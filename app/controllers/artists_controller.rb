
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
    :last_ul_datetime,
    :created_at,
    :step,
    :num_of_times,
    :r18,
    :point,
    :prediction,
    :force_disp_day,
    :rating,
    :rating_upper_limit,
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
    @rating_upper_limit = params[:rating_upper_limit]
    @twt_chk = params[:twt_chk]
    @created_at = params[:created_at]
    
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

    if @rating_upper_limit.presence
      @rating_upper_limit = @rating_upper_limit.to_i
    else
      @rating_upper_limit = -1
    end
    puts "rating_upper_limit=#{@rating_upper_limit}"

    if @status == nil
      @status = ""
    end
    puts %!status="#{@status}"!
    
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
    puts "amount=<gt:#{@amount_gt}/lt:#{@amount_lt}>"

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

    last_ul_datetime = params[:last_ul_datetime]
    if last_ul_datetime == nil or last_ul_datetime == 0
      @last_ul_datetime = 0
    else
      @last_ul_datetime = last_ul_datetime.to_i
    end
    puts "last_ul_datetime=#{@last_ul_datetime}"

    if @created_at.presence
      @created_at = @created_at.to_i
    else
      @created_at = nil
    end
    puts %!created_at="#{@created_at}"!

    if params[:step].presence
      @step = params[:step].to_i
    else
      @step = 3
    end
    puts %!step="#{@step}"!

    if params[:num_of_times].presence
      @num_of_times = params[:num_of_times].to_i
    else
      @num_of_times = 4
    end
    puts %!num_of_times="#{@num_of_times}"!

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
    SAME_FILENUM = '全ファイル数と最近のファイル数が同じレコード'
    REGIST_UL_DIFF = '新規登録日と最新投稿日の日数差'
    ACCESS_UL_DIFF_FAR = 'アクセス日と最新投稿日の日数差大きい'
    REGIST_UL_DIFF_NEAR = '新規登録日と昔の投稿日の日数差近い'
    TWTID_CASE_DIFF = 'twt screen name大文字・小文字違い'
    TABLE_UPDATE_NEW_USER = 'PXV DB更新（ファイルシステム）'
    UPDATE_RECORD = 'pxvレコード更新(PXV id 指定)'
    SEARCH = '検索'
    NAME_TEST = '名前テスト'
    DB_UNREGISTERED_USER = 'ファイル0件未登録'
    TWT_DB_UNREGISTERED_TWT_ID = 'twt未登録twt id' #PXV DBに登録されているがTWT DBに登録がないTWT ID
    TWT_DB_UNREGISTERED_PXV_USER_ID = '未登録pxv user id' # TWTテーブルに登録されているがPXVテーブルに登録されていないPXV ID
    TWT_DB_UNREGISTERED_PXV_USER_ID_LOCAL_DIR = 'DB未登録pxv user id local dir'
    UNASSOCIATED_PXV_USER = '未紐づけPXVユーザー' #TWT ID未設定PXV（TWT DBにはPXV ID登録済み）
    UNASSOCIATED_TWT_ACNT = '未紐づけTWTアカウント' #PXV DBにはTWT IDが登録されているがTWT DBにはPXV IDが登録されていない
    TWT_DUP_TWTID = 'same_twtid'
    ALL_IN_ONE = 'all in one'
    ALL_IN_1 = 'all in 1'
    URL_LIST = 'urllist'
    URL_LIST_PXV_ONLY_LATEST = "urllist-pxv-only(latest)"
    DUP_USER_ID_CHK = '重複ユーザーIDチェック'
  end

  module ApiEnum
    ARTIST_INFO = 0
    UPDATE_ACCESS_DATE = 1
    ARTIST_RECENT_FILENUM = 2
  end

  module FileTarget
    TWT_UNKNOWN_ONLY = "unknown_twt_only"
    PXV_UNKNOWN_ONLY = "unknown_pxv_only"
    TWT_KNOWN_ONLY = "twt,twt既知"
    TWT_EXPERIMENT = "twt_experiment"
    PXV_EXPERIMENT = "pxv_experiment"
    PXV_ARTWORK_LIST = "pxv_artwork_list"
  end

  module Status
    DELETED = "退会"
    SUSPEND = "停止"

    LONG_TERM_NO_UPDATS  = "長期更新なし"
    SIX_MONTH_NO_UPDATS  = "半年以上更新なし"
    NO_UPDATES_3M        = "3ヶ月以上更新なし"
    NO_UPDATES_1M        = "1ヶ月以上更新なし"

    ACCOUNT_MIGRATION    = "別アカウントに移行"
    
    NO_ARTWORKS          = "作品ゼロ"
    M_ARTWORKS_DISAPPEAR = "ほぼ消えた"
    F_ARTWORKS_DISAPPEAR = "一部消えた"
    
=begin
        ["取得途中", "取得途中"], 
        ["最新から取得し直し中", "最新から取得し直し中"], 
        ["最新追っかけ中", "最新追っかけ中"], 
        ["彼岸", "彼岸"],
        ["更新頻度低", "更新頻度低"],
=end

    ADJUSTMENT = "(整理対象)"
  end

  module DIR_TYPE
    UPDATE = "update"
    REG_DUP_FILES = "register_dup_files"
    NEW_LIST = "new-list"
    ARCHIVE_CHECK = "archive-check"
    SMARTPHONE = "SMARTPHONE"
    REG_FILESIZE = "ファイルサイズ登録"
  end

  module ShowMode
    SHOW_NORAML = "normal"
    SHOW_VIEWER = "viewer"
    SHOW_LIST_VIEW = "list_view"
    INTERVAL_CHECK = "interval_chk"
    STAT = "stat"
    TWT_PIC_LIST = "twt_pic_list"
  end

  module SORT_TYPE
    SORT_RATING = "RATING"
    SORT_RATING_O2N = "RATING/ACCESS旧→新"
    SORT_ACCESS_OLD_TO_NEW = "ACCESS旧→新"
    SORT_ACCESS_NEW_TO_OLD = "ACCESS新→旧"
    SORT_PXV_USER_ID_ASC = "pxv-user-id(古い順)"
  end

  module GROUP_TYPE
    GROUP_ACCESS_OLD_TO_NEW = "ACCESS旧→新"
    GROUP_FEAT_STAT_RAT = "feature/status/rating"
    GROUP_STAT = "status"
    GROUP_STAT_RAT = "status/rating"
    GROUP_STAT_RAT_R18 = "status/rating/r18"
    GROUP_RATING = "rating"
  end

  module GRP_SORT
      GRP_SORT_PRED = "予測順"
      GRP_SORT_ACCESS = "アクセス日順"
      GRP_SORT_UL = "投稿日順"
      GRP_SORT_NO_UPDATE = "更新なし"
      GRP_SORT_RATE = "評価順"
      GRP_SORT_REGISTERED = "登録日順"

      GRP_SORT_DEL = "削除"
  end

  def api_hoge
    puts %!api=#{params[:api]}!
    case params[:api].to_i
      when ApiEnum::ARTIST_INFO
        puts %!pxv!
        @artist = Artist.find(params[:id])
        #respond_to do |format|
        #  format.json {render json: @artist}
        #end
        render json: @artist
      when ApiEnum::UPDATE_ACCESS_DATE
        puts %!update ad!
        @artist.update(last_access_datetime: Time.now)
      when ApiEnum::ARTIST_RECENT_FILENUM
        puts %!recent filenum!
        xxx = {xxx: 333}
        render json: xxx
      else
        puts "else"
      end
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

    #case params[:file]
    case prms.param_file
    when ArtistsController::MethodEnum::DUP_USER_ID_CHK
      artists = Artist.all
      dup_ids = UrlTxtReader::same_pxv_user_id(artists)
      artists = artists.select {|x| dup_ids.include?(x[:pxvid])}
      @artists_group[""] = artists
      return
    when ArtistsController::MethodEnum::NAME_TEST
      artists = Artist.all
      Pxv::name_test()
      #return
    when ArtistsController::MethodEnum::SEARCH
      #TODO: SQLいんじぇくしょんたいさく？
      artists = Artist.looks(params[:target_col], params[:search_word], params[:match_method])
      @artists_group = index_group_by(artists, prms)
      return
    when MethodEnum::ALL_IN_1
      artists = Artist.all
      artists = index_select(artists, prms, true)
      artists = artists.select {|x| x.select_cond_aio}

      artists = index_sort(artists, prms)

      @artists_group = index_group_by(artists, prms)
      @artists_total_count = @artists_group.sum {|k,v| v.count}
      return
    when MethodEnum::ALL_IN_ONE
      if params[:aio].presence
        keys = params[:aio].split("|")

        target_hash = {}
        keys.each do |key|
          target_hash[key] = true
        end
      else
      end

      group_list = []
      interval = prms.last_access_datetime

      prms.num_of_times.times do |i|
        interval_wk = interval * (i + 1)
        #puts %!#{prms.rating}/#{prms.rating_upper_limit}!
        group_list << index_all_in_one(prms, %!#{prms.rating}:!, interval_wk, target_hash)
        #puts "#{i}/#{interval}(#{interval_wk})/#{prms.last_access_datetime}"

        ### 
        #prms.rating_upper_limit = prms.rating
        
        #prms.rating = prms.rating_upper_limit - prms.step
        prms.rating -= prms.step

        #puts "prms.last_access_datetime=#{prms.last_access_datetime}"
      end

      if false
        # 
        artists = Artist.all
        artists = artists.select {|x| x.rating == nil or x.rating == 0}
        artists = artists.select {|x| x.filenum == x.recent_filenum}
        artists = index_select_status_exclude(artists)
        artists = artists.sort_by {|x| [-x.prediction_up_cnt(true)]}
        group = {}
        group["ファイル数同じ"] = artists
        group_list << group
      end

      # 未設定gr
      if true
        artists = Artist.all
        artists = artists.select {|x| x.rating == nil or x.rating == 0}
        d_thre = 365
        artists = artists.select {|x| x.filenum != x.recent_filenum}
        artists = artists.select {|x| x.last_access_datetime_num < d_thre}
        artists = artists.sort_by {|x| [-x.prediction_up_cnt(true)]}
        group = {}
        group["未設定 予測順 #{d_thre}"] = artists
        group_list << group
      end

      if true
        artists = Artist.all
        artists = artists.select {|x| x.rating == nil or x.rating == 0}
        d_thre = 90
        artists = artists.select {|x| x.last_access_datetime_num < d_thre}
        #artists = artists.sort_by {|x| [-x.prediction_up_cnt(true), x.last_access_datetime]}
        artists = artists.sort_by {|x| [-x.prediction_up_cnt(true)]}
        group = {}
        group["未設定 予測順 #{d_thre}"] = artists
        group_list << group
      end
        

      if true
        artists = Artist.all
        artists = artists.select {|x| x.rating == nil or x.rating == 0}
        #artists = artists.select {|x| x.last_access_datetime_num > 90}
        artists = artists.select {|x| x.days_elapsed_since_created < 90}
        
        artists = artists.sort_by {|x| [-x.filenum]}
        group = {}
        group["未設定 総ファイル数順 最近?"] = artists
        group_list << group
      end

      if true
        artists = Artist.all
        artists = artists.select {|x| x.rating == nil or x.rating == 0}
        artists = artists.select {|x| x.last_access_datetime_num > 90}
        artists = artists.sort_by {|x| [-x.filenum]}
        group = {}
        group["未設定 総ファイル数順 全期間"] = artists
        group_list << group
      end

      # 
      if false
        artists = Artist.all
        if false
          artists = artists.select {|x| x.days_elapsed_since_created < 60}
          artists = artists.select {|x| x.last_access_datetime_num > 30 and x.last_access_datetime_num < 360}
          artists = artists.select {|x| x.last_ul_datetime != nil}
          #artists = artists.sort_by {|x| [-((x.created_at.to_date - x.last_ul_datetime.to_date).to_i)]}
          artists = artists.sort_by {|x| [-(x.days_elapsed(x.last_ul_datetime, x.created_at))]}
          artists = index_select_status_exclude(artists)
        else
          artists = artists.select {|x| x.last_access_datetime_num > 30 and x.last_access_datetime_num < 90}
          artists = artists.select {|x| x.last_ul_datetime != nil}
          artists = artists.select {|x| x.days_elapsed(x.last_ul_datetime, x.created_at) > 180}
          artists = artists.sort_by {|x| x.last_access_datetime}
          artists = index_select_status_exclude(artists)
        end
        group = {}
        group["レコード登録日と最新公開日が離れている"] = artists
        group_list << group
      end
      
      @artists_group = group_list[0].merge(*group_list)
      return
    when MethodEnum::TABLE_UPDATE_NEW_USER
      Pxv::db_update_by_newdir()
      #artists = Artist.select {|x| (x.created_at.to_date - Date.today.to_date).to_i == 0}
      artists = Artist.select {|x| x.days_elapsed_since_created == 0}
      @artists_group[""] = artists
      return
    when MethodEnum::UPDATE_RECORD
      #Pxv::update_record_by_dir()
      Pxv::db_update_by_newdir(false)
      #artists = Artist.select {|x| (x.created_at.to_date - Date.today.to_date).to_i == 0}
      artists = Artist.select {|x| x.days_elapsed_since_created == 0}
      @artists_group[""] = artists
      return
    else
      artists = Artist.all
    end

    if prms.param_file == MethodEnum::URL_LIST or
      prms.param_file == "urllist-pxv-only" or
      prms.param_file == MethodEnum::URL_LIST_PXV_ONLY_LATEST or #"urllist-pxv-only(latest)" or
      prms.param_file == "urllist-unknown-only" or
      prms.param_file == "urllist-twt-only" or
      prms.param_file == "urllist-twt-only(latest)"
      if prms.url_list_only
        @misc_urls = Artist.get_url_list_from_all_txt
        return
      else
        datestr = prms.filename
        puts %!datestr="#{datestr}"!
        if prms.param_file == "urllist-twt-only(latest)" or prms.param_file == "urllist-pxv-only(latest)"
          path = UrlTxtReader::get_latest_txt
        elsif datestr == ""
          path = ""
        elsif datestr == "latest"
          path = UrlTxtReader::get_latest_txt
        elsif datestr =~ /^(\d{2})$/
          # yy
          path = UrlTxtReader::txt_file_list($1 + "\\d{4}")
        elsif datestr =~ /^(\d{4})$/
          # yymm
          path = UrlTxtReader::txt_file_list($1 + "\\d+")
        elsif datestr =~ /^\d+$/
          #path = ["public/get illust url_#{datestr}.txt"]
          path = [UrlTxtReader::URLLIST_DIR_PATH + "/get illust url_#{datestr}.txt"]
        else
          #path = ["public/#{datestr}.txt"]
          path = [UrlTxtReader::URLLIST_DIR_PATH + "/#{datestr}.txt"]
        end
        puts %!path="#{path}"!
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
          #puts %!artists.size=#{artists.size}!
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
        twt = Twitter.find_by_twtid_ignore_case(twtid)
        
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
        twt = Twitter.find_by_twtid_ignore_case(twtid)
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
    elsif prms.param_file == ArtistsController::MethodEnum::TWT_DUP_TWTID #"same_twtid"
      artists = artists.select {|x| x.twtid != ""}
      dup_twtids = UrlTxtReader::same_twtid(artists)
      puts "dup id=#{dup_twtids}"
      artists = artists.select {|x| dup_twtids.include?(x[:twtid])}
    elsif prms.param_file == ArtistsController::MethodEnum::DB_UNREGISTERED_USER
      archive_dir_id_list = Pxv::archive_dir_id_list()
      @unknown_id_list = Artist::get_unknown_id_list(archive_dir_id_list)
    elsif prms.param_file == ArtistsController::MethodEnum::TWT_DB_UNREGISTERED_TWT_ID
      #artists = artists.select {|x| x.twtid != ""}
      twt_id_list = Twitter.all_twt_id_list
      #puts "twt_id_list = #{twt_id_list.size} // #{twt_id_list[0..3]}"
      #puts "artists = #{artists.size}"
      artists = artists.select {|x| x.twtid.presence and twt_id_list.include?(x.twtid) == false}
      #artists = artists.select {|x| x.twtid.presence}
    elsif prms.param_file == ArtistsController::MethodEnum::TWT_DB_UNREGISTERED_PXV_USER_ID#"未登録pxv user id"
      @unknown_id_list = Twitter::get_unregisterd_pxv_user_id_list()
    elsif prms.param_file == ArtistsController::MethodEnum::TWT_DB_UNREGISTERED_PXV_USER_ID_LOCAL_DIR#"DB未登録pxv user id local dir"
      @unknown_id_list = Artist::get_unregisterd_pxv_user_id_list_from_local()
    elsif prms.param_file == ArtistsController::MethodEnum::UNASSOCIATED_PXV_USER
      unassociated_pxv_uids = Twitter::unassociated_pxv_uids()
      artists = artists.select {|x| unassociated_pxv_uids.include?(x[:pxvid])}
    elsif prms.param_file == ArtistsController::MethodEnum::UNASSOCIATED_TWT_ACNT
      unassociated_twt_screen_names = Twitter::unassociated_twt_screen_names()
      artists = artists.select {|x| unassociated_twt_screen_names.include?(x.twtid)}
      #@unassociated_twt_screen_names = unassociated_twt_screen_names
    elsif prms.param_file == ArtistsController::MethodEnum::REGIST_UL_DIFF
      #artists = artists.select {|x| (x.created_at.to_date - x.last_ul_datetime.to_date).to_i > 365}
      artists = artists.select {|x| x.days_ul_to_created > 365}
    elsif prms.param_file == ArtistsController::MethodEnum::ACCESS_UL_DIFF_FAR
      artists = artists.select {|x| (x.last_access_datetime.to_date - x.last_ul_datetime.to_date).to_i > 60}
    elsif prms.param_file == ArtistsController::MethodEnum::SAME_FILENUM
      artists = artists.select {|x| x.filenum == x.recent_filenum}
    elsif prms.param_file == ArtistsController::MethodEnum::REGIST_UL_DIFF_NEAR
      artists = artists.select {|x| (x.created_at.to_date - x.earliest_ul_date.to_date).to_i < 30}
    elsif prms.param_file == ArtistsController::MethodEnum::TWTID_CASE_DIFF
      hit_list = []
      twt_id_list = Twitter.all_twt_id_list
      hash = twt_id_list.to_h {|x| [x.upcase, x]}

      pxv_twtid_list = Artist.all.map {|x| x.twtid}
      pxv_twtid_list.each do |twtid|
        key = twtid.upcase
        if hash.has_key? (key)
          val = hash[key]
          if val != twtid
            hit_list << twtid
            puts %!key="#{key}"/val="#{val}"!
          end
        end
      end
      artists = artists.select {|x| x.twtid.presence and hit_list.include?(x.twtid) }
    end

    artists = index_select(artists, prms)
    #puts %!artists.size=#{artists.size}!
    artists = index_sort(artists, prms)

    @artists_total_count = artists.size
    artists = artists.first(prms.display_number)

    if artists.size > 5
      @artists_group = index_group_by(artists, prms)
    else
      @artists_group["すくないのでひとまとめ"] = artists
    end
  end

  # GET /artists/1 or /artists/1.json
  def show
    @last_access_datetime = @artist.last_access_datetime
    if @artist.last_access_datetime.presence and Util::get_date_delta(@artist.last_access_datetime) == 0
      STDERR.puts %!更新不要:"#{@artist.last_access_datetime}"!
    else
      @artist.update(last_access_datetime: Time.now)
    end

    @show_mode = params[:mode]

    if params[:number_of_display].presence
      @number_of_display = params[:number_of_display].to_i
    else
      @number_of_display = 4
    end

    thumbnail = true
    if params[:thumbnail] == "yes"
    elsif @artist.filenum > 1000
      thumbnail = false
    end
    puts %!thubmnail=#{thumbnail}/#{params[:thumbnail]}!

    if thumbnail
      archive_dir = true
      #@path_list = Pxv::get_pathlist(@artist[:pxvid])
    else
      archive_dir = false
      #@path_list = []
    end
    @path_list = Pxv::get_pathlist(@artist[:pxvid], archive_dir)

    if @show_mode == ArtistsController::ShowMode::TWT_PIC_LIST #"twt_pic_list"
      @twt_pic_path_list = Twt::get_pic_filelist(@artist[:twtid])
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
    
    @hide_day = get_int(params[:hide_day], 5)
    STDERR.puts %![twt_index] hide_day="#{@hide_day}"!

    @rating = get_int(params[:rating], 0)
    STDERR.puts %![twt_index] rating="#{@rating}"!

    @force_disp_day = get_int(params[:force_disp_day], 0)
    STDERR.puts %![twt_index] force_disp_day="#{@force_disp_day}"!

    @pred = get_int(params[:pred], 0)
    STDERR.puts %![twt_index] pred="#{@pred}"!

    target = params[:target]
    if target.presence
      @target = target.split(",").map {|x| x.strip}
    else
      @target = []
    end
    STDERR.puts "[twt_index] target='#{@target}'"

    filename = params[:filename]
    if filename == nil
      dir = params[:dir]
      case dir
      when nil
        dir = ""
        @known_twt_url_list = Twt::twt_user_list(dir)
        puts %!@known_twt_url_list.size=#{@known_twt_url_list.size}!
      when DIR_TYPE::UPDATE
        Twt::db_update_by_newdir()
      when DIR_TYPE::REG_DUP_FILES
        Twt::db_update_dup_files_current_all()
      when DIR_TYPE::NEW_LIST
        @twt_user_infos = Twt::twt_user_infos()
      when DIR_TYPE::ARCHIVE_CHECK
        Twt::archive_check()
      when DIR_TYPE::SMARTPHONE
        @sp_dirs = Twt::sp_dirs()
      when DIR_TYPE::REG_FILESIZE
        @sp_dirs = Twt::reg_filesize()
      else
      end
    elsif filename == ""
      @url_file_list = UrlTxtReader::txt_file_list()
      @known_twt_url_list = []
    else
      path = UrlTxtReader::get_path(filename)

      if @target.size == 1 and @target[0] != "known_pxv"#適当すぎる。。。
        pxvid_list2 = []
        if @target[0] == ArtistsController::FileTarget::PXV_UNKNOWN_ONLY
          @unknown_pxv_user_id_list = UrlTxtReader::get_unknown_pxv_id_list(path)
        elsif @target[0] == ArtistsController::FileTarget::TWT_UNKNOWN_ONLY
          @unknown_twt_url_list = UrlTxtReader::get_unknown_twt_url_list(path)
          puts %!size=#{@unknown_twt_url_list.size}!
        elsif @target[0] == ArtistsController::FileTarget::PXV_EXPERIMENT
          pxv_id_list, twt_url_infos, @misc_urls = UrlTxtReader::get_url_txt_info(path)
          known_pxv_user_id_list, unknown_pxv_user_id_list = Artist::pxv_user_id_classify([pxv_id_list, pxvid_list2].flatten)
          @known_pxv_user_id_list = known_pxv_user_id_list
        elsif @target[0] == ArtistsController::FileTarget::TWT_EXPERIMENT
          pxv_id_list, twt_url_infos, @misc_urls = UrlTxtReader::get_url_txt_info(path)
          known_twt_url_list, unknown_twt_url_list, pxvid_list2 = Twitter::twt_user_classify(twt_url_infos)
          @known_twt_url_list = known_twt_url_list
        elsif @target[0] == ArtistsController::FileTarget::PXV_ARTWORK_LIST
          _, _, _, @pxv_artwork_id_list = UrlTxtReader::get_url_txt_info(path, false, false, false, true)
        else
          puts %!????!
        end
      else
        pxvid_list2 = []

        pxv_id_list, twt_url_infos, @misc_urls = UrlTxtReader::get_url_txt_info(path)

        # twt
        if @target.include?("twt既知") or @target.include?("twt未知")
          pxv_chk = true#false
          known_twt_url_list, unknown_twt_url_list, pxvid_list2 = Twitter::twt_user_classify(twt_url_infos, pxv_chk)

          if @target.include?("twt既知")
            @known_twt_url_list = known_twt_url_list
            #@twt_urls = known_twt_url_list
            STDERR.puts %!known_twt_url_list=#{@known_twt_url_list.size}!
          end

          if @target.include?("twt未知")
            @unknown_twt_url_list = unknown_twt_url_list.sort_by {|k,v| -v.size}.to_h
            STDERR.puts %!unknown_twt_url_list=#{@unknown_twt_url_list.size}!
          end
        end
  
        # pxv
        if @target.include?("known_pxv") or @target.include?("unknown_pxv")
          known_pxv_user_id_list, unknown_pxv_user_id_list = Artist::pxv_user_id_classify([pxv_id_list, pxvid_list2].flatten)

          if @target.include?("known_pxv")
            @known_pxv_user_id_list = known_pxv_user_id_list
            STDERR.puts %!known_pxv_user_id_list=#{@known_pxv_user_id_list.size}!
          end

          if @target.include?("unknown_pxv")
            @unknown_pxv_user_id_list = unknown_pxv_user_id_list
            STDERR.puts %!unknown_pxv_user_id_list=#{@unknown_pxv_user_id_list.size}!
          end
        end
      end
    end
  end

  # GET /artists/twt/hoge
  def twt_show
    @twtid = params[:twtid]

    @twt_pic_path_list = Twt::get_pic_filelist(@twtid)
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

  # GET /artists/djn
  def djn_index
    @djn_artist_list = Djn::djn_artist_list
  end

  # GET /artists/djn/1
  def djn_show
    djnid = params[:djnid]
    #puts %!"#{params[:djnid]}" => "#{djnid}"!
    @djn_artist = Djn::djn_artist(djnid)
  end
  
  # GET /artists/new
  def new
    @path_list = []
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

    if @artist.rating != params[:artist][:rating].to_i
      if @artist.change_history
        prev_val = @artist.change_history
      else
        prev_val = @artist.rating
      end
      history = %!#{prev_val}=>#{params[:artist][:rating]}!

      Rails.logger.info(history)
      params[:artist][:change_history] = history
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
        :twt_checked_date, :nje_checked_date, :show_count, :reverse_status,
        :latest_artwork_id, :oldest_artwork_id, :zipped_at, :recent_filenum,
        :del_cnt, :change_history, :del_info
      )
    end

    # select
    def index_select(artists, prms, use_pred=true)

      if prms.point > 0
        artists = artists.select {|x| x.point >= prms.point}
      elsif prms.point < 0
        artists = artists.select {|x| x.point < 0}
      end

      if use_pred
        if prms.prediction > 0
          artists = artists.select {
            |x| x.prediction_up_cnt(true) >= prms.prediction or
            (prms.force_disp_day != 0 and !x.last_access_datetime_p(prms.force_disp_day))
          }
        elsif prms.prediction < 0
          artists = artists.select {|x| x.prediction_up_cnt(true) <= -(prms.prediction)}
        end
        #puts %!artists.size=#{artists.size}!
      end
      
      if prms.rating < 0
      elsif prms.rating == 0
        artists = artists.select {|x| x.rating == 0}
      else
        #artists = artists.select {|x| x.rating == 0 or x.rating >= prms.rating}
        artists = artists.select {|x| x.rating >= prms.rating}
      end
      #puts %!artists.size=#{artists.size}!

      if prms.rating_upper_limit >= 0
        STDERR.puts %!rating_upper_limit=#{rating_upper_limit}!
        artists = artists.select {|x| x.rating < prms.rating_upper_limit}
      end

      if prms.twt
        artists = artists.select {|x| x[:twtid] != "" and x[:twtid] != "-"}
        @twt = true
      end

      if prms.twt_chk
        #artists = artists.select {|x| x[:twt_check] == prms.twt_chk}
      end
      #puts %!artists.size=#{artists.size}!
  
      if prms.feat_3d
        artists = artists.select {|x| x[:feature] == "3D"}
      end

      if prms.ai
        artists = artists.select {|x| x[:feature] == "AI"}
      end

      if prms.exclude_ai
        artists = artists.select {|x| x[:feature] != "AI"}
      end
      #puts %!artists.size=#{artists.size}!

      if prms.nje
        artists = artists.select {|x| x.nje_p}
        puts %!nje="#{prms.nje}"!
      end

      case prms.status
      when "(全て)"
      when "「長期更新なし」を除外"
        artists = index_select_status_exclude(artists)
      when Status::LONG_TERM_NO_UPDATS #"長期更新なし"
        artists = index_select_status_include(artists)
      when Status::ADJUSTMENT
        artists = index_select_status_adjust(artists)
      else
        artists = artists.select {|x| x.status == prms.status}
        puts %!status="#{prms.status}"!
      end
      STDERR.puts %![sts] artists.size=#{artists.size}!

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
      #puts %!artists.size=#{artists.size}!

      if prms.r18 and prms.r18 != ""
        artists = artists.select {|x| x[:r18] == prms.r18}
        puts %!r18="#{prms.r18}"!
      end

      #puts %!artists.size=#{artists.size}!
      if prms.amount_gt != 0 and prms.amount_lt != 0
        artists = artists.select {|x| prms.amount_gt < x.filenum and x.filenum <= prms.amount_lt}
        puts %!#{prms.amount_gt}/#{prms.amount_lt}!
      elsif prms.amount_gt != 0
        artists = artists.select {|x| prms.amount_gt < x.filenum}
        puts %!#{prms.amount_gt}!
        puts %!#{artists.size}!
      elsif prms.amount_lt != 0
        artists = artists.select {|x| x.filenum <= prms.amount_lt}
        puts %!#{prms.amount_lt}!
      else
      end

      if prms.recent_filenum != 0
        artists = artists.select {|x| x[:recent_filenum] >= prms.recent_filenum}
      end
  
      if prms.year_since != 0 and  prms.year_until != 0
        artists = artists.select {|x| y = x[:last_ul_datetime].strftime("%Y").to_i; y >= prms.year_since and y <= prms.year_until}
      end
  
      if prms.last_access_datetime != 0
        #artists = artists.select {|x| !x.last_access_datetime_p(prms.last_access_datetime)}
        artists = artists.select {|x| x.last_access_datetime_chk(prms.last_access_datetime)}
      end

      if prms.created_at
        artists = artists.select {|x|
          delta = Util::get_date_delta(x.created_at);
          delta <= prms.created_at
        }
      end

      if prms.last_ul_datetime > 0
        artists = artists.select {|x|
          day = Util::get_date_delta(x.last_ul_datetime);
          day >= prms.last_ul_datetime
        }
      elsif prms.last_ul_datetime < 0
        # 負の値の場合は最近アクセスしたものを選択
        #artists = artists.select {|x| x.last_ul_datetime_p(prms.last_ul_datetime)}
      end
      #puts %!artists.size=#{artists.size}!

      artists
    end

    def index_select_status_exclude(artists)
      excl_list = [
        "長期更新なし",
        "半年以上更新なし",
        "退会",
        "停止",
        "作品ゼロ",
        "別アカウントに移行",
      ]
      artists = artists.select {|x| excl_list.include?(x.status) == false}
      artists
    end

    def index_select_status_include(artists)
      excl_list = [
        "長期更新なし",
        "半年以上更新なし",
        "3ヶ月以上更新なし",
        "1ヶ月以上更新なし",
        "作品ゼロ",
      ]
      index_select_status_include_arg(artists, excl_list)
    end

    def index_select_status_adjust(artists)
      excl_list = [
        Status::DELETED,
        Status::LONG_TERM_NO_UPDATS,
        Status::ACCOUNT_MIGRATION,
        Status::NO_ARTWORKS,
        #Status::SUSPEND,
        #Status::SIX_MONTH_NO_UPDATS,
      ]
      index_select_status_include_arg(artists, excl_list)
    end

    def index_select_status_include_arg(artists, excl_list)
      artists = artists.select {|x| excl_list.include?(x.status)}
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
        artists = artists.sort_by {|x| [-x.get_date_delta(x[:last_access_datetime]), -x.point, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
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
        artists = artists.sort_by {|x| [-x.prediction_up_cnt(true), x.recent_filenum||0, -x.filenum||0, x.last_ul_datetime||Time.new(2001,1,1)]}
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
      when SORT_TYPE::SORT_PXV_USER_ID_ASC
        artists = artists.sort_by {|x| [x.pxvid]}
      when SORT_TYPE::SORT_RATING
        artists = artists.sort_by {|x| [-(x.rating||0)]}
      when SORT_TYPE::SORT_RATING_O2N
        artists = artists.sort_by {|x| [-(x.rating||0), x.last_access_datetime||"", x.last_ul_datetime||""]}
      when SORT_TYPE::SORT_ACCESS_OLD_TO_NEW
        artists = artists.sort_by {|x| [x.last_access_datetime]}
      when SORT_TYPE::SORT_ACCESS_NEW_TO_OLD
        artists = artists.sort_by {|x| [x.last_access_datetime]}.reverse
      else
        # デフォルト？
        artists = artists.sort_by {|x| [-x.point, -(x.priority||0), -(x.recent_filenum||0), -(x.filenum||0), x.last_ul_datetime]}
      end
      artists
    end

    def get_int(str, def_val)
      if str =~ /(\d+)/
        return $1.to_i
      else
        return def_val
      end
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
      when "last_ul_datetime_ym旧→新"
        artists_group = artists.group_by {|x| x[:last_ul_datetime].strftime("%Y-%m")}.sort.to_h
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
      when "r18"
        artists_group = artists.group_by {|x| x.r18}.sort.to_h
      when "priority"
        artists_group = artists.group_by {|x| -x.priority}.sort.to_h
      when "予測"
        artists_group = artists.group_by {|x| x.prediction_up_cnt(true) / 10 * 10 }.sort.to_h
      when GROUP_TYPE::GROUP_RATING
        artists_group = artists.group_by {|x| -x.rating}.sort.to_h
      when GROUP_TYPE::GROUP_FEAT_STAT_RAT
        artists_group = artists.group_by {|x| [x.feature, x.status, -x.rating]}.sort.to_h
      when GROUP_TYPE::GROUP_STAT
        artists_group = artists.group_by {|x| x.status}.sort.to_h
      when GROUP_TYPE::GROUP_STAT_RAT
        artists_group = artists.group_by {|x| [x.status, -x.rating]}.sort.to_h
      when GROUP_TYPE::GROUP_STAT_RAT_R18
        artists_group = artists.group_by {|x| [x.status, -x.rating, x.r18]}.sort.to_h
      when "評価+年齢制限"
        #artists_group = artists.group_by {|x| [-x.rating, x.r18]}.sort.to_h
        artists_group = artists.group_by {|x| [x.rating, x.r18]}.sort.reverse.to_h
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
      when GROUP_TYPE::GROUP_ACCESS_OLD_TO_NEW
        puts %![DBG] index_group_by::#{prms.group_by}!
        artists_group = artists.group_by {|x| x[:last_access_datetime].strftime("%Y-%m")}.sort.to_h
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

    def index_all_in_one(prms, prefix, interval, target_hash)
      #puts "interval=#{interval}"

      @artists_total_count = 0

      artists_group = {}

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_ACCESS]
        artists = index_select(Artist.all, prms, false)
        artists = index_select_status_exclude(artists)

        artists_sort_access = artists.sort_by {|x| [x.last_access_datetime||Time.new(2001,1,1), -(x.recent_filenum||0), -(x.filenum||0)]}

        if false
          artists_group[prefix + "アクセス日順"] = artists_sort_access
        else
          tmp_grp = artists_sort_access.group_by {|x| x.r18}.sort.reverse.to_h
          tmp_grp.each do |k,v|
            artists_group[%!#{prefix}#{k}:アクセス日順!] = v
          end
        end
      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_PRED]
        prms.last_access_datetime = 0
        artists = index_select(Artist.all, prms)
        artists = index_select_status_exclude(artists)

        artists_sort_pred = artists.sort_by {|x| [-x.prediction_up_cnt(true), x.recent_filenum||0, -x.filenum||0, (x.last_ul_datetime||"")]}
        artists_group[prefix + "予測順"] = artists_sort_pred

      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_RATE]
        artists = index_select(Artist.all, prms)
        artists = index_select_status_exclude(artists)

        prms.last_access_datetime = interval
        artists = artists.select {|x| !x.last_access_datetime_p(interval)}
        artists_sort_high = artists.sort_by {|x| [-x.rating, -x.prediction_up_cnt(true), x.last_access_datetime||Time.new(2001,1,1)]}

        artists_group[prefix + "評価順"] = artists_sort_high
      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_UL]
        artists = index_select(Artist.all, prms, false)
        artists = index_select_status_exclude(artists)

        artists2 = artists.select {|x| x.select_cond_post_date()}
        artists_sort_ul = artists2.sort_by {|x| [x.last_ul_datetime||Time.new(2001,1,1)]}
        artists_group[prefix + "公開日順"] = artists_sort_ul
      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_NO_UPDATE]
        status_bak = prms.status
        prms.status = "(全て)"
        artists = index_select(Artist.all, prms, false)
        prms.status = status_bak

        artists = index_select_status_include(artists)
        #STDERR.puts %!GRP_SORT_NO_UPDATE = #{artists.size}, "#{prms.status}"!

        artists = artists.select {|x| x.select_cond_post_date()}
        #STDERR.puts %!GRP_SORT_NO_UPDATE = #{artists.size}!

        artists_no_updated = artists.sort_by {|x| [x.last_access_datetime||Time.new(2001,1,1)]}
        STDERR.puts %!GRP_SORT_NO_UPDATE=#{artists_no_updated.size}!

        tmp_group = artists_no_updated.group_by {|x| [
            if x.reverse_status
              x.reverse_status
            else
              ""
            end
          ]
        }

        tmp_group.each do |key, g|
          STDERR.puts %!tmp_group[#{key}]=#{g.size}!
          artists_group[prefix + "更新なし:" + key.to_s] = g
        end
      end

      if target_hash == nil or target_hash[GRP_SORT::GRP_SORT_DEL]
        # ---
        artists = index_select(Artist.all, prms, false)
        artists = artists.select {|x| (x.status == ArtistsController::Status::DELETED or x.status == ArtistsController::Status::SUSPEND)}
        #artists = artists.select {|x| !x.last_access_datetime_p(interval)}

        artists_vanish = artists.sort_by {|x| [x.twtid, x.last_access_datetime]}.reverse
        artists_group[prefix + "消滅"] = artists_vanish
      end
      
      artists_group
    end
end
