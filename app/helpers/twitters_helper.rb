
module TwittersHelper
    DM_AI_ICON = ApplicationHelper::DM_AI_ICON
    DM_HAND_ICON = "✍️"
    DM_THIEF_ICON = "😎"

    R18_ICON = ApplicationHelper::R18_ICON #"🔞"
    PXV_ICON = ApplicationHelper::PXV_ICON #"🅿️"
    PRIVATE_ICON = ApplicationHelper::PRIVATE_ICON #"🔒️"

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

    def twitter_link_tag(twtid)
        tag = ""
        if twtid.presence
            tag = "▷" + link_to_ex("@#{twtid}", Twt::twt_user_media_url(twtid))
        end
        tag.html_safe
    end

    def twitter_info_tag_ex(twtid, br=false, unregist=false)
        twt = Twitter.find_by_twtid_ignore_case(twtid)
        if twt
            tag = twitter_info_tag(twt)
            #if twt.sp?
            if twt.sp? and (twt.rating and twt.rating >= Twt::RATING_THRESHOLD)
                tag = %!<h3>SP対象？</h3>! + tag
            elsif twt.filesize_huge?
                tag = %!<b>ファイルサイズ大</b>! + tag
            elsif br
                tag = "<br />" + tag
            end
            tag.html_safe
        elsif twtid.presence
            tag = ""
            user_exist = Twt::user_exist?(twtid)
            if user_exist
                tag += "※フォルダあり※"
            end
            tag += %![#{link_to_ex("☆twt☆:@#{twtid}", artist_twt_path(twtid))}]!
            tag += "<br />★★★DB未登録★★" if unregist

            pxv = Artist.find_by(twtid: twtid)
            if pxv
                tag += "※pxvに登録あり→"
                tag += %![#{link_to_ex("■pxv■(#{pxv.pxvname})", pxv)}]!
            end

            tag.html_safe
        end
    end

    def twitter_info_tag(twt)
        tag = ""

        tag += %!#{dm_disp(twt.drawing_method)}!
        tag += "【"
        tag += %!#{twt.rating}|#{twt.r18}#{r_icon(twt.r18)}!
        tag += "】"
        tag += %!"#{twt.twtname}"!
        tag += "【"
        tag += PRIVATE_ICON if twt.private?
        tag += %!#{twt.status}!
        if twt.status == Twitter::TWT_STATUS::STATUS_SCREEN_NAME_CHANGED or twt.status == Twitter::TWT_STATUS::STATUS_ANOTHER
            tag += %!(→#{twt.new_twtid})!
        end
        tag += "】"
        tag += %![#{link_to_ex("■twt■", twt)}]!
        tag += %!|A:#{smart_date twt.last_access_datetime}(#{twt.last_access_datetime_disp})!
        tag += %!|予測:<b>#{twt.prediction}</b>!
        tag += %!|U:#{Util.get_date_info twt.last_post_datetime}!
        tag += %!|ファイル数:#{twt.filenum}!
        tag += %!(頻度:#{twt.update_frequency})!
        tag += %!|#{PXV_ICON}:#{twt.pxvid}! if twt.pxvid.presence

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
        when Twitter::DRAWING_METHOD::DM_REPRINT
            icon = DM_THIEF_ICON
        else
            icon = ""
        end
    end

    def r_icon(restr)
        case restr
        when Twitter::RESTRICT::R18
            r_icon = R18_ICON
        when Twitter::RESTRICT::R15
            r_icon = ApplicationHelper::R15_ICON
        else
            r_icon = ""
        end
    end

    def restr_disp(restr)
        str = r_icon(restr)
        if str == ""
            str += "|" + (restr||"")
        end
        str
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

        if params[:rating].presence
            prm_rat = %![#{params[:rating]}↑]! unless params[:rating] == "0"
        end

        prm_page_title = params[:page_title]
        if params[:mode] == TwittersController::ModeEnum::SEARCH
            page_title = "#{prm_page_title}「#{params[:search_word]}」(#{cnt}件)"
        elsif twitters_total_count < 0
            page_title = "#{prm_page_title}"
        elsif total_count
            page_title = "#{prm_page_title} (#{cnt}/#{total_count}件)"
        else
            page_title = "#{prm_page_title} (#{cnt}/#{twitters_total_count}件#{rem_str})"
        end
        
        ApplicationHelper::TWT_ICON + "#{prm_rat}#{page_title} - TWT一覧"
    end

    def twitter_show_page_title(twitter, r18=false)
        title = ""

        if twitter.private?#_account == Twitter::TWT_VISIBILITY::TV_PRIVATE
            title += PRIVATE_ICON
        end

        title += dm_icon(twitter.drawing_method)
        title += %!【#{twitter.rating}!

        if r18 and twitter.r18
            title += "|" + twitter.r18
        end
        title += r_icon(twitter.r18)
        if twitter.pxvid.presence
            title += PXV_ICON
        end
        title += %!】!
        title += %!#{twitter.twtname}(@#{twitter.twtid})!
        ApplicationHelper::TWT_ICON + title
    end

    def twitter_show_header_str(twitter)
        str = twitter_show_page_title(twitter, true)

        if twitter.old_twtid.presence
            str += %!←#{twitter.old_twtid}!
        end

        if twitter.new_twtid.presence
            str += %!→#{twitter.new_twtid}!
        end

        if twitter.max_interval.presence or twitter.fetch_pred_n.presence
            str += %![MAX:#{twitter.max_interval}|#{twitter.fetch_pred_n}]!
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
