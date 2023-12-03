class Twitter < ApplicationRecord
    include UrlTxtReader

    belongs_to :artists, :class_name => 'Artist', optional: true

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

    def prediction
        pred = 1

        if update_frequency.presence
            delta_d = get_date_delta(last_access_datetime)
            pred = update_frequency * delta_d / 100
        else
        end

        pred
    end
end
