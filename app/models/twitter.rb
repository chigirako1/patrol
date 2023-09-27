class Twitter < ApplicationRecord
    belongs_to :artists, :class_name => 'Artist', optional: true

    def twt_screen_name
        if twtname == ""
            return "show"
        else
            return twtname
        end
    end
end
