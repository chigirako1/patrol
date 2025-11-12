
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
        tag += %!|予測:#{twt.prediction}!

        tag.html_safe
    end

    def twitter_show_page_title(twitter)
        title = ""

        case twitter.drawing_method
        when Twitter::DRAWING_METHOD::DM_AI
            title += "🤖"
        when Twitter::DRAWING_METHOD::DM_HAND
            #title += twitter.drawing_method[0]
            title += "✍️"
        else
        end

        title += %!【#{twitter.rating}!
        if twitter.r18 == "R18"
            title += "🔞"
        end
        if twitter.pxvid.presence
            title += "🅿️"
        end
        title += %!】!
        title += %!#{twitter.twtname}(@#{twitter.twtid})!
        title
    end

    def twitter_show_header_str(twitter)
        #str = %![#{twitter.rating}|#{twitter.r18}] #{twitter.twtname} (@#{twitter.twtid})!
        str = twitter_show_page_title(twitter)
        if twitter.old_twtid.presence
            str += %!←#{twitter.old_twtid}!
        end
        if twitter.new_twtid.presence
            str += %!→#{twitter.new_twtid}!
        end
        str
    end
end
