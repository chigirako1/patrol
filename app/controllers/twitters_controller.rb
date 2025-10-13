class TwittersController < ApplicationController
  before_action :set_twitter, only: %i[ show edit update destroy ]

  module ModeEnum
    UNASSOCIATED_TWT_ACNT = '未紐づけTWTアカウント' #PXV DBにはTWT IDが登録されているがTWT DBにはPXV IDが登録されていない
    ALL_IN_ONE = 'all in one'
    ALL_IN_1 = 'all in 1'
    URL_TXT = 'url txt'
    PATROL = 'patrol'
    STATS = 'stats'
    SEARCH = "search"
  end

  module SORT_BY
    ID = "id"
    PRED = "pred"
    ACCESS = "access"
    RATING = "rating"
  end

  module GRP_SORT
      GRP_SORT_PRED = "予測順"
      GRP_SORT_ACCESS = "アクセス日順"
      GRP_SORT_UL = "投稿日順"
      GRP_SORT_UL_ACCESS = "投稿日とアクセス日の差順"
      GRP_SORT_NO_UPDATE = "更新なし"
      GRP_SORT_RATE = "評価順"
      GRP_SORT_DEL = "削除"

      #
      GRP_SPLIT_STR = "|"
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
    
    if mode == TwittersController::ModeEnum::SEARCH
      target_col = params[:target_col]
      target_col = Twitter::SEARCH_TARGET::AUTO unless target_col
      match_method = params[:match_method]#Twitter::MATCH_METHOD::AUTO
      match_method = Twitter::MATCH_METHOD::AUTO unless match_method
      
      col, word = Twitter.looks(target_col, params[:search_word], match_method)
      p col
      p word
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
      #puts twitters.size
      #if 
      #twitters = twitters.where(col, word)
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
    when TwittersController::ModeEnum::ALL_IN_1

      tmp = twitters
      group = index_all_in_1(tmp, params, rating_gt, pred_cond_gt)
      @twitters_group = group
      @twitters_total_count = @twitters_group.sum {|k,v| v.count}

      if true
        @twitters_group.each do |k,v|
          v.each do |x|
            puts %!#{x.twtname}(@#{x.twtid})!
          end
        end
      end
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

=begin
      if false#true
        group = {}
        
        twitters = twitters.select {|x| x.drawing_method == params[:target]}
        twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}
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
=end
      if true
        rat = [rating_gt - 5, 85].min
        twitters_wk = twitters
        twitters_wk = twitters_wk.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}
        twitters_wk = twitters_wk.select {|x| x.drawing_method == params[:target]}
        twitters_wk = twitters_wk.select {|x| (x.rating||0) >= rat }
        twitters_wk = twitters_wk.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}
        group = {}
        group["xxx(#{rat}):アクセス日順"] = twitters_wk
        group_list << group
      end

      if params[:aio].presence
        keys = params[:aio].split(GRP_SORT::GRP_SPLIT_STR)

        target_hash = {}
        keys.each do |key|
          target_hash[key] = true
        end
      else
        if params[:tgt_access].present?
          target_hash = {}
          key = GRP_SORT::GRP_SORT_ACCESS
          target_hash[key] = true
        end
      end
      STDERR.puts %!target_hash=#{target_hash}!

      num_of_times.times do |cnt|
        group, @twitters_total_count = index_all_in_one(tmp, params, rating_gt, rating_lt, target_hash)
        if group
          group_list << group
        end
      
        if step > 0
          #rating_lt = rating_gt
          rating_gt -= step
        else
          rating_gt -= step
        end
      end
      @rating_min = rating_gt

      rating_gt += step - 1

      if target_hash == nil
        top = [89, rating_gt].min
        bottom = top - 9
        group_list << routine_group(twitters, params, bottom, top)
      end

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
        nday = 30
        twitters_w = twitters.select {|x| !x.last_access_datetime_p(-nday)}
        twitters_w = twitters_w.select {|x| x.status != Twitter::TWT_STATUS::STATUS_NOT_EXIST}
        twitters_w = twitters_w.sort_by {|x| [-x.prediction, x.last_access_datetime]}
        group = {}
        group["未設定 最近(#{nday}d)"] = twitters_w
        group_list << group
      end

      if true
        nday = 90
        twitters_w = twitters.select {|x| !x.last_access_datetime_p(-nday)}
        twitters_w = twitters_w.select {|x| x.filenum||0 > 10}
        twitters_w = twitters_w.select {|x| x.status != Twitter::TWT_STATUS::STATUS_NOT_EXIST}
        twitters_w = twitters_w.sort_by {|x| [-x.prediction, x.last_access_datetime]}
        group = {}
        group["未設定 #{nday}d"] = twitters_w
        group_list << group
      end

      if true
        nday = 180
        twitters_w = twitters.select {|x| !x.last_access_datetime_p(-nday)}
        twitters_w = twitters_w.select {|x| x.filenum||0 > 10}
        twitters_w = twitters_w.select {|x| x.status != Twitter::TWT_STATUS::STATUS_NOT_EXIST}
        twitters_w = twitters_w.sort_by {|x| [-x.prediction, x.last_access_datetime]}
        group = {}
        group["未設定 #{nday}d"] = twitters_w
        group_list << group
      end

      if true
        nday = 90
        twitters_w = twitters
        twitters_w = twitters_w.select {|x| !x.last_access_datetime_p(-(nday))}
        twitters_w = twitters_w.select {|x| !x.last_access_datetime_p(30) or x.prediction > 10}
        twitters_w = twitters_w.sort_by {|x| [-(x.filenum||0), x.last_access_datetime]}
        group = {}
        group["未設定 総ファイル数↑(#{nday}d)"] = twitters_w
        group_list << group
      end

      if true
        nday = 360
        twitters_w = twitters
        twitters_w = twitters_w.select {|x| !x.last_access_datetime_p(-(nday))}
        twitters_w = twitters_w.select {|x| !x.last_access_datetime_p(60) or x.prediction > 10}
        twitters_w = twitters_w.sort_by {|x| [-(x.filenum||0), x.last_access_datetime]}
        group = {}
        group["未設定 総ファイル数↑(#{nday}d)"] = twitters_w
        group_list << group
      end

      if true
        nday = 0
        twitters_w = twitters
        #twitters_w = twitters_w.select {|x| !x.last_access_datetime_p(-(nday))}
        twitters_w = twitters_w.select {|x| !x.last_access_datetime_p(60) or x.prediction > 10}
        twitters_w = twitters_w.sort_by {|x| [-(x.filenum||0), x.last_access_datetime]}
        group = {}
        group["未設定 総ファイル数↑(#{nday}d)"] = twitters_w
        group_list << group
      end

      @twitters_group = group_list[0].merge(*group_list)
      return
    when "同一"
      dup_ids = []
      twtids = Twitter.select('twtid')
      h = twtids.chunk {|x| x.twtid.upcase}
      h.each do |k,v|
        #puts %!#{k}|#{v}!
        if v.size > 1
          STDERR.puts %!dup="#{k}"!
          dup_ids << k
        end
      end
      STDERR.puts %!#{dup_ids}!
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

      if sort_by == SORT_BY::ID
        twitters = twitters.sort_by {|x| [x.id]}.reverse
      elsif  sort_by == SORT_BY::PRED
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
        twitters = twitters.select {|x| x.drawing_method == params[:target] or x.drawing_method == nil}
        if @hide_within_days > 0
          twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
        else
          twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
        end
        #@twitters_group = {}
        #@twitters_group[""] = twitters
        @twitters_group = twitters.group_by {|x| %!#{x.status}!}
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
      twitters = twitters.select {|x| x.status != Twitter::TWT_STATUS::STATUS_PATROL}
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "AI")}
    when "patrol3"
      twitters = twitters.select {|x| x.drawing_method != nil}
      twitters = twitters.select {|x|
=begin
        #x.status == "長期更新なし" or
        #x.status == "最近更新してない？" or
        x.status == "削除" or
        x.status == Twitter::TWT_STATUS::STATUS_NOT_EXIST or
        x.status == "凍結" or
        x.status == "別アカウントに移行" or
        x.status == "アカウントID変更"
=end
        x.update_chk?
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
      when SORT_BY::ACCESS
        twitters = twitters.sort_by {|x| [x.last_access_datetime]}
      else
        twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime]}
      end
      @twitters_group = twitters.group_by {|x| x.status}
      #@twitters_group = @twitters_group.sort_by {|k, v| k || 0}.reverse.to_h
      return
    when TwittersController::ModeEnum::PATROL, "patrol2", TwittersController::ModeEnum::STATS
      twitters = twitters.select {|x| x.drawing_method != nil}
      if mode == TwittersController::ModeEnum::PATROL
        twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}
      elsif mode == TwittersController::ModeEnum::STATS
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
        puts %!target=#{params[:target]}!
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

      if rating_lt != 0
        puts %!xyx #{twitters.size}!
        twitters = twitters.select {|x| x.rating == nil or x.rating <= rating_lt }
        puts %!xyy #{twitters.size} (#{rating_lt})!
      end

      case sort_by
      when SORT_BY::ACCESS
        #twitters = twitters.sort_by {|x| [-x.rating, x.last_access_datetime, (x.last_dl_datetime)]}#.reverse
        twitters = twitters.sort_by {|x| [x.last_access_datetime, (x.last_dl_datetime)]}#.reverse
      when SORT_BY::PRED
        twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime]}
      else
        twitters = twitters.sort_by {|x| [-(x.rating||0), -x.prediction, x.last_access_datetime]}
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
      twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}
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
      twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}
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
      #twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}

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
      twitters = twitters.select {|x| x.status != Twitter::TWT_STATUS::STATUS_PATROL}
      @twitters_group = twitters.group_by {|x| [x.status, x.r18]}
      return

    when "all"
      twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime, (x.last_post_datetime || "2000-01-01")]}
    when TwittersController::ModeEnum::SEARCH
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
      STDERR.puts %!@twt_ids=#{@twt_ids.size}!

      # TODO: スクリーンネーム変更の場合の対応
      old_chk = true
      if old_chk
        if @twitter.old_twtid.presence
          old_twt_ids = Twt::get_twt_tweet_ids_from_txts(@twitter.old_twtid)
          @twt_ids = [@twt_ids, old_twt_ids].flatten.sort
          STDERR.puts %!@twt_ids=#{@twt_ids}!
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
    twtname = params[:twitter][:twtname]
    twtname_mod = Twt::sanitize_filename(twtname)
    if twtname != twtname_mod
      msg = %![update] 置換文字あり："#{twtname}" => "#{twtname_mod}"!
      Rails.logger.info(msg)
      params[:twitter][:twtname] = twtname_mod
    end

    if params[:twitter][:rating] and @twitter.rating != params[:twitter][:rating].to_i
      if @twitter.change_history.presence
        prev_val = @twitter.change_history
      else
        prev_val = @twitter.rating
      end
      c_history = %!#{prev_val}=>#{params[:twitter][:rating]}!
      STDERR.puts %![dbg]#{c_history}!
      params[:twitter][:change_history] = c_history
    end

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
        :latest_tweet_id,
        :oldest_tweet_id,
        :zipped_at,
        :change_history
        )
    end

    def index_all_in_1(twitters, params, rating_gt, pred_cond_gt)
      twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt }
      twitters = twitters.select {|x| x.drawing_method == params[:target]}

      if @hide_within_days > 0
        twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      end
      
      if true
        twitters_wk = twitters

        if pred_cond_gt > 0
          twitters_wk = twitters_wk.select {|x| x.prediction >= pred_cond_gt}
        end

        twitters_wk = twitters_wk.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}

        twitters_wk = twitters_wk.select {|x| x.select_cond_aio(pred_cond_gt)}

        case params[:sort_by]
        when SORT_BY::ACCESS
          twitters_wk = twitters_wk.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}
          
          twitters_group = twitters_wk.group_by {|x| %!#{x.rating}|#{x.last_access_datetime_days_elapsed / 30}!}.sort_by {|k, v| k}.reverse.to_h
        when SORT_BY::RATING
        else
          twitters_wk = twitters_wk.sort_by {|x| [-(x.rating||0), -x.prediction, x.last_access_datetime]}

          twitters_group = twitters_wk.group_by {|x| %!#{x.rating}|#{x.last_access_datetime_days_elapsed / 30}!}#.sort_by {|k, v| k}.reverse.to_h
        end
      end

      if true
        twitters_check = twitters.select {|x| x.update_chk?}
        #STDERR.puts %!|xxx|[#{rating_gt}](twitters_check.size)=#{twitters_check.size}!
        twitters_check = twitters_check.select {|x| x.select_cond_post_date}
        twitters_check = twitters_check.select {|x| x.status != Twitter::TWT_STATUS::STATUS_WAITING}
        twitters_check = twitters_check.sort_by {|x| [-(x.rating||0), x.last_access_datetime, -x.prediction]}
        if twitters_check.size > 0
          #twitters_group["#{rating_gt}:更新なし"] = twitters_check
          tmp_grp = twitters_check.group_by {|x| x.status}
          twitters_group.merge!(tmp_grp)
        else
          STDERR.puts %!|xxx|更新なしゼロ件!
        end
      end

      twitters_group
    end

    def index_all_in_one(twitters, params, rating_gt, rating_lt, target_hash)
      twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt }
      if rating_lt > 0
        twitters = twitters.select {|x| x.rating == nil or x.rating < rating_lt }
      end
      twitters = twitters.select {|x| x.drawing_method == params[:target]}

      #### !!! こっちを先にやらないとだめ !!! ↓####
      #STDERR.puts %!twitters=#{twitters.size}!
      #twitters2 = twitters.select {|x| x.status == "長期更新なし" or x.status == "最近更新してない？"}
      
      #twitters_check = twitters.select {|x| x.status == "最近更新してない？"}
      twitters_check = twitters.select {|x| x.update_chk?}
      
      #STDERR.puts %!twitters2=#{twitters2.size}!
      ### ↑↑↑↑↑↑

      ####
      twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}

      twitters_group = {}

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_ACCESS]
        twitters = twitters.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}
        twitters_group["#{rating_gt}:アクセス日順"] = twitters
      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_PRED]
        twitters = twitters.sort_by {|x| [-x.prediction, -(x.rating||0), x.last_access_datetime]}

        if @hide_within_days > 0
          twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
        end
        
        twitters_group["#{rating_gt}:予測順"] = twitters
      end

      twitters_total_count = twitters.size

      ### ###
      twitters = twitters.select {|x|x.select_cond_post_date()}

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_UL]
        twitters = twitters.sort_by {|x| [(x.last_post_datetime || "2000-01-01"), -(x.rating||0), x.prediction]}
        twitters_group["#{rating_gt}:投稿日順"] = twitters
      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_UL_ACCESS]
        twitters = twitters.sort_by {|x| [-((x.last_access_datetime||"2000-01-01") - (x.last_post_datetime||"2000-01-01")), -(x.rating||0), x.prediction]}
        twitters_group["#{rating_gt}:#{GRP_SORT::GRP_SORT_UL_ACCESS}"] = twitters
      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_NO_UPDATE]
        STDERR.puts %!|xxx|[#{rating_gt}](twitters_check.size)=#{twitters_check.size}!
        twitters_check = twitters_check.select {|x| x.select_cond_post_date}
        twitters_check = twitters_check.select {|x| x.status != Twitter::TWT_STATUS::STATUS_WAITING}
        twitters_check = twitters_check.sort_by {|x| [x.last_access_datetime, -(x.rating||0), -x.prediction]}
        if twitters_check.size > 0
          twitters_group["#{rating_gt}:更新なし"] = twitters_check
        else
          STDERR.puts %!|xxx|更新なしゼロ件/rating_gt=#{rating_gt}!
        end
      end

      if (target_hash == nil or target_hash[GRP_SORT::GRP_SORT_RATE]) and rating_gt != rating_lt
        twitters = twitters.select {|x| !x.last_access_datetime_p(5) or x.prediction > 5}

        #twitters = twitters.sort_by {|x| [-(x.rating||0), x.last_access_datetime, x.prediction]}
        twitters = twitters.sort_by {|x| [-(x.rating||0), -(x.prediction), x.last_access_datetime]}
        twitters_group["#{rating_gt}:評価順"] = twitters
      end

      [twitters_group, twitters_total_count]
    end

    def routine_group(twitters_arg, params, l_limit_r, u_limit_r)
      STDERR.puts %!#{l_limit_r}|#{u_limit_r}!
      if l_limit_r > u_limit_r
        raise "不正な引き数:#{l_limit_r}-#{u_limit_r}" 
      end

      twitters = twitters_arg
      group = {}

      twitters = twitters.select {|x| x.drawing_method == params[:target]}
      twitters = twitters.select {|x| x.status == Twitter::TWT_STATUS::STATUS_PATROL}
      
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

      if true
        group["(#{u_limit_r}-#{l_limit_r}):アクセス日順"] = twitters_accs_list.sort_by {|x| [-x.rating]}
        group["(#{u_limit_r}-#{l_limit_r}):予測数順"] = twitters_pred_list.sort_by {|x| [-x.rating]}
      end

      group
    end
end
