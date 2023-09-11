class Artist < ApplicationRecord
    def self.looks(target_col, search_word)
        @artist = Artist.where("#{target_col} LIKE?", "#{search_word}")
=begin
        if search == "perfect_match"
            @user = User.where("name LIKE?", "#{word}")
        elsif search == "forward_match"
            @user = User.where("name LIKE?","#{word}%")
        elsif search == "backward_match"
            @user = User.where("name LIKE?","%#{word}")
        elsif search == "partial_match"
            @user = User.where("name LIKE?","%#{word}%")
        else
            @user = User.all
        end
=end
    end

    def get_date_delta(date)
        now = Time.zone.now  
        days = (now - date).to_i / 60 / 60 / 24
    end

    def get_date_info(date)
        days = get_date_delta(date)
        if days >= 365
            years = days / 365
            "#{years}年以上前"
        elsif days >= 30
            months = days / 30
            "#{months}ヵ月以上前"
        elsif days == 0
            "今日"
        else
            "#{days}日以内"
        end
    end
end
