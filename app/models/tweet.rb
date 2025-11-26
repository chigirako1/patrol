

class Tweet < ApplicationRecord

    module StatusEnum
        SAVED = "保存済み"
        TO_BE_REMOVED = "削除予定"
        DELETED = "削除"
        UNACCESSIBLE = "URLアクセス不可"
        DUPLICATE = "重複"
    end

    def self.create_record(screen_name, tweet_id, status=StatusEnum::SAVED, num=-1)
        twt_params = {}
        twt_params[:screen_name] = screen_name
        twt_params[:tweet_id] = tweet_id
        twt_params[:status] = status
        if num != -1
            twt_params[:num] = num
        end
        twt = Tweet.new(twt_params)
        twt.save
        #puts %!new. "#{twt}"!
        twt
    end

    def self.update_record(tweet_id, status=StatusEnum::SAVED)
=begin
        tweet = Tweet.find_by(tweet_id: tweet_id)
        
        twt_params = {}
        twt_params[:status] = status
        tweet.update(twt_params)
=end
        update_tweet_record(nil, tweet_id, status: status, rating: nil, remarks: nil)
    end

    def self.update_tweet_record(tweet, tweet_id, status:, rating:, remarks:)
        if tweet
        else
            tweet = Tweet.find_by(tweet_id: tweet_id)
        end


        if tweet
            twt_params = {}

            twt_params[:status] = status if status
            twt_params[:rating] = rating if rating
            twt_params[:status] = remarks if remarks
            
            tweet.update(twt_params)

            puts %!@#{tweet_id}:#{twt_params}!
        else
            STDERR.puts %!@#{tweet_id}の更新に失敗しました。未登録のIDです!
        end
    end

    def self.check_registered_record(url_list)
        exsit = 0

        url_list.each do |x|
            tweet_id = Twt::get_tweet_id_from_url(x)
            tweet = Tweet.find_by(tweet_id: tweet_id)
            if tweet
                exsit += 1
            end
        end
        exsit
    end

    def self.summary()
        tweet_cnt_list = Tweet.group("screen_name").count.sort_by {|x| x[1]}.reverse

        tweet_sum_hash = {}
        tweet_cnt_list.each do |e|
            screen_name = e[0]
            t = Tweet.where(screen_name: screen_name)
            a = t.group(:status).count
            tweet_sum_hash[screen_name] = a
        end
        [tweet_cnt_list, tweet_sum_hash]
    end

    def self.url_list_summary(known_twt_url_list)
        url_List_Summary = Struct.new(:screen_name, :url_cnt, :todo_cnt)

        url_list_summary = []
        known_twt_url_list.each do |key, url_list|
            exist_cnt = check_registered_record(url_list)
            url_list_summary << url_List_Summary.new(key, url_list.size, url_list.size - exist_cnt)
            #STDERR.puts %!"@#{key}":#{}!
        end
        url_list_summary.sort_by {|x| [x.todo_cnt, x.url_cnt, x.screen_name]}#.reverse
    end

    def self.url_list_summary_hash(known_twt_url_list)
        url_l_summary = url_list_summary(known_twt_url_list)
        url_l_summary.map {|x| [x.screen_name, x]}.to_h
    end

    def self.summary_str(tweet_sum_hash, screen_name)
        tmp_ary = []
        hash = tweet_sum_hash[screen_name]
        unless hash
            return tmp_ary
        end

        cnt = hash.sum {|k,v| v}
        hash.each do |k,v|
            tmp_ary << %!#{k}:#{v}(#{ v * 100 / cnt}%)!
        end
        tmp_ary
    end

    def self.get_summary_str(screen_name)
        tmp_ary = []

        t = Tweet.where(screen_name: screen_name)
        hash = t.group(:status).count

        cnt = hash.sum {|k,v| v}
        hash.each do |k,v|
            tmp_ary << %!#{k}:#{v}(#{ v * 100 / cnt}%)!
        end
        tmp_ary
    end
    
    def self.summary_cnt(tweet_sum_hash, screen_name, status)
        tweet_sum_hash[screen_name][status]
    end
end
