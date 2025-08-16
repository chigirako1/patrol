
module TwittersHelper
    def twitter_status_tag(twt)
        tag = ""

        #tag += %!最新UL:#{twt.last_ul_datetime_disp}!

        if twt.status.presence
            txt = "※" + twt.status
            tag += %!<b>#{txt}</b>!
        end

        if twt.reverse_status.presence
            txt = twt.reverse_status
            tag += %!|#{txt}!
        end
        
        tag.html_safe
    end

    def twitter_info_tag(twt)
        tag = ""

        tag += %!"#{twt.twtname}"!
        tag += "【"
        tag += %!#{twt.rating}|#{twt.r18}|#{twt.drawing_method}|#{twt.status}!
        tag += "】"
        tag += %![#{link_to_ex("■twt■", twt)}]!
        tag += %!|A:#{twt.last_access_datetime_disp}!
        tag += %!|U:#{Util.get_date_info twt.last_post_datetime}!
        tag += %!|PXVID:#{twt.pxvid}! if twt.pxvid.presence

        tag.html_safe
    end
end
