module TwittersHelper
    def artist_status_tag(artist)
        if artist.status.presence
            txt = "※" + artist.status
            tag = %!<b>#{txt}</b>!
            tag
        else
            tag = ""
        end
        tag.html_safe
    end
end
