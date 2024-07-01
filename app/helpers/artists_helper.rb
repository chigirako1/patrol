module ArtistsHelper

    def pxvname_tag(artist)
        tag = artist.pxvname
        if artist.append_info != nil and artist.append_info != ""
            tag += %!【#{artist.append_info}】!
        end
        if artist.altname != ""
            tag += "<br />"
            tag += "別名:(#{artist.altname})"
        end
        if artist.oldname != ""
            tag += "<br />"
            tag += "旧名:(#{artist.oldname})"
        end
        if artist.circle_name != ""
            tag += "<br />"
            tag += "【#{artist.circle_name}】"
        end
        if artist.reverse_status.presence
            tag += "<br />"
            tag += "[#{artist.reverse_status}]"
        end
        tag += "<br />"
        tag += "("
        tag += link_to_ex(artist["pxvid"], artist.pxv_user_url)
        tag += ")"
        tag += "<br />"

        tag.html_safe
    end

    def priority_tag(artist)
        tag = ""
        if artist.rating == 0
            tag = %!<td align="right" bgcolor="orange">!
        elsif artist["priority"] > 0
            tag = %!<td align="right" bgcolor="yellow">!
        elsif artist["priority"] < 0
            tag = %!<td align="right" bgcolor="gray">!
        else
            tag = %!<td align="right">!
        end
        tag += %!【#{artist.rating}】!
        if artist.r18.presence
            tag += %!#{artist.r18}<br />!
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
        #tag += %!#{work_list.size}!

        if append_txt
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

    def pre_bgcolor(pred_cnt, threshold=2)
        if pred_cnt == 0
            bgcolor = "grey"
        elsif pred_cnt > threshold
            bgcolor = "orange"
        else
            bgcolor = "beige"
        end
        bgcolor
    end
end
