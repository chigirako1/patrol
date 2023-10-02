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
end
