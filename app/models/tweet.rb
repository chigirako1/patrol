class Tweet < ApplicationRecord

    module StatusEnum
        SAVED = "保存済み"
        DELETED = "削除"
        UNACCESSIBLE = "URLアクセス不可"
    end

    def self.create_record(screen_name, tweet_id, status=StatusEnum::SAVED)
        twt_params = {}
        twt_params[:screen_name] = screen_name
        twt_params[:tweet_id] = tweet_id
        twt_params[:status] = status
        twt = Tweet.new(twt_params)
        twt.save
        puts %!new. "#{twt}"!
    end
end
