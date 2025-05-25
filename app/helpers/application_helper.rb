
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

    def yellow_shade(value)
        # 100以上なら完全な黄色
        #return "#FFFF00" if value >= 100
        
        # 15以下ならごく薄い黄色
        #return "#111100" if value <= 15

        # 15～99の範囲で黄色の濃淡を計算
        # RとGの値を調整（線形補間を利用）
        #intensity = ((value - 15) * (255 - 17) / (100 - 15) + 17).to_i
        #hex_value = intensity.to_s(16).rjust(2, '0').upcase
        #"##{hex_value * 2}00"

        min = 15
        max = 100
        # 15〜99 の間で B（青）の値を線形補間
        #blue_intensity = ((value - 15) * (0 - 204) / (100 - 15) + 204).to_i
        blue_intensity = ((value - min) * (0 - 204) / (max - min) + 204).to_i
        blue_hex = blue_intensity.to_s(16).rjust(2, '0').upcase
         "#FFFF#{blue_hex}"
    end

    def pred_bg_color(pred)
        if pred < 1
            bgcolor = "grey"
        elsif pred > 15
            #bgcolor = "khaki"
            bgcolor = yellow_shade(pred)
        else
            bgcolor = "beige"
        end
        bgcolor
    end
end
