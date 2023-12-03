class TwittersController < ApplicationController
  before_action :set_twitter, only: %i[ show edit update destroy ]

  # GET /twitters or /twitters.json
  def index

    twitters = Twitter.joins(
      "LEFT OUTER JOIN artists ON twitters.twtid = artists.twtid"
    ).select("artists.id AS artist_id, artists.pxvid AS artist_pxvid, artists.status AS artist_status, artists.last_access_datetime AS artists_last_access_datetime, artists.*, twitters.*").sort_by {|x| [x[:last_access_datetime], x[:last_dl_datetime]]}

=begin
    twitters = twitters.sort_by {|x|
      if x[:last_ul_datetime] == nil
        ["2001-01-01"]
      else
        [x[:last_ul_datetime]]
      end
    }.reverse

    twitters = twitters.group_by {|x| x[:last_ul_datetime] == nil ? "nil" : "x" }
    @twitters_group = twitters["x"].group_by {|x| "20" + x[:last_ul_datetime][0..1]}.sort.reverse.to_h
    @twitters_group["nil"] = twitters["nil"].sort_by {|x| [x[:last_access_datetime], x[:last_dl_datetime]]}
=end
    if params[:debug] == nil
      twitters = twitters.select {|x| x.drawing_method != nil}
      twitters = twitters.select {|x| !x.last_access_datetime_p(1)}
      twitters = twitters.sort_by {|x| [x.last_access_datetime, (x.last_dl_datetime)]}
      #twitters = twitters.select {|x| x.last_dl_datetime.year >= 2023}
      #twitters = twitters.select {|x| x.last_dl_datetime.month >= 11}
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "AI" or x.drawing_method == "パクリ")}
    else
      twitters = twitters.select {|x| x.last_dl_datetime == nil}
    end
    #@twitters_group = twitters.group_by {|x| x.drawing_method}
    @twitters_group = twitters.group_by {|x| x.rating}
    @twitters_group = @twitters_group.sort_by {|k, v| v}.to_h
  end

  # GET /twitters/1 or /twitters/1.json
  def show
    @twitter.update(last_access_datetime: Time.now)
  end

  # GET /twitters/new
  def new
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
        :sensitive
    
        )
    end
end
