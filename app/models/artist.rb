class Artist < ApplicationRecord
    has_one :twitters, :class_name => 'Twitter'

    def self.looks(target_col, search_word, match_method)
        search_word_p = ""
        case match_method
        when "perfect_match"
            search_word_p = search_word
        when "begin_match"
            search_word_p = "#{search_word}%"
        when "end_match"
            search_word_p = "%#{search_word}"
        when "partial_match"
            search_word_p = "%#{search_word}%"
        else
            search_word_p = search_word
        end
        @artist = Artist.where("#{target_col} LIKE?", search_word_p)
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

    def get_datetime_string(last_ul_datetime)
        now = Time.zone.now
        if last_ul_datetime.year == now.year
          ym_format = "%m月%d日"
        else
          ym_format = "%Y年%m月"
        end
        last_ul_datetime_str = last_ul_datetime.in_time_zone('Tokyo').strftime(ym_format)
    end
end
