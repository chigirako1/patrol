require 'nkf'
require 'find'

class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[ show edit update destroy ]

  # GET /artists or /artists.json
  def index
    @size_per_table = 25
    twt = params[:twt]
    ai = params[:ai]
    amount = params[:amount]
    year = params[:year]
    display_number = params[:display_number]
    group_by = params[:group_by]
    sort_by = params[:sort_by]

    if display_number != nil
      @size_per_table = display_number.to_i
    end

    @artists_group = {}
    artists = Artist.all

    if twt == "twt"
      artists = artists.select {|elem| elem[:twtid] != ""}
    end

    if ai == "ai"
      artists = artists.select {|elem| elem[:comment] == "AI"}
    end

    if amount != nil
      case amount 
      when "many"
        artists = artists.select {|elem| elem[:filenum] > 200}
      when "mid"
        artists = artists.select {|elem| elem[:filenum] > 100 and elem[:filenum] <= 200}
      when "few"
        artists = artists.select {|elem| elem[:filenum] <= 100}
      else
      end
    end

    if year != nil
      artists = artists.select {|elem| elem[:last_ul_datetime].strftime("%Y") == year}
    end

    case sort_by
    when "access_date_X_last_ul_datetime"
      artists = artists.sort_by {|x| [x[:last_access_datetime], x[:last_ul_datetime]]}
    when "access_date_X_recent_filenum"
      artists = artists.sort_by {|x| [x[:last_access_datetime], -x[:recent_filenum]]}
    when "access_date_X_pxvname_X_recent_filenum"
      artists = artists.sort_by {|x| [x[:last_access_datetime], x[:pxvname].downcase, -x[:recent_filenum]]}
    else
    end

    case group_by
    when "last_ul_datetime"
      @artists_group = artists.group_by {|elem| elem[:last_ul_datetime].strftime("%Y")}.sort.reverse.to_h
      return
    when "pxvname"
      @artists_group = artists.group_by {|elem| select_group(elem[:pxvname])}.sort.to_h
      return
    else
    end

    set_artist_group_pxv(artists)
  end

  # GET /artists/1 or /artists/1.json
  def show
    @artist.update(last_access_datetime: Time.now)

    @path_list = []
    rpath = ""
    search_str = %!(#{@artist[:pxvid]})!
    base_path = Rails.root.join("public").to_s

=begin
遅すぎる
    Find.find(base_path + "/dpxv/pxv") {|f|
      Find.prune if f.split(/\//).size > 11
      @path_list << f
      if f.include?(search_str)
        rpath = f
        break
      end
    }

    findやglobはシンボリックリンクは辿ってくれない模様
=end
    #DBにパスを格納したいが面倒なので。。。　
    txtpath = Rails.root.join("public/pxv/dirlist.txt").to_s
    File.open(txtpath) { |file|
      while line  = file.gets
        if line.include?(search_str)
          rpath = line.chomp
          break
        end
      end
    }

    if rpath != ""
      tmp_list = []
      Find.find(rpath) do |path|
        if File.extname(path) == ".jpg"
          tmp_list << path.gsub(base_path, "")
        end
      end
      @path_list = tmp_list.last(5).reverse
    end

    #外部にリダイレクトしようとするとエラー
    #url = %!https://www.pixiv.net/users/#{@artist["pxvid"]}!
    #redirect_to url
    #render url
  end

  # GET /artists/new
  def new
    @artist = Artist.new
  end

  # GET /artists/1/edit
  def edit
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
      params.require(:artist).permit(:pxvname, :pxvid, :filenum, :last_dl_datetime, :last_ul_datetime, :last_access_datetime, :priority, :status, :comment, :twtid)
    end

    def select_group(pxvname)
      group = ""
      fl = pxvname[0]
      case fl
      when /[A-Za-z]/
        group = fl.downcase
      when /\p{katakana}/
        fl = NKF.nkf('-w -X', fl) #半角を全角に変換
        fl = fl.tr('ァ-ン','ぁ-ん')
        group = "あ"
      when /\p{hiragana}/
        group = "あ"
      when /[:digit:]/
        group = "0"
      when /[0-9]/
        group = "0"
      when /[가-힣]/
        group = "ハングル"
      else
        group = "他"
      end
      group
    end

    def judge_number(filenum)
      if filenum >= 100
        "3多"
      elsif filenum >= 30
        "2中"
      elsif filenum >= 10
        "1小"
      else
        "0"
      end
    end

    def set_artist_group_pxv(artists_select)
      artists_group_by_year = artists_select.group_by {|elem| elem[:last_ul_datetime].strftime("%Y")}.sort.reverse.to_h

      artists_group_by_year.each do |key, artists|
        if artists.count > 300
          artists_group_by_yymm = artists.group_by {|elem| elem[:last_ul_datetime].strftime("%Y-%m")}.sort.reverse.to_h
          artists_group_by_yymm.each do |tmp_key, tmp_artists|
            if tmp_artists.count > 100
              tmp2 = tmp_artists.group_by {|elem| judge_number(elem[:filenum])}.sort.reverse.to_h
              tmp2.each do |tmp2_key, tmp2_artists|
                @artists_group[tmp_key + ":" + tmp2_key.to_s] = tmp2_artists.sort_by {|x| [x[:last_access_datetime], -x[:recent_filenum]]}
              end
            else
              @artists_group[tmp_key] = tmp_artists.sort_by {|x| [x[:last_access_datetime], -x[:filenum]]}
            end
          end
        else
          @artists_group[key] = artists.sort_by {|x| [x[:last_access_datetime], -x[:filenum]]}
        end
      end
      @artists_group["all"] = Artist.all.sort_by {|x| [x[:last_access_datetime], -(x[:recent_filenum] / 10 * 10), x[:last_ul_datetime] ,-x[:filenum]]}
    end
end
