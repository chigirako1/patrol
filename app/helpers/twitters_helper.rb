
module TwittersHelper
    def artist_status_tag(artist)
        tag = ""

        tag += %!最新UL:#{artist.last_ul_datetime_disp}!

        if artist.status.presence
            txt = "※" + artist.status
            tag += %!<b>#{txt}</b>!
        end

        if artist.reverse_status.presence
            txt = artist.reverse_status
            tag += %!|#{txt}!
        end
        
        tag.html_safe
    end
end
