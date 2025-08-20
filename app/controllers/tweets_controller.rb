class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[ show edit update destroy ]

  module ModeEnum
    SUMMARY = 'summary'
    URL_LIST = 'urllist'
  end

  # GET /tweets or /tweets.json
  def index

    if params[:hide_within_days] == ""
      @hide_within_days = 0
    else
      @hide_within_days = params[:hide_within_days].to_i
    end
    puts %!hide_within_days="#{@hide_within_days}"!

    if params[:rating] == ""
      @rating_gt = 0
    else
      @rating_gt = params[:rating].to_i
    end
    puts %!rating_gt="#{@rating_gt}"!

    @tweet_cnt_list = []
    @known_twt_url_list = []
    @unknown_twt_url_list = []
    @tweets = []

    mode = params[:mode].presence
    case mode
    when ModeEnum::SUMMARY
      @tweet_cnt_list = Tweet.group("screen_name").count.sort_by {|x| x[1]}.reverse
    when ModeEnum::URL_LIST
      filename = "all"
      filename = "target2507"
      filename = params[:filename]
      path = UrlTxtReader::get_path(filename)
      _, twt_url_infos, _ = UrlTxtReader::get_url_txt_info(path)
      pxv_chk = false
      @known_twt_url_list, @unknown_twt_url_list, _ = Twitter::twt_user_classify(twt_url_infos, pxv_chk)
    else
      if params[:screen_name].presence
        scrn_name = params[:screen_name]
        @tweets = Tweet.select {|x| x.screen_name == scrn_name}

        @tweet_ids = Twt::get_twt_tweet_ids_from_txts(scrn_name)

        @pic_list = Twt::get_pic_filelist(scrn_name)
      else
        @tweets = Tweet.all.first(100)#TBD
      end
    end
  end

  # GET /tweets/1 or /tweets/1.json
  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
  end

  # POST /tweets or /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to tweet_url(@tweet), notice: "Tweet was successfully created." }
        format.json { render :show, status: :created, location: @tweet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tweets/1 or /tweets/1.json
  def update
    respond_to do |format|
      if @tweet.update(tweet_params)
        format.html { redirect_to tweet_url(@tweet), notice: "Tweet was successfully updated." }
        format.json { render :show, status: :ok, location: @tweet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1 or /tweets/1.json
  def destroy
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url, notice: "Tweet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tweet_params
      params.require(:tweet).permit(:tweet_id, :screen_name, :status, :rating, :num)
    end
end
