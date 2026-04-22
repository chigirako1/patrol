

class Tweet < ApplicationRecord

    module StatusEnum
        TO_BE_OBTAIN = "取得予定"
        SAVED = "保存済み"
        TO_BE_REMOVED = "削除予定"
        DELETED = "削除"
        UNACCESSIBLE = "URLアクセス不可"
        UNACCESSIBLE_FREEZED = "URLアクセス不可(凍結されたアカウント)"
        UNACCESSIBLE_PRIVATE = "URLアクセス不可(非公開アカウント)"
        DUPLICATE = "重複"
    end

    def self.status_enum_array()
        [
            [StatusEnum::SAVED],
            [StatusEnum::TO_BE_REMOVED],
            [StatusEnum::DELETED],
            [StatusEnum::UNACCESSIBLE],
            [StatusEnum::UNACCESSIBLE_FREEZED],
            [StatusEnum::UNACCESSIBLE_PRIVATE],
            [StatusEnum::DUPLICATE],
            [StatusEnum::TO_BE_OBTAIN],
        ]
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

            puts %![update_tweet_record] @#{tweet_id}:#{twt_params}!
        else
            msg = %!@#{tweet_id}の更新に失敗しました。未登録のIDです!
            Rails.logger.error(msg)
        end
    end

    def self.get_tweet_record(tweet_id)
        tweet = Tweet.find_by(tweet_id: tweet_id)
    end

    C_YET = "01.未登録"
    C_TODAY = "10.本日登録"
    C_YESTERDAY = "90.昨日以前登録"
    C_TBO = "99.#{StatusEnum::TO_BE_OBTAIN}"
    
    def self.tweet_group(tweet_i_ids, spec_str)
        #work = tweet_i_ids.map {|x| [x, Tweet::get_tweet_record(x)]}.sort_by {|x| [x[1]&.tweet_id||Float::INFINITY, x[0]]}
        tweets_grp = Hash.new { |h, k| h[k] = [] }
        screen_name_set = Set.new

        work = tweet_i_ids.each do |x|
            r =  Tweet::get_tweet_record(x)
            if r
                if Util::get_date_delta(r.created_at) == 0
                    key = C_TODAY
                elsif r.status == StatusEnum::TO_BE_OBTAIN
                    key = C_TBO
                else
                    key = C_YESTERDAY
                    if screen_name_set.include?(r.screen_name)
                        next
                    end

                    screen_name_set.add(r.screen_name)
                    next
                end
            else
                key = C_YET
            end
            tweets_grp[key] << [x, r]
        end

        tweets_grp.each do |key, val|
            case key
            when C_TODAY
                val.sort_by! {|x| x[1].id}
            when C_YESTERDAY
                val.sort_by! {|x| [x[1].status, x[1].screen_name]}
            when C_YET
                val.sort_by! {|x| x[0]}
            else
            end
        end

        twitters = build_twitters(screen_name_set)
        twt_grp = build_twt_grp(twitters, spec_str)

        [tweets_grp.sort.to_h, twt_grp.sort_by {|k,v| k}.reverse.to_h]
    end

    def self.build_twitters(screen_name_set)
        twitters = []
        screen_name_set.each do |screen_name|
            twt = Twitter.find_by_twtid_ignore_case(screen_name)
            if twt
                twitters << twt
            end
        end
        twitters
    end

    def self.build_twt_grp(twitters, spec_str)
        twt_grp = Hash.new { |h, k| h[k] = [] }
        twitters.each do |twt|
            spec = spec_str
            key_header = twt.group_spec(spec)
            twt_grp[key_header] << twt
        end

        twt_grp.each do |key, value|
            value.sort_by! {|v| [-(v.rating||0), -v.prediction, v.last_access_datetime]}
        end

        twt_grp
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

    def self.get_records(screen_name, status)
        Tweet.where(screen_name: screen_name, status: status)
    end

    def self.has_acquisition_schedule?(screen_name)
        #tweets = Tweet.where(screen_name: screen_name, status: StatusEnum::TO_BE_OBTAIN)
        tweets = Tweet.get_records(screen_name, StatusEnum::TO_BE_OBTAIN)
        #STDERR.puts %!has_acquisition_schedule?: @#{screen_name}, #{tweets.size}!
        if tweets.size > 0
            true
        else
            false
        end
    end

    def self.hoge()
        tweet_cnt_list = Tweet.group("screen_name").count.sort_by {|x| x[1]}.reverse

        tweet_h = {}
        tweet_cnt_list.each do |elem|
            screen_name = elem[0]
            cnt = elem[1]
            twt = Twitter.where(twtid: screen_name)
            tweet_h[screen_name] = [twt, cnt]
        end
        tweet_h
    end

    def self.get_unregistered_tweet_ids(tweet_id_list)
        ids = []
        tweet_id_list.each do |tweet_id|
            tweet_rcd = Tweet.find_by(tweet_id: tweet_id)
            if tweet_rcd and (tweet_rcd.status == StatusEnum::SAVED or tweet_rcd.status == StatusEnum::UNACCESSIBLE)
            else
                ids << tweet_id
            end
        end
        ids
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

    def self.to_be_obtain_list()
        t = Tweet.select {|x| x.status == StatusEnum::TO_BE_OBTAIN}
        grp = t.group_by {|x| x.screen_name}
        grp
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
