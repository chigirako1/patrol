class TwittersController < ApplicationController
  before_action :set_twitter, only: %i[ show edit update destroy ]

  # GET /twitters or /twitters.json
  def index

    if params[:mode] == ""
      mode = "id"
    else
      mode = params[:mode]
    end

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

    if params[:pred] == ""
      pred_cond_gt = 0
    else
      pred_cond_gt = params[:pred].to_i
    end

    if params[:rating] == ""
      rating_gt = 0
    else
      rating_gt = params[:rating].to_i
    end

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
    puts %!sort_by="#{@sort_by}"!
    
    if mode == "search"
      #twitters = Twitter.looks(params[:target_col], params[:search_word], params[:match_method])
      col, word = Twitter.looks("(自動判断)", params[:search_word], "auto")
      twitters = Twitter.joins(
        "LEFT OUTER JOIN artists ON twitters.twtid = artists.twtid"
      ).select("artists.id AS artist_id,
            artists.pxvid AS artist_pxvid,
            twitters.twtid AS twitter_twtid,
            artists.twtid AS artist_twtid,
            artists.status AS artist_status,
            artists.last_access_datetime AS artists_last_access_datetime,
            artists.*, twitters.*").where(col, word).sort_by {|x| [x[:last_access_datetime], x[:last_dl_datetime]]}
    else
      twitters = Twitter.joins(
        "LEFT OUTER JOIN artists ON twitters.twtid = artists.twtid"
      ).select("artists.id AS artist_id,
            artists.pxvid AS artist_pxvid,
            artists.status AS artist_status,
            artists.last_access_datetime AS artists_last_access_datetime,
            artists.*, twitters.*").sort_by {|x| [x[:last_access_datetime], x[:last_dl_datetime]]}
    end
    
    case mode
    when "id"
      @num_of_disp = 5
      if rating_gt != 0
        twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt }
      end
      twitters = twitters.sort_by {|x| [x.id]}.reverse
      #@twitters_group = twitters.group_by {|x| x.rating}
      #@twitters_group = {}
      #@twitters_group[""] = twitters
      if params[:target] != nil and params[:target] == ""
        @twitters_group = {}
        twitters = twitters.select {|x| x.drawing_method == params[:target] or x.drawing_method == nil}
        twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
        @twitters_group[""] = twitters
      else
        @twitters_group = twitters.group_by {|x| %!#{x.status}:#{x.drawing_method}! }
      end
      return
    when "pxv_search"
      @num_of_disp = 30
      twitters = twitters.select {|x| x.pxvid.presence and x.artist_pxvid == nil }
      twitters = twitters.sort_by {|x| [x.id]}.reverse
      @twitters_group = {}
      @twitters_group[""] = twitters
      return
    when "access"
      twitters = twitters.sort_by {|x| [x.last_access_datetime]}.reverse
    when "rating_nil"
      @num_of_disp = 30
      twitters = twitters.select {|x| x.rating == nil}
      twitters = twitters.sort_by {|x| [x.last_access_datetime]}.reverse
      @twitters_group = twitters.group_by {|x| x.rating}
    when "dl_nil"
      twitters = twitters.select {|x| x.last_dl_datetime == nil}
    when "not_patrol"
      twitters = twitters.select {|x| x.status != "TWT巡回"}
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "AI")}
    when "patrol"
      twitters = twitters.select {|x| x.drawing_method != nil}
      twitters = twitters.select {|x| x.status == "TWT巡回"}
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      #twitters = twitters.select {|x| x.get_date_delta(x.last_access_datetime) > 0}
      #twitters = twitters.select {|x| x.id == 1388}
      
      if params[:target].presence
        twitters = twitters.select {|x| x.drawing_method == params[:target]}
      else
        twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "AI" or x.drawing_method == "パクリ")}
      end

      if pred_cond_gt != 0
        twitters = twitters.select {|x| x.prediction >= pred_cond_gt}
      end

      if rating_gt != 0
        twitters = twitters.select {|x| x.rating == nil or x.rating >= rating_gt }
      end

      case sort_by
      when "access"
        twitters = twitters.sort_by {|x| [x.last_access_datetime, (x.last_dl_datetime)]}
      else
        twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime, (x.last_dl_datetime)]}
      end
    when "hand"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.select {|x| x.status == "TWT巡回"}
      twitters = twitters.select {|x| x.drawing_method != nil and (x.drawing_method == "手描き")}

      twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime, (x.last_dl_datetime)]}
    when "未設定"
      twitters = twitters.select {|x| !x.last_access_datetime_p(@hide_within_days)}
      twitters = twitters.select {|x| !(x.drawing_method.presence) }
      twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime, (x.last_ul_datetime || "2000-01-01")]}
      @twitters_group = twitters.group_by {|x| x.status}
      return
    when "all"
      twitters = twitters.sort_by {|x| [-x.prediction, x.last_access_datetime, (x.last_ul_datetime || "2000-01-01")]}
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
    else
      @twitter.update(last_access_datetime: Time.now)
    end
    @twt_pic_path_list = @twitter.get_pic_filelist
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
        :sensitive,
        :private_account,
        :reverse_status,
        :new_twtid,
        :sub_twtid,
        :main_twtid,
        )
    end
end
