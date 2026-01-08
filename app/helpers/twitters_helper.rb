
module TwittersHelper
    DM_AI_ICON = ApplicationHelper::DM_AI_ICON#"🤖"
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
        tag += PRIVATE_ICON if twt.private_account == Twitter::TWT_VISIBILITY::TV_PRIVATE
        tag += %!#{twt.rating}|#{twt.r18}#{R18_ICON if twt.r18 == Twitter::RESTRICT::R18}|#{dm_disp(twt.drawing_method)}|#{twt.status}!
        tag += "】"
        tag += %![#{link_to_ex("■twt■", twt)}]!
        tag += %!|A:#{twt.last_access_datetime_disp}!
        tag += %!|U:#{Util.get_date_info twt.last_post_datetime}!
        tag += %!|#{PXV_ICON}:#{twt.pxvid}! if twt.pxvid.presence
        tag += %!|予測:#{twt.prediction}!

        tag.html_safe
    end

    def dm_disp(dm)
        dm.to_s + dm_icon(dm)
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

    def twitter_index_page_title(twitters_group, total_count, num_of_disp)
        cnt = twitters_group.sum {|k,v| v.count}
        if total_count.presence
            twitters_total_count = total_count
        else
            twitters_total_count = -1
        end

        rem = twitters_total_count - num_of_disp
        if rem > 0
            rem_str = %!/残り#{rem}件!
        end

        if params[:mode] == TwittersController::ModeEnum::SEARCH
            page_title = "twt検索:「#{params[:search_word]}」(#{cnt}件)"
        elsif twitters_total_count < 0
            page_title = "#{params[:page_title]}"
        elsif total_count
            page_title = "#{params[:page_title]} (#{cnt}/#{total_count}件)"
        else
            page_title = "#{params[:page_title]} (#{cnt}/#{twitters_total_count}件#{rem_str}) a"
        end
        
        page_title += " - TWT一覧"
    end

    def twitter_show_page_title(twitter, r18=false)
        title = ""

        if twitter.private_account == Twitter::TWT_VISIBILITY::TV_PRIVATE
            title += PRIVATE_ICON
        end

        title += dm_icon(twitter.drawing_method)
        title += %!【#{twitter.rating}!

        if r18 and twitter.r18
            title += "|" + twitter.r18
        end

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
        str = twitter_show_page_title(twitter, true)
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
