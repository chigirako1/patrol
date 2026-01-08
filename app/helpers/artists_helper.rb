module ArtistsHelper

    DM_AI_ICON = ApplicationHelper::DM_AI_ICON
    DM_HAND_ICON = ApplicationHelper::DM_HAND_ICON
    R18_ICON = ApplicationHelper::R18_ICON
    PXV_ICON = ApplicationHelper::PXV_ICON
    PRIVATE_ICON = ApplicationHelper::PRIVATE_ICON

    def r18_disp(restr)
        if restr == Artist::RESTRICT::R18
            r18_icon = R18_ICON
        else
            r18_icon = ""
        end

        (restr||"") + r18_icon
    end

    def feature_icon(feat)
        case feat
        when Artist::FEATURE::AI
            icon = DM_AI_ICON
        when Artist::FEATURE::HAND, nil
            #icon = DM_HAND_ICON
            icon = ""
        else
            icon = ""
        end
    end
    
    def feature_disp(feat)
        (feat||"") + feature_icon(feat)
    end

    def page_title(artist)
        feature = feature_icon(artist.feature)

        if artist.twtid.presence
            twt = ""
        else
            #twt = %!@\!!
            twt = %!❗️!
        end
        
        r = r18_disp(artist.r18)

        feature + twt + %![#{artist.rating}]#{artist.pxvname}【#{r}】!
    end

    def page_header(artist)
        if artist.furigana != ""
            furigana = %![#{artist.furigana}]! 
        end

        altname = %!/別名"#{artist.altname}"! if artist.altname.presence
        oldname = %!/旧名"#{artist.oldname}"! if artist.oldname.presence
        circle_name = %!/サークル名："#{artist.circle_name}"! if artist.circle_name.presence

        %!#{feature_icon(artist.feature)}【#{artist.rating}|#{r18_disp(artist.r18)}】#{artist.pxvname}(#{artist.pxvid})#{furigana}#{altname}#{oldname}#{circle_name}!
    end

    def pxvname_tag(artist)
        tag = %!<b>#{artist.pxvname}</b>!
        if artist.append_info != nil and artist.append_info != ""
            tag += %!【#{artist.append_info}】!
        end
        if artist.altname.presence
            tag += "<br />"
            tag += "別名:(#{artist.altname})"
        end
        if artist.oldname.presence
            tag += "<br />"
            tag += "旧名:(#{artist.oldname})"
        end
        if artist.circle_name.presence
            tag += "<br />"
            tag += "【#{artist.circle_name}】"
        end
=begin
        if artist.reverse_status.presence
            tag += "<br />"
            tag += "[#{artist.reverse_status}]"
        end
=end
        tag += "<br />"

        tag += "("
        #tag += link_to_ex(artist["pxvid"], artist.pxv_user_url)
        tag += %!#{artist.pxvid}!
        tag += ")"

        tag += "<br />"

        tag.html_safe
    end

    def priority_tag(artist)
        tag = ""
        if artist.rating == 0
            bgcolor = "orange"
=begin
        elsif artist.priority > 0
            bgcolor = "yellow"
        elsif artist.priority < 0
            bgcolor = "gray"
=end
        elsif artist.rating < 75
            bgcolor = "lightgray"
        else
        end

        tag += %!<td bgcolor="#{bgcolor}">!
        tag += feature_disp(artist.feature)
        tag += %!【#{artist.rating}】!
        if artist.r18.presence
            tag += %!#{r18_disp(artist.r18)}<br />!
        end
                
        tag += %!</td>!
        tag.html_safe
    end

    def pic_path_tag(pxvid, no_of_disp, scale='15%', append_txt=false)
        tag = ""
        pathlist = Pxv::get_pathlist(pxvid)
        work_list = Artist.artwork_list(pathlist)
        work_list.first(no_of_disp).each do |artwork_id, data|
            path = data[0]
            tag += link_to(image_tag(path, width: scale, height: scale), path, target: :_blank, rel: "noopener noreferrer")
        end

        if append_txt
            tag += %!#{work_list.size}!
            tag += %!</br>!
            pathlist.first(1).each do |path|
                tag += link_to(path, path, target: :_blank, rel: "noopener noreferrer")
            end
        end
        tag.html_safe
    end

    def get_url_params
        s = ""
        params.each do |k,v|
            s += "&#{k}=#{v}"
        end
        s[1..-1]
    end

    def date_diff?(artist, date_str)
        artist.last_ul_datetime.in_time_zone('Tokyo').strftime("%y-%m-%d") != date_str
    end

    def pre_bgcolor(pred_cnt, threshold1, threshold2)
        if pred_cnt == 0
            bgcolor = "grey"
        elsif pred_cnt >= threshold1
            bgcolor = "yellow"
        elsif pred_cnt >= threshold2
            bgcolor = "orange"
        else
            bgcolor = "beige"
        end
        bgcolor
    end

    def pre_bgcolor_ex(pred_cnt)
        if pred_cnt >= 30
            bgcolor = "pink"
        elsif pred_cnt >= 20
            bgcolor = "#FFFF00"#"yellow"
        elsif pred_cnt >= 10
            bgcolor = "#DDDD44"
        elsif pred_cnt >= 5
            bgcolor = "lightskyblue"#"#999900"
        elsif pred_cnt == 0
            bgcolor = "grey"
        else
            bgcolor = "beige"
        end
        bgcolor
    end

    def date_bg_color(dayn)
        if dayn < 7
            bgcolor = "palegreen"
        elsif dayn < 30
            bgcolor = "Lime"
        elsif dayn > 365 * 2
            bgcolor = "darkred"
        elsif dayn > 365
            bgcolor = "red"
        elsif dayn > 180
            bgcolor = "yellow"
        elsif dayn > 90
            bgcolor = "khaki"
        else
            bgcolor = "beige"
        end
        bgcolor
    end

    def access_date_bg_color(dayn, pred)
        if pred > 5
            bgcolor = "pink"
        elsif pred == 0
            bgcolor = "gray"
        else
            if dayn < 7
                bgcolor = "lightgray"
            elsif dayn > 365
                bgcolor = "red"
            elsif dayn > 180
                bgcolor = "yellow"
            elsif dayn > 90
                bgcolor = "khaki"
            else
                bgcolor = "beige"
            end
        end
        bgcolor
    end
end
