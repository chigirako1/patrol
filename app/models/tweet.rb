

class Tweet < ApplicationRecord

    module StatusEnum
        SAVED = "保存済み"
        TO_BE_REMOVED = "削除予定"
        DELETED = "削除"
        UNACCESSIBLE = "URLアクセス不可"
        UNACCESSIBLE_FREEZED = "URLアクセス不可(凍結されたアカウント)"
        UNACCESSIBLE_PRIVATE = "URLアクセス不可(非公開アカウント)"
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
        exist = 0

        url_list.each do |x|
            tweet_id = Twt::get_tweet_id_from_url(x)
            if tweet_id
                tweet = Tweet.find_by(tweet_id: tweet_id)
                if tweet
                    exist += 1
                end
            else
                exist += 1
                #STDERR.puts %!\t"#{x}"\t#{exist}!
            end
        end
        exist
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

    Url_List_Summary = Struct.new(:screen_name, :url_cnt, :todo_cnt)

    def self.new_summary(key, url_list)
        exist_cnt = check_registered_record(url_list)
        todo_cnt = url_list.size - exist_cnt
        if todo_cnt > 0
            #STDERR.puts %!"@#{key}":#{todo_cnt}/#{url_list.size}!
        end

        Url_List_Summary.new(key, url_list.size, todo_cnt)
    end

    def self.url_list_summary(known_twt_url_list)

        url_list_summary = []
        known_twt_url_list.each do |key, url_list|
            url_list_summary << new_summary(key, url_list)
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

        make_summary_str(hash)
    end

    def self.summary_hash(screen_name)
        t = Tweet.where(screen_name: screen_name)
        hash = t.group(:status).count
        hash
    end
    
    def self.make_summary_str(hash)
        tmp_ary = []
        cnt = hash.sum {|k,v| v}
        hash.each do |k,v|
            tmp_ary << %!#{k}:#{v}(#{ v * 100 / cnt}%)!
        end
        tmp_ary
    end

    def self.get_summary_str(screen_name)
        hash = summary_hash(screen_name)
        make_summary_str(hash)
    end
    
    def self.summary_cnt(tweet_sum_hash, screen_name, status)
        tweet_sum_hash[screen_name][status]
    end

    def self.get_unaccessible_twt_account_list()
        t = Tweet.select {|x| x.status == StatusEnum::UNACCESSIBLE}
        grp = t.group_by {|x| x.screen_name}.delete_if {|k,v| v.size < 2}
        grp
    end

    def self.unaccessible_tweet_summary()
        grp = get_unaccessible_twt_account_list
        #grp = grp.sort_by {|k,v| v.size}.reverse.to_h
        unaccessible_tweet_summary = grp
    end

    def self.unaccessible_twt_list(grp)
        id_list = grp.keys
        twitters = Twitter.select {|x| id_list.include?(x.twtid)}
        twitters = twitters.select {|x| x.drawing_method == Twitter::DRAWING_METHOD::DM_AI and x.status == Twitter::TWT_STATUS::STATUS_PATROL}
        #twitters = twitters.sort_by {|x| -x.rating}
        twitters = twitters.sort_by {|x| x.last_access_datetime}
        twitters
    end
end
