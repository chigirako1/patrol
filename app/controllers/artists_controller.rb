
#------------------------------------------------------------------------------
# class:
#------------------------------------------------------------------------------
class Params
  attr_accessor :param_file,
    :twt,
    :feat_3d,
    :ai,
    :exclude_ai,
    :nje,
    :year_since,
    :year_until,
    :display_number,
    :group_by,
    :sort_by,
    :status,
    :amount_gt,
    :amount_lt,
    :recent_filenum,
    :filename,
    :last_access_datetime,
    :r18,
    :point,
    :prediction,
    :force_disp_day,
    :rating,
    :twt_chk,
    :thumbnail,
    :begin_no,
    :reverse_status,
    :url_list_only

  def initialize(params)
    @group_by = params[:group_by]
    @sort_by = params[:sort_by]
    @status = params[:status]
    @reverse_status = params[:reverse_status]
    @point = params[:point]
    @prediction = params[:prediction]
    @force_disp_day = params[:force_disp_day]
    @rating = params[:rating]
    @twt_chk = params[:twt_chk]
    puts %!group_by="#{@group_by}"/sort_by="#{@sort_by}"/!

    if @point == nil
      @point = 0
    else
      @point = @point.to_i
    end
    puts "point=#{@point}"

    if @prediction == nil
      @prediction = 0
    else
      @prediction = @prediction.to_i
    end
    puts "prediction=#{@prediction}"

    if @force_disp_day == nil
      @force_disp_day = 0
    else
      @force_disp_day = @force_disp_day.to_i
    end
    puts "force_disp_day=#{@force_disp_day}"

    if @rating == nil or @rating == ""
      @rating = -1
    else
      @rating = @rating.to_i
    end
    puts "rating=#{@rating}"

    if @status == nil
      @status = ""
    end
    puts "status=#{@status}"
    
    if @reverse_status == nil
      @reverse_status = ""
    end
    puts "reverse_status=#{@reverse_status}"
    
    begin_no = params[:begin_no]
    if begin_no == nil
      @begin_no = 0
    else
      @begin_no = begin_no.to_i
    end
    puts "begin_no=#{@begin_no}"

    @r18 = params[:r18]
    if @r18 == nil
      @r18 = ""
    end
    puts "r18=#{@r18}"

    year = params[:year]
    if year =~ /^(\d{4}):(\d{4})$/
      @year_since = $1.to_i
      @year_until = $2.to_i
    elsif year =~ /^(\d{4})$/
      @year_since = $1.to_i
      @year_until = $1.to_i
    elsif year =~ /^(\d{4}):$/
      @year_since = $1.to_i
      @year_until = 0
    elsif year =~ /^:(\d{4})$/
      @year_since = 0
      @year_until = $1.to_i
    else
      @year_since = 0
      @year_until = 0
    end
    puts "year=#{@year_since}:#{@year_until}"

    amount_gt = params[:amount_gt]
    amount_lt = params[:amount_lt]
    if amount_gt == nil or amount_gt == ""
      @amount_gt = 0
    else
      @amount_gt = amount_gt.to_i
    end
    if amount_lt == nil or amount_lt == ""
      @amount_lt = 0
    else
      @amount_lt = amount_lt.to_i
    end
    puts "amount=#{@amount_gt}-#{@amount_lt}"

    recent_filenum = params[:recent_filenum]
    if recent_filenum.presence
      @recent_filenum = recent_filenum.to_i
    else
      @recent_filenum = 0
    end
    puts "recent_filenum=#{@recent_filenum}"

    last_access_datetime = params[:last_access_datetime]
    if last_access_datetime == nil or last_access_datetime == 0
      @last_access_datetime = 0
    else
      @last_access_datetime = last_access_datetime.to_i
    end
    puts "last_access_datetime=#{@last_access_datetime}"

    display_number = params[:display_number]
    if display_number == nil
      @display_number = 3
    else
      @display_number = display_number.to_i
    end
    if @display_number == 0
      @display_number = 3
    end
    puts %!@display_number=#{@display_number}!

    twt = params[:twt]
    if twt == "true"
      @twt = true
      #puts %!@twt=#{@twt}!
    end

    feat_3d = params[:feat_3d]
    if feat_3d != nil and feat_3d == "true"
      @feat_3d = true
    end

    ai = params[:ai]
    if ai != nil and ai == "true"
      @ai = true
    end
    
    exclude_ai = params[:exclude_ai]
    if exclude_ai and exclude_ai == "true"
      @exclude_ai = true
    end

    nje = params[:nje]
    if nje != nil and nje == "true"
      @nje = true
    end

    thumbnail = params[:thumbnail]
    if thumbnail != nil and thumbnail == "true"
      @thumbnail = true
      #puts %!@thumbnail=#{@thumbnail}!
    end
    puts %![twt:#{@twt}],[ai:#{@ai}],[thumbnail:#{@thumbnail}],[feat_3d:#{@feat_3d}]!

    @param_file = params[:file]
    filename = params[:filename]
    if filename == nil
      @filename = ""
    else
      @filename = filename
    end
    puts %!param_file="#{@param_file}"/filename="#{@filename}"!

    @url_list_only = false
    url_list_only = params[:url_list_only]
    if url_list_only == "true"
      @url_list_only = true
      puts %!url_list_only="#{@url_list_only}"!
    end
  end
end

#------------------------------------------------------------------------------
# class:
#------------------------------------------------------------------------------
class ArtistsController < ApplicationController
  extend UrlTxtReader
  #extend Nje
  
  before_action :set_artist, only: %i[show edit update destroy edit_no_update]

  module MethodEnum
    REGIST_UL_DIFF = '新規登録日と最新投稿日の日数差'
    REGIST_UL_DIFF_NEAR = '新規登録日と昔の投稿日の日数差近い'
  end

  # GET /artists or /artists.json
  def index
    @twt_urls = {}
    @unknown_id_list = []
    @misc_urls = []
    @authors_list = []
    @twt = false

    prms = Params.new(params)
    @size_per_table = prms.display_number
    @begin_no = prms.begin_no
    @thumbnail = prms.thumbnail

    @artists_group = {}

    if params[:file] == "検索"
      artists = Artist.looks(params[:target_col], params[:search_word], params[:match_method])
      @artists_group = index_group_by(artists, prms)
      return
    else
      artists = Artist.all
    end

    if prms.param_file == "urllist" or
      prms.param_file == "urllist-pxv-only" or
      prms.param_file == "urllist-pxv-only(latest)" or
      prms.param_file == "urllist-unknown-only" or
      prms.param_file == "urllist-twt-only" or
      prms.param_file == "urllist-twt-only(latest)"
      if prms.url_list_only
        @misc_urls = Artist.get_url_list_from_all_txt
        return
      else
        datestr = prms.filename
        if prms.param_file == "urllist-twt-only(latest)" or prms.param_file == "urllist-pxv-only(latest)"
          #path = "public/get illust url_1029.txt"
          path = UrlTxtReader::get_latest_txt
        elsif datestr == ""
          path = ""
        else
          path = "public/get illust url_#{datestr}.txt"
        end
        puts "path='#{path}'"
        id_list, @twt_urls, @misc_urls = Artist.get_url_list(path)

        if prms.param_file == "urllist-unknown-only"
          artists = artists.first(1)
          @twt_urls = {}
          @twt = false
          @unknown_id_list = Artist.get_unknown_id_list(id_list)
        elsif prms.param_file == "urllist-pxv-only" or  prms.param_file == "urllist-pxv-only(latest)"
          artists = artists.select {|x| id_list.include?(x[:pxvid])}
          @twt_urls = {}
          @twt = false
          #@unknown_id_list = Artist.get_unknown_id_list(id_list)
        elsif prms.param_file == "urllist-twt-only" or prms.param_file == "urllist-twt-only(latest)"
          artists = artists.first(1)
          @twt = true
        else
          artists = artists.select {|x| id_list.include?(x[:pxvid])}
          puts %!artists.size=#{artists.size}!
          @twt = true
          @unknown_id_list = Artist.get_unknown_id_list(id_list)
        end
      end
    elsif prms.param_file == "unchecked-pxv"
      twt_pxvids = Twitter.select('pxvid')
      pxvids = twt_pxvids.filter_map {|x| x.pxvid if x.pxvid.presence }
      pxvids.sort.uniq.each {|pxvid|
        artist = Artist.find_by(pxvid: pxvid)
        if artist.presence
        else
          @unknown_id_list << pxvid
        end
      }
    elsif prms.param_file == "unchecked-twt"
      pxv_twtids = Artist.select('twtid')
      twtids = pxv_twtids.filter_map {|x| x.twtid if x.twtid.presence }
      twtids.sort.uniq.each {|twtid|
        twt = Twitter.find_by(twtid: twtid)
        if twt.presence
        else
          @misc_urls << twtid
        end
      }
    elsif prms.param_file == "twt-twt"
      alt_twt_ids = Twitter.select('alt_twtid')
      twtids_alt = alt_twt_ids.filter_map {|x| x.alt_twtid if x.alt_twtid.presence }

      old_twt_ids = Twitter.select('old_twtid')
      twtids_old = old_twt_ids.filter_map {|x| x.old_twtid if x.old_twtid.presence }

      [twtids_alt, twtids_old].flatten.sort.uniq.each {|twtid|
        twt = Twitter.find_by(twtid: twtid)
        if twt.presence
        else
          @misc_urls << Twt::twt_user_url(twtid)
        end
      }
    elsif prms.param_file == "pxvids"
      @twt = true
      id_list = Artist.get_id_list_tsv#get_id_list()
      artists = artists.select {|x| id_list.include?(x[:pxvid])}

      @unknown_id_list = Artist.get_unknown_id_list(id_list)
    elsif prms.param_file == "namelist"
      @authors_list = UrlTxtReader::authors_list("r18book_author_20230813.tsv", "book")
      return
    elsif prms.param_file == "namelist_djn"
      @authors_list = UrlTxtReader::authors_list("stat-djn-20230819.tsv", "djn")
      return
    elsif prms.param_file == "namelist_mag"
      @authors_list = UrlTxtReader::authors_list("mag_stat_20230727.tsv", "mag")
      return
    elsif prms.param_file == "same_name"
      dup_pxvnames = UrlTxtReader::same_name(artists)
      puts "dup name=#{dup_pxvnames}"
      artists = artists.select {|x| dup_pxvnames.include?(x[:pxvname])}
    elsif prms.param_file == "same_twtid"
      artists = artists.select {|x| x.twtid != ""}
      dup_twtids = UrlTxtReader::same_twtid(artists)
      puts "dup id=#{dup_twtids}"
      artists = artists.select {|x| dup_twtids.include?(x[:twtid])}
    elsif prms.param_file == "ファイル0件未登録"
      archive_dir_id_list = Pxv::archive_dir_id_list()
      @unknown_id_list = Artist::get_unknown_id_list(archive_dir_id_list)
    elsif prms.param_file == "twt未登録twt id"
      #artists = artists.select {|x| x.twtid != ""}
      twt_id_list = Twitter.all_twt_id_list
      #puts "twt_id_list = #{twt_id_list.size} // #{twt_id_list[0..3]}"
      #puts "artists = #{artists.size}"
      artists = artists.select {|x| x.twtid.presence and twt_id_list.include?(x.twtid) == false}
      #artists = artists.select {|x| x.twtid.presence}
    elsif prms.param_file == "未登録pxv user id"
      @unknown_id_list = Twitter::get_unregisterd_pxv_user_id_list()
    elsif prms.param_file == "DB未登録pxv user id local dir"
      @unknown_id_list = Artist::get_unregisterd_pxv_user_id_list_from_local()
    elsif prms.param_file == ArtistsController::MethodEnum::REGIST_UL_DIFF
      artists = artists.select {|x| (x.created_at.to_date - x.last_ul_datetime.to_date).to_i > 365}
    elsif prms.param_file == ArtistsController::MethodEnum::REGIST_UL_DIFF_NEAR
      artists = artists.select {|x| (x.created_at.to_date - x.earliest_ul_date.to_date).to_i < 30}
    end

    artists = index_select(artists, prms)
    puts %!artists.size=#{artists.size}!
    artists = index_sort(artists, prms)
    if artists.size > 5
      @artists_group = index_group_by(artists, prms)
    else
      @artists_group[""] = artists
    end
  end

  # GET /artists/1 or /artists/1.json
  def show
    if params[:access_dt_update].presence and params[:access_dt_update] == "no"
      @last_access_datetime = @artist.last_access_datetime
    else
      @last_access_datetime = @artist.last_access_datetime
      @artist.update(last_access_datetime: Time.now)
    end

    if params[:mode] != nil
      @show_mode = params[:mode]
    end

    if params[:number_of_display].presence
      @number_of_display = params[:number_of_display].to_i
    else
      @number_of_display = 4
    end

    @path_list = Pxv::get_pathlist(@artist[:pxvid])
    if @show_mode == "twt_pic_list"
      @twt_pic_path_list = Artist.get_twt_pathlist(@artist[:twtid])
    end
  end

  def stats
    @stats = {}

    col = [:rating, :r18, :status, :drawing_method, :warning]
    col.each do |c|
      key = "twt(ai):" + c.to_s
      #@stats[key] = Twitter.select {|x| x.drawing_method == "AI"}.group(c).count
      #t = Twitter.all
      #t = Twitter.select {|x| x.drawing_method == "AI"}
      t = Twitter.where(drawing_method: 'AI')
      #@stats[key] = t.group(c).having("drawing_method = 'AI'").count
      @stats[key] = t.group(c).count
      @stats[key].delete(nil)
      @stats[key].delete("")
      @stats[key].delete(0)
    end

    col = [:rating, :r18, :status]
    col.each do |c|
      key = "pxv:" + c.to_s
      @stats[key] = Artist.all.group(c).count
      @stats[key].delete(nil)
      @stats[key].delete("")
      @stats[key].delete(0)
    end
  end

  # GET /artists/pxv/1
  def pxv_show
    @pxvid = params[:pxvid]

    @pxv_pic_list = Pxv::get_pathlist(@pxvid)
  end


  # GET /artists/twt
  def twt_index
    
    hide_day = params[:hide_day]
    if hide_day =~ /(\d+)/
      @hide_day = $1.to_i
    else
      @hide_day = 5
    end

    force_disp_day = params[:force_disp_day]
    if force_disp_day =~ /(\d+)/
      @force_disp_day = $1.to_i
    else
      @force_disp_day = 0
    end

    pred = params[:pred]
    if pred =~ /(\d+)/
      @pred = $1.to_i
    else
      @pred = 0
    end

    target = params[:target]
    if target.presence
      @target = target.split(",")
    else
      @target = []
    end
    puts "target='#{@target}'"

    filename = params[:filename]
    if filename == nil
      dir = params[:dir]
      if dir == nil
        dir = ""
      elsif dir == "update"
        Twt::db_update_by_newdir()
        dir = "new"
      end
      @twt_urls = Twt::twt_user_list(dir)
    elsif filename == ""
      @url_file_list = UrlTxtReader::txt_file_list()
      @twt_urls = []
    else
      case filename
      when "all"
        path = []
      when "latest"
        path = UrlTxtReader::get_latest_txt
      when /latest\s+(\d+)/
        path = UrlTxtReader::get_latest_txt($1.to_i)
      else
        path = ["public/#{filename}.txt"]
      end
      puts "path='#{path}'"
      if @target.include?("twt")
        db_chek = true
      else
        db_chek = false
      end
      pxv_id_list, @twt_urls, @misc_urls = UrlTxtReader::get_url_list(path, db_chek)
      known_pxv_user_id_list, unknown_pxv_user_id_list = Artist::pxv_user_id_classify(pxv_id_list)
      if @target.include?("known_pxv")
        @known_pxv_user_id_list = known_pxv_user_id_list
      end
      if @target.include?("unknown_pxv")
        @unknown_pxv_user_id_list = unknown_pxv_user_id_list
      end
    end
  end

  # GET /artists/twt/hoge
  def twt_show
    @twtid = params[:twtid]

    @twt_pic_path_list = Artist.get_twt_pathlist(@twtid)
  end

  # GET /artists/nje
  def nje_index
    method = params[:method]
    if method == "update"
      Nje::update_db_by_fs()
    end
    @nje_artist_list = Nje::nje_user_list
  end

  # GET /artists/nje/1
  def nje_show
    njeid = params[:njeid]
    @nje_artist = Nje::nje_user(njeid)
  end

  # GET /artists/new
  def new
    @artist = Artist.new
  end

  # GET /artists/1/edit
  def edit
  end

  # GET ???PATCH /artists/1/edit_xxx
  def edit_no_update
    method = params["method"]
    if method == "no_update"
      update_params = {status: "長期更新なし"}
    elsif method == "priority_minus_one"
      priority = @artist.priority - 1
      update_params = {priority: priority}
    elsif method == "priority_minus_ten"
      priority = @artist.priority - 10
      update_params = {priority: priority}
    elsif method == "priority_plus_ten:R18"
      priority = @artist.priority + 10
      r18 = "R18"
      update_params = {priority: priority, r18: r18}
    else
      puts "unknown method"
      update_params = nil
    end
    respond_to do |format|
      if @artist.update(update_params)
        format.html { redirect_to artist_url(@artist, access_dt_update: "no"), notice: "Artist was successfully updated." }
        format.json { render :show, status: :ok, location: @artist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /artists or /artists.json
  def create
    @artist = Artist.new(artist_params)

    respond_to do |format|
      if @artist.save
        format.html { redirect_to artist_url(@artist), notice: "Artist was successfully created." }
        format.json { render :show, status: :created, location: @artist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artists/1 or /artists/1.json
  def update
    if params[:artist][:twtid] =~ /twitter\.com%2F(.*)$/
      params[:artist][:twtid] = $1
      puts %![LOG] twtid=#{params["artist"]["twtid"]}!
    end
    respond_to do |format|
      if @artist.update(artist_params)
        format.html { redirect_to artist_url(@artist), notice: "Artist was successfully updated." }
        format.json { render :show, status: :ok, location: @artist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /artists/1 or /artists/1.json
  def destroy
    @artist.destroy

    respond_to do |format|
      format.html { redirect_to artists_url, notice: "Artist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_artist
      @artist = Artist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def artist_params
      params.require(:artist).permit(
        :pxvname, :pxvid, :filenum, :last_dl_datetime, :last_ul_datetime,
        :last_access_datetime, :priority, :status, :comment, :twtid, :njeid,
        :r18, :remarks, :rating, :furigana, :altname, :oldname, :chara, :work,
        :warnings, :feature, :twt_check, :earliest_ul_date, :circle_name,
        :fetish, :pxv_fav_artwork_id, :web_url, :append_info,
        :twt_checked_date, :nje_checked_date, :show_count, :reverse_status
      )
    end

    # select
    def index_select(artists, prms)

      if prms.point > 0
        artists = artists.select {|x| x.point >= prms.point}
      elsif prms.point < 0
        artists = artists.select {|x| x.point < 0}
      end

      if prms.prediction > 0
        artists = artists.select {
          |x| x.prediction_up_cnt(true) >= prms.prediction or
          (prms.force_disp_day != 0 and !x.last_access_datetime_p(prms.force_disp_day))
        }
      elsif prms.prediction < 0
        artists = artists.select {|x| x.prediction_up_cnt(true) <= -(prms.prediction)}
      end
      
      if prms.rating < 0
      elsif prms.rating == 0
        artists = artists.select {|x| x.rating == 0}
      else
        #artists = artists.select {|x| x.rating == 0 or x.rating >= prms.rating}
        artists = artists.select {|x| x.rating >= prms.rating}
      end

      if prms.twt
        artists = artists.select {|x| x[:twtid] != "" and x[:twtid] != "-"}
        @twt = true
      end

      if prms.twt_chk
        artists = artists.select {|x| x[:twt_check] == prms.twt_chk}
      end
  
      if prms.feat_3d
        artists = artists.select {|x| x[:feature] == "3D"}
      end

      if prms.ai
        artists = artists.select {|x| x[:feature] == "AI"}
      end

      if prms.exclude_ai
        artists = artists.select {|x| x[:feature] != "AI"}
      end

      if prms.nje
        artists = artists.select {|x| x.nje_p}
        puts %!nje="#{prms.nje}"!
      end

      if prms.status == "(全て)"
      elsif prms.status == "「長期更新なし」を除外"
        excl_list = [
          "長期更新なし",
          "半年以上更新なし",
          "退会",
          "停止",
          "作品ゼロ",
        ]
        artists = artists.select {|x| excl_list.include?(x.status) == false}
      elsif prms.status == "長期更新なし"
        excl_list = [
          "長期更新なし",
          "半年以上更新なし",
          "3ヶ月以上更新なし",
          "1ヶ月以上更新なし",
          "作品ゼロ",
        ]
        artists = artists.select {|x| excl_list.include?(x.status)}
      else
        artists = artists.select {|x| x.status == prms.status}
        puts %!status="#{prms.status}"!
      end

      if prms.reverse_status == ""
      elsif prms.reverse_status == "「さかのぼり済」を除く"
        excl_list = [
          "さかのぼり済",
        ]
        artists = artists.select {|x| excl_list.include?(x.reverse_status) == false}
      else
        artists = artists.select {|x| x.reverse_status == prms.reverse_status}
        puts %!reverse_status="#{prms.reverse_status}"!
      end

      if prms.r18 and prms.r18 != ""
        artists = artists.select {|x| x[:r18] == prms.r18}
        puts %!r18="#{prms.r18}"!
      end

      if prms.amount_gt != 0 and prms.amount_lt != 0
        artists = artists.select {|x| prms.amount_gt < x[:filenum] and x[:filenum] <= prms.amount_lt}
      elsif prms.amount_gt != 0
        artists = artists.select {|x| prms.amount_gt < x[:filenum]}
      elsif prms.amount_lt != 0
        artists = artists.select {|x| x[:filenum] <= prms.amount_lt}
      else
      end

      if prms.recent_filenum != 0
        artists = artists.select {|x| x[:recent_filenum] >= prms.recent_filenum}
      end
  
      if prms.year_since != 0 and  prms.year_until != 0
        artists = artists.select {|x| y = x[:last_ul_datetime].strftime("%Y").to_i; y >= prms.year_since and y <= prms.year_until}
      end
  
      if prms.last_access_datetime > 0
        artists = artists.select {|x| !x.last_access_datetime_p(prms.last_access_datetime)}
      elsif prms.last_access_datetime < 0
        # 負の値の場合は最近アクセスしたものを選択
        artists = artists.select {|x| x.last_access_datetime_p(prms.last_access_datetime)}
      end
      artists
    end

    # sort
    def index_sort(artists, prms)
      case prms.sort_by
      when "access_date_X_last_ul_datetime"
        artists = artists.sort_by {|x| [x[:last_access_datetime], x[:last_ul_datetime]]}
      when "access_date_X_recent_filenum"
        artists = artists.sort_by {|x| [x[:last_access_datetime], -x[:recent_filenum], -x[:filenum]]}
      when "access_date_X_recent_filenum_X_ul"
        artists = artists.sort_by {|x| [-x.get_date_delta(x[:last_access_datetime]), -x.priority, -x.point, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      when "access_date_X_pxvname_X_recent_filenum"
        artists = artists.sort_by {|x| [x[:last_access_datetime], x[:pxvname].downcase, -x[:recent_filenum], -x[:filenum]]}
      when "pxvname"
        artists = artists.sort_by {|x| [x.pxvname]}
      when "priority"
        artists = artists.sort_by {|x| [-x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      when "point"
        artists = artists.sort_by {|x| [-x.point, x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      when "-point"
        artists = artists.sort_by {|x| [x.point, -x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      when "予測▽"
        artists = artists.sort_by {|x| [-x.prediction_up_cnt(true), x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      when "予測△"
        artists = artists.sort_by {|x| [x.prediction_up_cnt(true), x[:last_ul_datetime], x[:recent_filenum], -x[:filenum]]}
      when "last_ul_date"
        artists = artists.sort_by {|x| [x.last_ul_datetime]}
      when "twtid"
        artists = artists.sort_by {|x| [x.twtid]}
      when "filenum"
        artists = artists.sort_by {|x| [-x.filenum]}
      when "recent_filenum"
        artists = artists.sort_by {|x| [-x.recent_filenum]}
      when "id"
        artists = artists.sort_by {|x| [-x.id]}
      when "pxv-user-id"
        artists = artists.sort_by {|x| [-x.pxvid]}
      else
        # デフォルト？
        artists = artists.sort_by {|x| [-x.point, -x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      end
      artists
    end

    def filenum_g(filenum)
      f = 0
      if filenum >= 300
        f = filenum / 100 * 100
      elsif filenum >= 100
         f = filenum / 50 * 50
      elsif filenum >= 50
        f = filenum / 25 * 25
      else
        f = filenum / 10 * 10
      end
      f
    end

    # group_by
    def index_group_by(artists, prms)
      artists_group = {}
      case prms.group_by
      when "last_ul_datetime"
        artists_group = artists.group_by {|x| x[:last_ul_datetime].strftime("%Y")}.sort.reverse.to_h
      when "last_ul_datetime_X_filenum"
        artists_group = artists.group_by {|x| x.judge_number(x[:filenum]) + ":" + x[:last_ul_datetime].strftime("%Y")}.sort.reverse.to_h
      when "last_ul_datetime_ym"
        artists_group = artists.group_by {|x| x[:last_ul_datetime].strftime("%Y-%m")}.sort.reverse.to_h
      when "last_ul_datetime_y"
        artists_group = artists.group_by {|x| x[:last_ul_datetime].strftime("%Y")}.sort.reverse.to_h
      when "filenum"
        artists_group = artists.group_by {|x| filenum_g(x.filenum)}.sort.reverse.to_h
      when "recent_filenum"
        artists_group = artists.group_by {|x| (x.recent_filenum / 10 * 10)}.sort.reverse.to_h
      when "pxvname_fl"
        artists_group = artists.group_by {|x| x.select_group(x[:pxvname])}.sort.to_h
      when "pxvname"
        artists_group = artists.group_by {|x| x.pxvname}.sort.to_h
      when "status"
        artists_group = artists.group_by {|x| x.status}.sort.to_h
      when "r18"
        artists_group = artists.group_by {|x| x.r18}.sort.to_h
      when "priority"
        artists_group = artists.group_by {|x| -x.priority}.sort.to_h
      when "予測"
        artists_group = artists.group_by {|x| x.prediction_up_cnt(true) / 10 * 10 }.sort.to_h
      when "rating"
        artists_group = artists.group_by {|x| -x.rating}.sort.to_h
      when "評価+年齢制限"
        artists_group = artists.group_by {|x| [-x.rating, x.r18]}.sort.to_h
      when "さかのぼり"
        artists_group = artists.group_by {|x| [
            if x.reverse_status
              x.reverse_status
            else
              ""
            end
          ]
        }.sort.to_h
      when "none"
        artists_group["none"] = artists
      else
        #artists_group = set_artist_group_pxv(artists)
        artists_group["all"] = artists
      end
      artists_group
    end

    def set_artist_group_pxv(artists_select)
      artists_group = {}
      
      artists_group_by_year = artists_select.group_by {|x| x[:last_ul_datetime].strftime("%Y")}.sort.reverse.to_h

      artists_group_by_year.each do |key, artists|
        if artists.count > 300
          artists_group_by_yymm = artists.group_by {|x| x[:last_ul_datetime].strftime("%Y-%m")}.sort.reverse.to_h
          artists_group_by_yymm.each do |tmp_key, tmp_artists|
            if tmp_artists.count > 100
              tmp2 = tmp_artists.group_by {|x| x.judge_number(x[:filenum])}.sort.reverse.to_h
              tmp2.each do |tmp2_key, tmp2_artists|
                artists_group[tmp_key + ":" + tmp2_key.to_s] = tmp2_artists#.sort_by {|x| [x[:last_access_datetime], -x[:recent_filenum]]}
              end
            else
              artists_group[tmp_key] = tmp_artists.sort_by {|x| [x[:last_access_datetime], -x[:filenum]]}
            end
          end
        else
          artists_group[key] = artists.sort_by {|x| [x[:last_access_datetime], -x[:filenum]]}
        end
      end
      #artists_group["all"] = artists_select.sort_by {|x| [-x.priority, x[:last_access_datetime]]}

      artists_group
    end

end
