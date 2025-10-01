

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
end
