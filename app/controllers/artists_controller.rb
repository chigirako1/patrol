
#------------------------------------------------------------------------------
# class:
#------------------------------------------------------------------------------
class Params
  attr_accessor :param_file,
    :twt,
    :ai,
    :nje,
    :year_since,
    :year_until,
    :display_number,
    :group_by,
    :sort_by,
    :status,
    :amount_gt,
    :amount_lt,
    :filename,
    :last_access_datetime,
    :r18,
    :point,
    :thumbnail,
    :begin_no,
    :url_list_only

  def initialize(params)
    @group_by = params[:group_by]
    @sort_by = params[:sort_by]
    @status = params[:status]
    @point = params[:point]

    if @point == nil
      @point = 0
    else
      @point = @point.to_i
    end

    if @status == nil
      @status = ""
    end
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

    last_access_datetime = params[:last_access_datetime]
    if last_access_datetime == nil or last_access_datetime == 0
      @last_access_datetime = 25 #0
    else
      @last_access_datetime = last_access_datetime.to_i
    end
    puts "last_access_datetime=#{@last_access_datetime}"

    display_number = params[:display_number]
    if display_number != nil
      @display_number = display_number.to_i
    else
      @display_number = 10
    end
    if @display_number == 0
      @display_number = 10
    end
    puts %!@display_number=#{@display_number}!

    twt = params[:twt]
    if twt == "true"
      @twt = true
    end

    ai = params[:ai]
    if ai != nil and ai == "true"
      @ai = true
    end

    nje = params[:nje]
    if nje != nil and nje == "true"
      @nje = true
    end

    thumbnail = params[:thumbnail]
    if thumbnail != nil and thumbnail == "true"
      @thumbnail = true
    end
    puts %![twt:#{@twt}],[ai:#{@ai}],[thumbnail:#{@thumbnail}]!

    @param_file = params[:file]
    filename = params[:filename]
    if filename == nil
      @filename = ""
    else
      @filename = filename
    end
    puts %!param_file=#{@param_file}/filename=#{@filename}!

    @url_list_only = false
    url_list_only = params[:url_list_only]
    if url_list_only == "true"
      @url_list_only = true
      puts %!url_list_only=#{@url_list_only}!
    end
  end
end

#------------------------------------------------------------------------------
# class:
#------------------------------------------------------------------------------
class ArtistsController < ApplicationController
  extend UrlTxtReader
  
  before_action :set_artist, only: %i[show edit update destroy edit_no_update]

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
    else
      artists = Artist.all
    end

    if prms.param_file == "urllist" or
      prms.param_file == "urllist-pxv-only" or
      prms.param_file == "urllist-unknown-only" or
      prms.param_file == "urllist-twt-only" or
      prms.param_file == "urllist-twt-only(latest)"
      if prms.url_list_only
        @misc_urls = Artist.get_url_list_from_all_txt
        return
      else
        datestr = prms.filename
        if prms.param_file == "urllist-twt-only(latest)"
          path = "public/get illust url_1029.txt"
        elsif datestr == ""
          path = ""
        else
          path = "public/get illust url_#{datestr}.txt"
        end
        puts "path=#{path}"
        id_list, @twt_urls, @misc_urls = Artist.get_url_list(path)

        if prms.param_file == "urllist-unknown-only"
          artists = artists.first(1)
          @twt_urls = []
          @twt = false
          @unknown_id_list = Artist.get_unknown_id_list(id_list)
        elsif prms.param_file == "urllist-pxv-only"
          artists = artists.select {|x| id_list.include?(x[:pxvid])}
          @twt_urls = []
          @twt = false
          @unknown_id_list = Artist.get_unknown_id_list(id_list)
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
    end

    artists = index_select(artists, prms)
    puts %!artists.size=#{artists.size}!
    artists = index_sort(artists, prms)
    @artists_group = index_group_by(artists, prms)
  end

  # GET /artists/1 or /artists/1.json
  def show
    if params[:access_dt_update].presence and params[:access_dt_update] == "no"
    else
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

    @path_list = Artist.get_pathlist(@artist[:pxvid])
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
        :last_access_datetime, :priority, :status, :comment, :twtid, :njeid, :r18, :remarks,
        :rating, :furigana, :altname, :oldname, :chara, :work, :warnings, :feature,
        :twt_check, :earliest_ul_date, :circle_name, :fetish, :pxv_fav_artwork_id, :web_url,
        :append_info, :twt_checked_date, :nje_checked_date, :show_count
      )
    end

    # select
    def index_select(artists, prms)

      if prms.point != 0
        artists = artists.select {|x| x.point >= prms.point}
      end

      if prms.twt
        artists = artists.select {|x| x[:twtid] != "" and x[:twtid] != "-"}
        @twt = true
      end
  
      if prms.ai
        artists = artists.select {|x| x[:feature] == "AI"}
      end

      if prms.nje
        artists = artists.select {|x| x.nje_p}
        puts %!nje="#{prms.nje}"!
      end

        if prms.status != "(全て)"
        artists = artists.select {|x| x.status == prms.status}
        puts %!status="#{prms.status}"!
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
=begin
        artists.each do |x|
          if x.point == "@" or x.priority == nil or x[:recent_filenum] == "@" or x[:filenum] == "@" or x[:last_ul_datetime] == "@"
            puts x.pxvname
          end
        end
=end
        #artists = artists.sort_by {|x| [-x.point, -x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
        artists = artists.sort_by {|x| [-x.point, x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      when "-point"
        artists = artists.sort_by {|x| [x.point, -x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      when "last_ul_date"
        artists = artists.sort_by {|x| [x.last_ul_datetime]}
      when "twtid"
        artists = artists.sort_by {|x| [x.twtid]}
      when "filenum"
        artists = artists.sort_by {|x| [-x.filenum]}
      else
        # デフォルト？
        artists = artists.sort_by {|x| [-x.point, -x.priority, -x[:recent_filenum], -x[:filenum], x[:last_ul_datetime]]}
      end
      artists
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
      when "filenum"
        artists_group = artists.group_by {|x| (x[:filenum] / 100 * 100)}.sort.reverse.to_h
      when "recent_filenum"
        artists_group = artists.group_by {|x| (x[:recent_filenum] / 10 * 10)}.sort.reverse.to_h
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
      when "rating"
        artists_group = artists.group_by {|x| -x.rating}.sort.to_h
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
