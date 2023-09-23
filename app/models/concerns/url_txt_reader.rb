
module UrlTxtReader
    extend ActiveSupport::Concern

    def get_ulrs(txts)
        id_list = []
        twt_urls = {}
        misc_urls = []

        txts.each do |line|
            line.chomp!
            next if line =~ /^$/
    
            if line =~ %r!https?://www\.pixiv\.net/users/(\d+)!
                user_id = $1.to_i
                id_list.push user_id
            elsif line =~ %r!((https?://twitter\.com/(\w+)))$! or line =~ %r!((https?://twitter\.com/(\w+))/.*)!
                url = $1
                #twt_user_url = $2
                twt_id = $3

                #https://twitter.com/258shin/status/1643549775860727809?t=3vLfQP1QuY67a_OGa9RPMw&s=19
                if url =~ %r!(https?://twitter\.com/\w+/status/\d+)\?.*!
                    #twt_urls.push($1)
                    #twt_urls.push($1 + "/photo/1")
                end

                if twt_urls.has_key? twt_id
                    twt_urls[twt_id] << line
                else
                    twt_urls[twt_id] = []
                    twt_urls[twt_id] << line
                end

                artist = Artist.find_by(twtid: twt_id)
                if artist != nil
                    id_list << artist.pxvid unless id_list.include? (artist.pxvid)
                end
            elsif line =~ %r!(https?://.*)!
                url = $1
                misc_urls.push url
            end
        end
        [id_list, twt_urls, misc_urls]
    end
end