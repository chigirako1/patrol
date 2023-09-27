module ArtistsHelper

    def pic_path_tag(pxvid, no_of_disp)
        tag = ""
        pathlist = Artist.get_pathlist("(#{pxvid})")
        pathlist.first(no_of_disp).each do |path|
            tag += image_tag path, width: '15%', height: '15%'
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
end
