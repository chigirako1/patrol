class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[ show edit update destroy ]

  module ModeEnum
    SUMMARY = 'summary'
    URL_LIST = 'urllist'
    URL_LIST_SUMMARY = 'urllist_summary'
  end

  def get_param_num(symbol, def_val=0)
    if params[symbol] == ""
      value = def_val
    else
      value = params[symbol].to_i
    end
    STDERR.puts %!#{symbol}="#{value}"!
    value
  end

  def get_param_str(symbol, def_val="")
    if params[symbol]
      value = params[symbol]
    else
      value = def_val
    end
    STDERR.puts %!#{symbol}="#{value}"!
    value
  end

  # GET /tweets or /tweets.json
  def index

    @hide_within_days = get_param_num(:hide_within_days)
    @rating_gt = get_param_num(:rating)
    @pred = get_param_num(:pred)
    @target = get_param_str(:target)
    @created_at = get_param_num(:created_at)
    @todo_cnt = get_param_num(:todo_cnt)

    @tweet_cnt_list = []
    @known_twt_url_list = []
    @unknown_twt_url_list = []
    @tweets = []

    mode = params[:mode].presence
    case mode
    when ModeEnum::SUMMARY
      @tweet_cnt_list, @tweet_sum_hash = Tweet.summary
    when ModeEnum::URL_LIST_SUMMARY
      filename = params[:filename]
      known_twt_url_list, _ = url_list(filename)
      @url_list_summary = Tweet::url_list_summary(known_twt_url_list)
    when ModeEnum::URL_LIST
      filename = params[:filename]
      @known_twt_url_list, @unknown_twt_url_list = url_list(filename)
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

  # GET /tweets/
  def update_recods
    @hoge = Twt::update_tweet_records_by_fs()
  end

  # GET /tweets/1 or /tweets/1.json
  def show
    @pic_list = Twt::get_pic_filelist(@tweet.screen_name)
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

    def url_list(filename)
      Twitter::url_list(filename)
    end
end
