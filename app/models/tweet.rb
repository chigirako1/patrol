

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
    end

    def self.update_record(tweet_id, status=StatusEnum::SAVED)
        tweet = Tweet.find_by(tweet_id: tweet_id)
        
        twt_params = {}
        twt_params[:status] = status
        tweet.update(twt_params)
    end
end
