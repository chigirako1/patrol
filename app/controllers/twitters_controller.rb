class TwittersController < ApplicationController
  before_action :set_twitter, only: %i[ show edit update destroy ]

  module ModeEnum
    UNASSOCIATED_TWT_ACNT = '未紐づけTWTアカウント' #PXV DBにはTWT IDが登録されているがTWT DBにはPXV IDが登録されていない
    ALL_IN_ONE = 'all in one'
    URL_TXT = 'url txt'
  end

  # GET /twitters or /twitters.json
  def index

    if params[:mode] == ""
      mode = "id"
    else
      mode = params[:mode]
    end
    puts %!mode="#{mode}"!

    if params[:num_of_disp].presence
      @num_of_disp = params[:num_of_disp].to_i
    else
      @num_of_disp = 10
    end
    puts %!num_of_disp="#{@num_of_disp}"!

    if params[:hide_within_days] == ""
      @hide_within_days = 0
    else
      @hide_within_days = params[:hide_within_days].to_i
    end
    puts %!hide_within_days="#{@hide_within_days}"!

    if params[:pred] == ""
      pred_cond_gt = 0
    else
      pred_cond_gt = params[:pred].to_i
    end
    puts %!pred_cond_gt="#{pred_cond_gt}"!

    if params[:force_disp_day].presence
      force_disp_day = params[:force_disp_day].to_i
    else
      force_disp_day = 0
    end
    puts %!force_disp_day="#{force_disp_day}"!

    if params[:rating] == ""
      rating_gt = 0
    else
      rating_gt = params[:rating].to_i
    end
    puts %!rating_gt="#{rating_gt}"!

    if params[:rating_lt] == ""
      rating_lt = 0
    else
      rating_lt = params[:rating_lt].to_i
    end
    puts %!rating_lt="#{rating_lt}"!

    if params[:thumbnail].presence
      @thumbnail = true
    else
      @thumbnail = false
    end
    puts %!thumnail="#{@thumbnail}"!
    
    if params[:sort_by].presence
      sort_by = params[:sort_by]
    else
      sort_by = ""
    end
    puts %!sort_by="#{sort_by}"!
    
    if params[:no_pxv].presence
      no_pxv = true
    else
      no_pxv = false
    end
    puts %!no_pxv="#{no_pxv}"!

    if params[:step].presence
      step = params[:step].to_i
    else
      step = 3
    end
    puts %!step="#{step}"!

    if true
      sql_query = "LEFT OUTER JOIN artists ON twitters.twtid = artists.twtid"
    else
      sql_query = "LEFT OUTER JOIN artists ON UPPER(twitters.twtid) = UPPER(artists.twtid)"
    end
    
    if mode == "search"
      col, word = Twitter.looks("(自動判断)", params[:search_word], "auto")
      twitters = Twitter.joins(
        sql_query
      ).select("artists.id AS artist_id,
            artists.pxvid AS artist_pxvid,
            twitters.twtid AS twitter_twtid,
            artists.twtid AS artist_twtid,
            artists.status AS artist_status,
            artists.rating AS artist_rating,
            artists.last_access_datetime AS artists_last_access_datetime,
            artists.*, twitters.*").where(col, word)
      #@twitters_total_count = twitters.count
      #puts twitters.size
    else
      twitters = Twitter.joins(
        sql_query
      ).select("artists.id AS artist_id,
            artists.pxvid AS artist_pxvid,
            artists.status AS artist_status,
            artists.rating AS artist_rating,
            artists.last_access_datetime AS artists_last_access_datetime,
            artists.last_ul_datetime AS artists_last_ul_datetime,
            artists.*, twitters.*")
    end

    if no_pxv
      twitters = twitters.select {|x| !(x.pxvid.presence) and x.artist_pxvid == nil or x.artist_status == "長期更新なし" or x.artist_status == "半年以上更新なし"}
    end

    case mode
    when TwittersController::ModeEnum::UNASSOCIATED_TWT_ACNT
      unassociated_twt_screen_names = Twitter::unassociated_twt_screen_names()
      twitters = twitters.select {|x| unassociated_twt_screen_names.include?(x.twtid)}
      @twitters_group = {}
      @twitters_group[""] = twitters
      return
    when TwittersController::ModeEnum::URL_TXT
      return
    when TwittersController::ModeEnum::ALL_IN_ONE
      @twitters_group = {}

      group_list = []

      if params[:num_of_times].presence
        num_of_times = params[:num_of_times].to_i
      else
        num_of_times = 3
      end
      puts %!num_of_times="#{num_of_times}"!

      if params[:ex_pxv].presence and params[:ex_pxv] == "true"
        tmp = twitters.select {|x|
          x.select_cond_no_pxv
        }
      else
        tmp = twitters
      end

      twitters_bak = twitters


      if false#true
        group = {}
        
        twitters = twitters.select {|x| x.drawing_method == params[:target]}
        twitters = twitters.select {|x| x.status == "TWT巡回"}
        twitters = twitters.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}
        
        r = 85
        twitters_w = twitters.select {|x| x.rating == nil or x.rating >= r }
        group["#{r}A:アクセス日順"] = twitters_w

        r = 80
        twitters = twitters.select {|x| x.rating == nil or x.rating >= r }
        group["#{r}A:アクセス日順"] = twitters

        twitters = twitters.sort_by {|x| [-x.prediction, -(x.rating||0), x.last_access_datetime]}
        group["#{r}A:予測数順"] = twitters

        group_list << group
      end

      if true
        top = [89, rating_gt - 1].min
        bottom = top - 9
        group_list << routine_group(twitters, params, bottom, top)
      end

      num_of_times.times do |cnt|
        group, @twitters_total_count = index_all_in_one(tmp, params, rating_gt, rating_lt)
        if group
          group_list << group
        end
      
        rating_lt = rating_gt
        rating_gt -= step
      end
      @rating_min = rating_gt

      ###
      twitters = twitters_bak
      #tmp = tmp.select {|x| x.select_cond_no_pxv}
      twitters = twitters.select {|x| !(x.pxvid.presence) and x.artist_pxvid == nil or x.artist_status == "長期更新なし" or x.artist_status == "半年以上更新なし"}
      twitters = twitters.select {|x| x.rating == nil or x.rating == 0}

      if false
        twitters2 = twitters.select {|x| x.last_access_datetime_p(-30)}
        twitters2 = twitters2.sort_by {|x| [-x.prediction, x.last_access_datetime]}
        group = {}
        group["未設定"] = twitters2
        group_list << group
      end

      if true
        twitters_w = twitters.select {|x| !x.last_access_datetime_p(-30)}
        twitters_w = twitters_w.sort_by {|x| [-x.prediction, x.last_access_datetime]}
        group = {}
        group["未設定 最近"] = twitters_w
        group_list << group
      end

      if true
        #twitters_w = twitters.select {|x| !x.last_access_datetime_p(-30)}
        twitters_w = twitters
        twitters_w = twitters_w.sort_by {|x| [-(x.filenum||0), x.last_access_datetime]}
        group = {}
        group["未設定 ファイル数↑"] = twitters_w
        group_list << group
      end

      @twitters_group = group_list[0].merge(*group_list)
      return
    when "同一"
      dup_ids = []
      twtids = Twitter.select('twtid')
      h = twtids.chunk {|x| x.twtid.upcase}
      h.each do |k,v|
        if v.size > 1
          dup_ids = k
        end
      end
      twitters = twitters.select {|x| dup_ids.include?(x.twtid.upcase)}
      @twitters_group = {}
      @twitters_group[""] = twitters
      return
    when "id"
      if rating_gt != 0
        twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt}
      elsif rating_gt == 0
        twitters = twitters.select {|x| x.rating == nil or x.rating == rating_gt}
      end

      if sort_by == "id"
        twitters = twitters.sort_by {|x| [x.id]}.reverse
      elsif  sort_by == "pred"
        twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime]}
      end

      if pred_cond_gt != 0
        if force_disp_day == 0
          twitters = twitters.select {|x| x.prediction >= pred_cond_gt}
        else
          twitters = twitters.select {|x| x.prediction >= pred_cond_gt or !x.last_access_datetime_p(force_disp_day)}
        end
      end
      
      if params[:target] != nil and params[:target] == ""
        @twitters_group = {}
        twitters = twitters.select {|x| x.drawing_method == params[:target] or x.drawing_method == nil}
        if @hide_within_days > 0
          twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
        else
          twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
        end
        @twitters_group[""] = twitters
      else
        @twitters_group = twitters.group_by {|x| %!#{x.status}:#{x.drawing_method}! }
      end
      return
    when "pxv_search"
      #@num_of_disp = 30
      twitters = twitters.select {|x| x.pxvid.presence and x.artist_pxvid == nil }
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.sort_by {|x| [x.id]}.reverse
      @twitters_group = {}
      @twitters_group[""] = twitters
      return
    when "access"
      twitters = twitters.sort_by {|x| [x.last_access_datetime]}.reverse
    when "rating_nil"
      #@num_of_disp = 30
      twitters = twitters.select {|x| x.rating == nil}
      twitters = twitters.sort_by {|x| [x.last_access_datetime]}.reverse
      @twitters_group = twitters.group_by {|x| x.rating}
    when "dl_nil"
      twitters = twitters.select {|x| x.last_dl_datetime == nil}
    when "not_patrol"
      twitters = twitters.select {|x| x.status != "TWT巡回"}
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "AI")}
    when "patrol3"
      twitters = twitters.select {|x| x.drawing_method != nil}
      twitters = twitters.select {|x|
        #x.status == "長期更新なし" or
        #x.status == "最近更新してない？" or
        x.status == "削除" or
        x.status == Twitter::TWT_STATUS::STATUS_NOT_EXIST or
        x.status == "凍結" or
        x.status == "別アカウントに移行" or
        x.status == "アカウントID変更"
      }
      if params[:target].presence
        twitters = twitters.select {|x| x.drawing_method == params[:target]}
      else
        twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "AI" or x.drawing_method == "パクリ")}
      end

      if pred_cond_gt != 0
        if force_disp_day == 0
          twitters = twitters.select {|x| x.prediction >= pred_cond_gt}
        else
          twitters = twitters.select {|x| x.prediction >= pred_cond_gt or !x.last_access_datetime_p(force_disp_day)}
        end
      end

      if rating_gt != 0
        twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt }
      end

      case sort_by
      when "access"
        twitters = twitters.sort_by {|x| [x.last_access_datetime]}
      else
        twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime]}
      end
      @twitters_group = twitters.group_by {|x| x.status}
      #@twitters_group = @twitters_group.sort_by {|k, v| k || 0}.reverse.to_h
      return
    when "patrol", "patrol2"
      twitters = twitters.select {|x| x.drawing_method != nil}
      if mode == "patrol"
        twitters = twitters.select {|x| x.status == "TWT巡回"}
      else
        twitters = twitters.select {|x|
          x.status == "長期更新なし" or
          x.status == "最近更新してない？" #or
          #x.status == "削除" or
          #x.status == "存在しない" or
          #x.status == "凍結" or
          #x.status == "別アカウントに移行" or
          #x.status == "アカウントID変更"
        }
      end
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      #twitters = twitters.select {|x| x.get_date_delta(x.last_access_datetime) > 0}
      #twitters = twitters.select {|x| x.id == 1388}
      
      if params[:target].presence
        twitters = twitters.select {|x| x.drawing_method == params[:target]}
      else
        twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "AI" or x.drawing_method == "パクリ")}
      end

      if pred_cond_gt != 0
        if force_disp_day == 0
          twitters = twitters.select {|x| x.prediction >= pred_cond_gt}
        else
          twitters = twitters.select {|x| x.prediction >= pred_cond_gt or !x.last_access_datetime_p(force_disp_day)}
        end
      end

      if rating_gt != 0
        twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt }
      end

      case sort_by
      when "access"
        #twitters = twitters.sort_by {|x| [-x.rating, x.last_access_datetime, (x.last_dl_datetime)]}#.reverse
        twitters = twitters.sort_by {|x| [x.last_access_datetime, (x.last_dl_datetime)]}#.reverse
      when "pred"
        twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime]}
      else
        twitters = twitters.sort_by {|x| [-x.rating, -x.prediction, x.last_access_datetime]}
      end

      @twitters_total_count = twitters.size
      twitters = twitters.first(@num_of_disp)#limit(@num_of_disp)#offset(3)

=begin
      case sort_by
      when "access"
      when "pred"
        @twitters_group[""] = twitters
        return
      else
      end
=end
    when "hand"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.select {|x| x.status == "TWT巡回"}
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "手描き")}
      if rating_gt != 0
        twitters = twitters.select {|x| x.rating != nil and x.rating >= rating_gt }
      end
      if params[:ex_pxv].presence and params[:ex_pxv] == "true"
        twitters = twitters.select {|x|
          artists_last_access_dayn = Util::get_date_delta(x.artists_last_access_datetime);
          !x.artists_last_ul_datetime.presence or
          (Util::get_date_delta(x.artists_last_ul_datetime) > 90 and
          artists_last_access_dayn > 90 )
        }
      end
      #twitter.artist_status
      #twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "手描き")}

=begin
      #twitters = twitters.select {|x| !(x.pxvid.presence) or (x.last_ul_datetime.presence and Util::get_date_delta(x.last_ul_datetime) > 60)}
      #twitters = twitters.select {|x| !(x.pxvid.presence)}
      twitters = twitters.select {|x|
        puts %!#{x.artists_last_ul_datetime}!
        puts %!#{x.artists_last_ul_datetime.class}!
        puts %!#{x.artists_last_ul_datetime.to_date}!
        puts %!#{Date.parse x.artists_last_ul_datetime}!
        puts %!#{(Time.zone.now.to_date - x.artists_last_ul_datetime.to_date).to_i}!
        puts %!@#{x.twtid}:#{x.pxvid}:#{Util::get_date_delta(x.artists_last_ul_datetime)}! if x.artists_last_ul_datetime.presence
        (x.artists_last_ul_datetime.presence and Util::get_date_delta(x.artists_last_ul_datetime) > 60)
      }
=end
      twitters = twitters.select {|x|
        !(x.pxvid.presence) or
        (x.last_ul_datetime.presence and Util::get_date_delta(Date.parse(x.last_ul_datetime).to_s) > 60)#last_post_datetime???
      }

      twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime]}
    when "no_pxv"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.select {|x| x.status == "TWT巡回"}
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "手描き")}
      if rating_gt != 0
        twitters = twitters.select {|x| x.rating != nil and x.rating >= rating_gt }
      end
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "手描き")}

      twitters = twitters.select {|x|
        x.artists_last_ul_datetime != nil and
        Util::get_date_delta(x.artists_last_ul_datetime) > 60 and
        Util::get_date_delta(x.artists_last_access_datetime) > 30
      }
      
      twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime]}
    when "未設定"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.select {|x| !(x.drawing_method.presence) }
      #twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime, (x.last_ul_datetime || "2000-01-01")]}
      #twitters = twitters.sort_by {|x| [x.last_access_datetime, (x.last_ul_datetime || "2000-01-01")]}.reverse
      twitters = twitters.sort_by {|x| [-(x.artist_pxvid || 0), x.last_access_datetime, (x.last_ul_datetime || "2000-01-01")]}.reverse
      @twitters_group = twitters.group_by {|x| x.status}
      return
    when "file"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      if rating_gt != 0
        twitters = twitters.select {|x| x.rating == nil or x.rating == 0 or x.rating >= rating_gt }
      end
      #twitters = twitters.select {|x| x.status == "TWT巡回"}

      #pxv_id_list, twt_urls, misc_urls = UrlTxtReader::get_url_list([], false)
      #known_ids = twt_urls.keys

      case params[:filename]
      when "", nil
        filepaths = UrlTxtReader::get_latest_txt
      when /(\d{4})/
        filepaths = UrlTxtReader::txt_file_list($1 + "\\d+")
      when /(\d{2})/
        filepaths = UrlTxtReader::txt_file_list($1 + "\\d{4}")
      when "all"
        filepaths = []
      else
        filepaths = params[:filename]
      end
      known_ids = UrlTxtReader::get_twt_id_list(filepaths)
      STDERR.puts %!size=#{known_ids.size}!
      #p known_ids
      twitters = twitters.select {|x| known_ids.include?(x.twtid) }
      STDERR.puts %!size=#{twitters.size}!
      twitters = twitters.sort_by {|x| [-(x.rating||0), -x.prediction, x.last_access_datetime]}
      @twitters_group = twitters.group_by {|x| x.key_for_group_by()}.sort_by {|k, v| k}.reverse.to_h
      return
    when "存在しない"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_NOT_EXIST}
      twitters = twitters.first(@num_of_disp)
      #@twitters_group = twitters.group_by {|x| [x.status, x.r18]}
      @twitters_group = twitters.group_by {|x| [x.rating]}.sort_by {|k, v| k || 0}.reverse.to_h
      return
    when "更新不可"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.select {|x| x.status != "TWT巡回"}
      @twitters_group = twitters.group_by {|x| [x.status, x.r18]}
      return
=begin
      ["TWT巡回", "TWT巡回"],
      ["TWT巡回不要", "TWT巡回不要"],
      ["長期更新なし★", "長期更新なし"], 
      ["TWT巡回不要(PXVチェック)", "TWT巡回不要(PXVチェック)"],
      ["最近更新してない？", "最近更新してない？"], 
      ["アカウント削除", "削除"],
      ["存在しない", "存在しない"],
      ["凍結", "凍結"],
      ["非公開アカウント", "非公開アカウント"],
      ["別アカウントに移行（存在はするが更新していない？）", "別アカウントに移行"],
      ["アカウントID変更", "アカウントID変更"],
=end

    when "all"
      twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime, (x.last_post_datetime || "2000-01-01")]}
    when "search"
      @twitters_group = twitters.group_by {|x| x.rating}
      @twitters_total_count = twitters.size
    else
      #twitters = twitters.select {|x| x.last_dl_datetime.year >= 2023}
      #twitters = twitters.select {|x| x.last_dl_datetime.month >= 11}
    end
    @twitters_group = twitters.group_by {|x| x.rating}
    @twitters_group = @twitters_group.sort_by {|k, v| k || 0}.reverse.to_h
  end

  # GET /twitters/1 or /twitters/1.json
  def show
    if params[:file_check].presence
      @twt_ids = Twt::get_twt_tweet_ids_from_txts(@twitter.twtid)
      if false
        if @twitter.old_twtid.presence
          old_twt_ids = Twt::get_twt_tweet_ids_from_txts(@twitter.old_twtid)
          @twt_ids = [@twt_ids, old_twt_ids].flatten
        end
      end
      force_read_all = true
    elsif (params[:refresh].presence and params[:refresh] == "y")
      force_read_all = true
    else
      force_read_all = false
      dn = Util::get_date_delta(@twitter.last_access_datetime)
      if dn > 0 or @twitter.last_access_datetime == nil
        @twitter.update(last_access_datetime: Time.now)
      else
        STDERR.puts "更新不要:#{dn}"
      end
    end
    @twt_pic_path_list = @twitter.get_pic_filelist(force_read_all)
  end

  # GET /twitters/new
  def new
    if params[:twtid].presence
      @twt_pic_path_list = Twt::get_pic_filelist(params[:twtid])
    end
    @twitter = Twitter.new
  end

  # GET /twitters/1/edit
  def edit
  end

  # POST /twitters or /twitters.json
  def create
    @twitter = Twitter.new(twitter_params)

    respond_to do |format|
      if @twitter.save
        format.html { redirect_to twitter_url(@twitter), notice: "Twitter was successfully created." }
        format.json { render :show, status: :created, location: @twitter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @twitter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twitters/1 or /twitters/1.json
  def update

    params[:twitter][:main_twtid] = Twt::get_screen_name(params[:twitter][:main_twtid])
    params[:twitter][:sub_twtid]  = Twt::get_screen_name(params[:twitter][:sub_twtid])
    params[:twitter][:alt_twtid]  = Twt::get_screen_name(params[:twitter][:alt_twtid])
    params[:twitter][:new_twtid]  = Twt::get_screen_name(params[:twitter][:new_twtid])
    params[:twitter][:old_twtid]  = Twt::get_screen_name(params[:twitter][:old_twtid])

    respond_to do |format|
      if @twitter.update(twitter_params)
        format.html { redirect_to twitter_url(@twitter), notice: "Twitter was successfully updated." }
        format.json { render :show, status: :ok, location: @twitter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @twitter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitters/1 or /twitters/1.json
  def destroy
    @twitter.destroy

    respond_to do |format|
      format.html { redirect_to twitters_url, notice: "Twitter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter
      @twitter = Twitter.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def twitter_params
      params.require(:twitter).permit(:twtid,
        :twtname, :filenum, :recent_filenum, :last_dl_datetime,
        :earliest_dl_datetime, :last_access_datetime,
        :comment, :remarks, :status, :pxvid,
        :drawing_method,
        :warning,
        :alt_twtid,
        :old_twtid,
        :rating,
        :r18,
        :update_frequency,
        :last_post_datetime,
        :sensitive,
        :private_account,
        :reverse_status,
        :new_twtid,
        :sub_twtid,
        :main_twtid,
        )
    end

    def index_all_in_one(twitters, params, rating_gt, rating_lt)

      twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt }
      if rating_lt > 0
        twitters = twitters.select {|x| x.rating == nil or x.rating < rating_lt }
      end
      twitters = twitters.select {|x| x.drawing_method == params[:target]}

      #### !!! こっちを先にやらないとだめ !!! ↓####
      #STDERR.puts %!twitters=#{twitters.size}!
      #twitters2 = twitters.select {|x| x.status == "長期更新なし" or x.status == "最近更新してない？"}
      twitters_check = twitters.select {|x| x.status == "最近更新してない？"}
      #STDERR.puts %!twitters2=#{twitters2.size}!
      ### ↑↑↑↑↑↑

      ####
      twitters = twitters.select {|x| x.status == "TWT巡回"}

      twitters_group = {}

      if true
        twitters = twitters.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}
        twitters_group["#{rating_gt}:アクセス日順"] = twitters
      end

      if true
        twitters = twitters.sort_by {|x| [-x.prediction, -(x.rating||0), x.last_access_datetime]}
        twitters_group["#{rating_gt}:予測順"] = twitters
      end

      twitters_total_count = twitters.size

      ### ###
      twitters = twitters.select {|x|x.select_cond_post_date()}

      if true
        twitters = twitters.sort_by {|x| [(x.last_post_datetime || "2000-01-01"), -(x.rating||0), x.prediction]}
        twitters_group["#{rating_gt}:投稿日順"] = twitters
      end

      if true
        STDERR.puts %!xxx(twitters_check.size)=#{twitters_check.size}!
        twitters_check = twitters_check.select {|x| x.select_cond_post_date}
        twitters_check = twitters_check.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}
        if twitters_check.size > 0
          twitters_group["#{rating_gt}:更新なし"] = twitters_check
        else
          STDERR.puts %!更新なしゼロ件!
        end
      end

      if true and rating_gt != rating_lt
        twitters = twitters.select {|x| !x.last_access_datetime_p(3)}

        #twitters = twitters.sort_by {|x| [-(x.rating||0), x.last_access_datetime, x.prediction]}
        twitters = twitters.sort_by {|x| [-(x.rating||0), x.prediction, x.last_access_datetime]}
        twitters_group["#{rating_gt}:評価順"] = twitters
      end

      [twitters_group, twitters_total_count]
    end

    def routine_group(twitters_arg, params, l_limit_r, u_limit_r)
      if l_limit_r > u_limit_r
        raise "不正な引き数:#{l_limit_r}-#{u_limit_r}" 
      end

      twitters = twitters_arg
      group = {}

      twitters = twitters.select {|x| x.drawing_method == params[:target]}
      twitters = twitters.select {|x| x.status == "TWT巡回"}
      
      twitters = twitters.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}

      twitters_pred_list = []
      twitters_accs_list = []

      rate = l_limit_r
      while rate <= u_limit_r
        #STDERR.puts %!#{rate} - #{u_limit_r}!
        twitters_wk = twitters.select {|x| x.rating == rate}
        rate += 1

        if twitters_wk.size == 0
          next
        end

        twitters_wk = twitters_wk.sort_by {|x| [-x.prediction, x.last_access_datetime]}
        twitters_pred_list << twitters_wk.first(1)[0]

        twitters_wk = twitters_wk.sort_by {|x| [x.last_access_datetime, -x.prediction]}
        twitters_accs_list << twitters_wk.first(1)[0]
      end

      group["(#{l_limit_r}-#{u_limit_r}):予測数順"] = twitters_pred_list.sort_by {|x| [-x.rating]}
      group["(#{l_limit_r}-#{u_limit_r}):アクセス日順"] = twitters_accs_list.sort_by {|x| [-x.rating]}

      group
    end
end
