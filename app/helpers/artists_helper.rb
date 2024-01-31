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
        #tag += %!#{artist.rating}<br />[#{artist.priority}]!
        tag += %!#{artist.rating}<br />!
        if artist.r18.presence
            tag += %!#{artist.r18}<br />!
        end
                
        tag += %!</td>!
        tag.html_safe
    end

    def pic_path_tag(pxvid, no_of_disp, scale='15%')
        tag = ""
        pathlist = Pxv::get_pathlist(pxvid)
        work_list = Artist.artwork_list(pathlist)
        work_list.first(no_of_disp).each do |artwork_id, data|
            path = data[0]
            tag += link_to(image_tag(path, width: scale, height: scale), path, target: :_blank, rel: "noopener noreferrer")
        end

        #pathlist.first(no_of_disp).each do |path|
            #tag += link_to(image_tag(path, width: scale, height: scale), path, target: :_blank, rel: "noopener noreferrer")
        #end
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

end
