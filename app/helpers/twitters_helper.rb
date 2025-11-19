
module TwittersHelper
    DM_AI_ICON = "🤖"
    DM_HAND_ICON ="✍️"
    R18_ICON = "🔞"
    PXV_ICON = "🅿️"
    PRIVATE_ICON = "🔒️"

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

    def dm_icon(dm)
        case dm
        when Twitter::DRAWING_METHOD::DM_AI
            icon = DM_AI_ICON
        when Twitter::DRAWING_METHOD::DM_HAND
            icon = DM_HAND_ICON
        else
            icon = ""
        end
    end

    def twitter_show_page_title(twitter)
        title = ""

        if twitter.private_account == Twitter::TWT_VISIBILITY::TV_PRIVATE
            title += PRIVATE_ICON
        end

        title += dm_icon(twitter.drawing_method)
        title += %!【#{twitter.rating}!

        if twitter.r18 == Twitter::RESTRICT::R18
            title += R18_ICON
        end
        if twitter.pxvid.presence
            title += PXV_ICON
        end
        title += %!】!
        title += %!#{twitter.twtname}(@#{twitter.twtid})!
        title
    end

    def twitter_show_header_str(twitter)
        str = twitter_show_page_title(twitter)
        if twitter.old_twtid.presence
            str += %!←#{twitter.old_twtid}!
        end
        if twitter.new_twtid.presence
            str += %!→#{twitter.new_twtid}!
        end
        str
    end

    def tw_build_select_list(ary)
        ary.map {|x| [x, x]}
    end

    def tw_visibility_list
        list = [
            Twitter::TWT_VISIBILITY::TV_OPEN,
            Twitter::TWT_VISIBILITY::TV_PRIVATE,
        ]
        tw_build_select_list(list)
    end
end
