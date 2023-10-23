module ArtistsHelper

    def pxvname_tag(artist)
        tag = artist.pxvname
        if artist.altname != ""
            tag += "<br />"
            tag += "alt:(#{artist.altname})"
        end
        if artist.oldname != ""
            tag += "<br />"
            tag += "old:(#{artist.oldname})"
        end
        tag.html_safe
    end

    def priority_tag(artist)
        tag = ""
        if artist["priority"] > 0
            tag += %!<td align="right" bgcolor="yellow">!
        elsif artist["priority"] < 0
            tag += %!<td align="right" bgcolor="gray">!
        else
            tag += %!<td align="right">!
        end
        tag += %!#{artist.priority}<br />#{artist.rating}</td>!
        tag.html_safe
    end

    def pic_path_tag(pxvid, no_of_disp)
        tag = ""
        pathlist = Artist.get_pathlist("(#{pxvid})")
        pathlist.first(no_of_disp).each do |path|
            #tag += image_tag path, width: '15%', height: '15%'
            tag += link_to image_tag(path, width: '15%', height: '15%'), path, target: :_blank, rel: "noopener noreferrer"
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
end
