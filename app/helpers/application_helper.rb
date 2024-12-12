
module ApplicationHelper
    BASE_TITLE = "巡回app".freeze

    def full_title(page_title)
        if page_title.blank?
            BASE_TITLE
        else
            "#{page_title} - #{BASE_TITLE}"
        end
    end

    def link_to_ex(txt, link, newtab=true)
        if newtab
            link_to(txt, link, target: :_blank, rel: "noopener noreferrer")
        else
            link_to(txt, link)
        end
    end

    def td_date_bg_color(dayn)
        if dayn < 7
            #bgcolor = "palegreen"
            bgcolor = "grey"
        elsif dayn > 365 * 2
            bgcolor = "darkred"
        elsif dayn > 365
            bgcolor = "red"
        elsif dayn > 180
            bgcolor = "yellow"
        elsif dayn > 90
            bgcolor = "khaki"
        elsif dayn > 30
            bgcolor = "palegreen"
        else
            bgcolor = "beige"
        end
        bgcolor
    end
end
