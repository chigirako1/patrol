class Twitter < ApplicationRecord
    include UrlTxtReader

    belongs_to :artists, :class_name => 'Artist', optional: true

    def self.looks(target_col, search_word, match_method)

        search_word.strip!
        puts %!#{target_col}, #{search_word}, #{match_method}!

        if target_col == "(自動判断)"
            if search_word =~ /^\w+$/
                target_col = "twitter_twtid"
            elsif search_word =~ /@(\w+)/
                target_col = "twitter_twtid"
                search_word = $1
            elsif search_word =~ %r!www\.twitter\.com/(\d+)!
                target_col = "twitter_twtid"
                search_word = $1
            else
                target_col = "twtname"
            end
        end

        if match_method == "auto"
            case target_col
            when "twitter_twtid"
                #match_method = "perfect_match"
                match_method = "partial_match"
            else
                match_method = "partial_match"
            end
        end

        puts %!#{target_col}, #{search_word}, #{match_method}!

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
        ["#{target_col} LIKE?", search_word_p]
    end

    def twt_screen_name
        if twtname == ""
            return ""
        else
            return twtname
        end
    end

    def last_dl_datetime_disp
        get_date_info(last_dl_datetime)
    end

    def last_access_datetime_disp
        get_date_info(last_access_datetime)
    end

    def twt_user_url
        Twt::twt_user_url(twtid)
    end

    def get_pic_filelist
        Twt::get_pic_filelist(twtid)
    end

    def prediction
        if update_frequency.presence
            delta_d = get_date_delta(last_access_datetime)# + 1 #1日分足す
            pred = update_frequency * delta_d / 100
            pred
        else
            pred = 33
        end
    end
end
