class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[ show edit update destroy ]

  # GET /artists or /artists.json
  def index
    @size_per_table = 25
    @num = params[:num]

    #@artists_group = Artist.all.group_by {|elem| elem[:last_ul_datetime].year}.sort.reverse.to_h
    #@artists_group = Artist.all.group_by {|elem| elem[:last_ul_datetime].strftime("%Y-%m")}.sort.reverse.to_h
    artists_group = Artist.all.group_by {|elem| elem[:last_ul_datetime].strftime("%Y")}.sort.reverse.to_h
    @artists_group = {}
    artists_group.each do |key, artists|
      if @num == "few"
        artists = artists.sort_by {|x| [x[:last_access_datetime], x[:filenum]]}
      else
        artists = artists.sort_by {|x| [x[:last_access_datetime], -x[:priority], -x[:filenum]]}
      end
      if artists.count > 1000
        tmp = artists.group_by {|elem| elem[:last_ul_datetime].strftime("%Y-%m")}.sort.reverse.to_h
        tmp.each do |tmp_key, tmp_artists|
          @artists_group[tmp_key] = tmp_artists
        end
      else
        @artists_group[key] = artists
      end
    end


    #@artists = Artist.all.sort {|a,b| a[:last_access_datetime] <=> b[:last_access_datetime]}
    #@artists = Artist.all.sort_by(&:last_access_datetime, &:filenum)
    @artists = Artist.all.sort_by {|x| [x[:last_access_datetime], -(x[:filenum] / 100 * 100)]}
    #@artists = Artist.all.sort_by {|x| [x[:filenum]]}
  end

  # GET /artists/1 or /artists/1.json
  def show
    @artist.update(last_access_datetime: Time.now)

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
      params.require(:artist).permit(:pxvname, :pxvid, :filenum, :last_dl_datetime, :last_ul_datetime, :last_access_datetime, :priority)
    end
end
