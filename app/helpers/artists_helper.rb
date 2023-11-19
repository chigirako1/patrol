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
        if artist["priority"] > 0
            tag += %!<td align="right" bgcolor="yellow">!
        elsif artist["priority"] < 0
            tag += %!<td align="right" bgcolor="gray">!
        else
            tag += %!<td align="right">!
        end
        tag += %!#{artist.rating}<br />[#{artist.priority}]</td>!
        tag.html_safe
    end

    def pic_path_tag(pxvid, no_of_disp)
        tag = ""
        pathlist = Artist.get_pathlist(pxvid)
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

    def twt_path_str(path)
        fn = File.basename path

        twtid = 0
        if fn =~ /(\d+)\s(\d+)\s(\d+\-\d+\-\d+)/
            #puts fn
            twtid = $1.to_i
            pic_no = $2.to_i
        elsif fn =~ /(\d+)\s(\d+)\s(\d+)/
            #9715239224554008999 0 2023-11-12
            dl_date_str = $1
            begin
                #dl_date = Date.parse(dl_date_str)
            rescue Date::Error => ex

            end
            twtid = $2.to_i
            pic_no = $3.to_i
        else
        end

        if twtid != 0
            ul_datestr = Artist.timestamp_str(twtid)
            date_str = %!【#{ul_datestr}】!
        else
            fullpath = Rails.root.join("public/" + path)
            mtime = File::mtime(fullpath)
            date_str = %![#{mtime.strftime("%Y-%m-%d")}]!
        end
        date_str + %! (#{fn})(#{File.dirname path})!
    end

end
