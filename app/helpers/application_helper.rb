
module ApplicationHelper
    BASE_TITLE = "巡回app".freeze
    
    DM_AI_ICON = "🤖"
    DM_HAND_ICON ="✍️"
    R18_ICON = "🔞"
    PXV_ICON = "🅿️"
    TWT_ICON = "🆃" #X
    PRIVATE_ICON = "🔒️"
    SEARCH_EMOJI = "🔍️"

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

    def get_val(orig_val, target_symbol)
        if orig_val.presence
            val = orig_val
        elsif params[:target_symbol].presence
            val = params[:target_symbol]
        else
            val = ""
        end
        val
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

    def yellow_shade(value)
        # 100以上なら完全な黄色
        return "#FFFF00" if value >= 100
        
        # 15以下ならごく薄い黄色
        #return "#111100" if value <= 15

        base = 204#255#204
        min = 15
        max = 100

        # 15〜99 の間で B（青）の値を線形補間
        blue_intensity = ((value - min) * (0 - base) / (max - min) + base).to_i
        blue_hex = blue_intensity.to_s(16).rjust(2, '0').upcase
        #STDERR.puts %!#{value}=>"#{blue_intensity}(##{blue_hex})"!
         "#FFFF#{blue_hex}"
    end

    def pred_bg_color(pred)
        if pred < 1
            bgcolor = "grey"
        elsif pred > 10
            #bgcolor = "khaki"
            bgcolor = yellow_shade(pred)
        else
            bgcolor = "beige"
        end
        bgcolor
    end

    def percent_star(percent)
        n10 = percent / 10
        n2 = (percent - (n10 * 10)) / 2
        %!#{"★" * n10}#{"*" * n2}!
    end

    def smart_date(date)
        return "" if date.blank?
    
        if date.year == Date.current.year
            if date.today?
                "今日(#{date.strftime("%-m月%-d日")})"
            else
                date.strftime("%-m月%-d日")
            end
        else
            date.strftime("%Y年%-m月%-d日")
        end
    end
end
