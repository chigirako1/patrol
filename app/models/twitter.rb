class Twitter < ApplicationRecord
    include UrlTxtReader

    validates :twtid, uniqueness: true

    belongs_to :artists, :class_name => 'Artist', optional: true

    module TWT_STATUS
        STATUS_PATROL = "TWT巡回"
        STATUS_NO_PATROL = "TWT巡回不要"
        STATUS_NO_UPDATE_LT = "長期更新なし"
        STATUS_NO_PATROL_PXV_CHECK = "TWT巡回不要(PXVチェック)"
        STATUS_NO_UPDATE_IM = "最近更新してない？"
        STATUS_DELETED = "削除"
        STATUS_NOT_EXIST = "存在しない"
        STATUS_FROZEN = "凍結"
        STATUS_PRIVATE = "非公開アカウント"
        STATUS_WAITING = "フォロー許可待ち"
        STATUS_ANOTHER = "別アカウントに移行"
        STATUS_SCREEN_NAME_CHANGED = "アカウントID変更"
    end

    module DRAWING_METHOD
        DM_HAND = "手描き"
        DM_AI = "AI"
        DM_3D = "3D"
        DM_REPRINT = "パクリ"
    end

    module SEARCH_TARGET
        AUTO = "(自動判断)"
        TWT_TWTID = "twitter_twtid"
        TWT_TWTNAME = "twtname"
    end

    module MATCH_METHOD
        AUTO = "auto"
        PARTIAL_MATCH = "partial_match"
        PERFECT_MATCH = "perfect_match"
        BEGIN_MATCH = "begin_match"
        END_MATCH = "end_match"
    end

    def self.find_by_twtid_ignore_case(twtid, ignore=true)
        if twtid == nil
            return nil
        end

        if ignore
            records = Twitter.where('UPPER(twtid) = ?', twtid.upcase)
            if records.size > 1
                msg = %!"@#{twtid}":#{records.size}件のレコードが見つかりました =>!
                STDERR.puts msg
                Rails.logger.warn(msg)
                records.each do |x|
                    STDERR.puts %!\t"#{x.twtname}"(@#{x.twtid})!
                end
            end
            records.first
        else
            Twitter.find_by(twtid: twtid)
        end
    end

    def self.looks(target_col, search_word, match_method)
        search_word.strip!
        puts %!["#{target_col}", "#{search_word}", "#{match_method}"]!

        if target_col == SEARCH_TARGET::AUTO
            if search_word =~ /^\w+$/
                target_col = SEARCH_TARGET::TWT_TWTID
            elsif search_word =~ /@(\w+)/
                target_col = SEARCH_TARGET::TWT_TWTID
                search_word = $1
            elsif search_word =~ %r!twitter\.com/(\w+)! or
                search_word =~ %r!x\.com/(\w+)!
                target_col = SEARCH_TARGET::TWT_TWTID
                search_word = $1
            else
                target_col = SEARCH_TARGET::TWT_TWTNAME
            end
        end

        if match_method == MATCH_METHOD::AUTO
            case target_col
            when SEARCH_TARGET::TWT_TWTID
                #match_method = "perfect_match"
                match_method = MATCH_METHOD::PARTIAL_MATCH
            else
                match_method = MATCH_METHOD::PARTIAL_MATCH
            end
        end

        puts %!#{target_col}, #{search_word}, #{match_method}!

        search_word_p = ""
        case match_method
        when MATCH_METHOD::PERFECT_MATCH
            search_word_p = search_word
        when MATCH_METHOD::BEGIN_MATCH
            search_word_p = "#{search_word}%"
        when MATCH_METHOD::END_MATCH
            search_word_p = "%#{search_word}"
        when MATCH_METHOD::PARTIAL_MATCH
            search_word_p = "%#{search_word}%"
        else
            search_word_p = search_word
        end
        col = "#{target_col} LIKE?"
        puts %!対象="#{col}"\t検索ワード="#{search_word_p}"!
        [col, search_word_p]

        #[%!#{SEARCH_TARGET::TWT_TWTID} LIKE? OR #{SEARCH_TARGET::TWT_TWTNAME} LIKE?!, [search_word, search_word]]
    end

    def self.all_twt_id_list()
        ids = Twitter.all.map {|x| x.twtid}
    end

    def self.get_unregisterd_pxv_user_id_list()
        unregisterd_pxv_user_id_list = []
        
        pxvids_in_twt_table = Twitter.select('pxvid').map {|x| x.pxvid}.compact.sort.uniq
        pxvids_in_twt_table.each do |pxvid|
            p = Artist.find_by(pxvid: pxvid)
            if p
            else
                puts %!PXV DB未登録:"#{pxvid}"!
                unregisterd_pxv_user_id_list << pxvid
            end
        end
        unregisterd_pxv_user_id_list
    end

    def self.unassociated_pxv_uids()
        unassociated_pxv_uids = []
        
        pxvids_in_twt_table = Twitter.select('pxvid').map {|x| x.pxvid}.compact.sort.uniq
        pxvids_in_twt_table.each do |pxvid|
            p = Artist.find_by(pxvid: pxvid)
            if p
                if p.twtid.presence
                else
                    unassociated_pxv_uids << pxvid
                end
            else
            end
        end
        unassociated_pxv_uids
    end

    def self.unassociated_twt_screen_names()
        unassociated_twt_screen_names = []
        
        twtids_in_pxv_table = Artist.select('twtid').map {|x| x.twtid}.compact.sort.uniq
        twtids_in_pxv_table.each do |twtid|
            t = Twitter.find_by(twtid: twtid)
            if t
                if t.pxvid.presence
                else
                    unassociated_twt_screen_names << twtid
                end
            else
            end
        end
        unassociated_twt_screen_names
    end

    def self.twt_user_classify(twt_url_infos, pxv_chk=true)
        pxvid_list = []
        registered_twt_acnt_list = {}
        unregistered_twt_acnt_list = {}
        twt_url_infos.each do |twt_id, twt_url_info|
            if pxv_chk
                pxv = Artist.find_by_twtid_ignore_case(twt_id)
                ignore_case = true
            else
                pxv = nil
                ignore_case = false
            end
            twt = Twitter.find_by_twtid_ignore_case(twt_id, ignore_case)
            if twt and pxv
                case pxv.status
                when ArtistsController::Status::DELETED
                when ArtistsController::Status::SUSPEND
                when ArtistsController::Status::SIX_MONTH_NO_UPDATS
                when ArtistsController::Status::SIX_MONTH_NO_UPDATS
                when ArtistsController::Status::ACCOUNT_MIGRATION
                when ArtistsController::Status::NO_ARTWORKS
                    registered_twt_acnt_list[twt_id] = twt_url_info.url_list
                else
                    pxvid_list << pxv.pxvid
                end
            elsif pxv
                pxvid_list << pxv.pxvid
            elsif twt
                registered_twt_acnt_list[twt_id] = twt_url_info.url_list
            else
                unregistered_twt_acnt_list[twt_id] = twt_url_info.url_list
            end
        end

        [registered_twt_acnt_list, unregistered_twt_acnt_list, pxvid_list]
    end
    
    def self.twt_build_group(twt_url_list)
        list = []
        twt_url_list.each do |screen_name, url_list|
            twt = Twitter.find_by_twtid_ignore_case(screen_name)

            if twt.pxvid.presence
                pxv = Artist.find_by(pxvid: twt.pxvid)
            else
                pxv = Artist.find_by(twtid: twt.twtid)
            end

            list << [screen_name, url_list, twt, pxv]
        end
        list.sort_by {|x|
            url_list = x[1];
            twt = x[2];
            pxv = x[3];
            pxv_exist = pxv == nil ? 0:1;
            pxv_e = [];
            #pxv_e = [pxv.status||"", pxv.last_access_datetime||""] if pxv;
            pxv_e = [pxv.status||"", -(pxv.rating||0)] if pxv;
            pxv_status = pxv.status if pxv;

            [
                pxv_exist,
                pxv_status||"",
                pxv_e,
                twt.status||"",
                -url_list.size,
                -(twt.rating || 0),
                twt.r18||"",
                twt.last_access_datetime||"",
                twt.last_post_datetime||"",
            ]
        }
    end

    def twt_screen_name
        twtname
=begin
        if twtname == ""
            return ""
        else
            return twtname
        end
=end
    end

    def last_dl_datetime_disp
        get_date_info(last_dl_datetime)
    end

    def last_access_datetime_disp
        get_date_info(last_access_datetime)
    end

    def last_access_datetime_days_elapsed
        get_date_delta(last_access_datetime)
    end

    def twt_user_url
        Twt::twt_user_url(twtid)
    end

    def get_pic_filelist(force_read_all=true)
        if filenum == nil or filenum < 500 or force_read_all
            read_archive = true
        else
            read_archive = false
        end
        Twt::get_pic_filelist(twtid, read_archive)
    end

    def get_pic_filelist_ex()
        list = get_pic_filelist
        list = list.map {|x| [Twt::twt_path_str(x), x]}.sort.reverse
        list = list.map {|x| x[1]}
        list
    end

    def prediction(datetime_arg=nil)
        if update_frequency.presence
            if datetime_arg == nil
                dt = last_access_datetime
            else
                dt = datetime_arg
            end
            delta_d = get_date_delta(dt)
            pred = update_frequency * delta_d / 100
            pred
        else
            pred = 33
        end
    end

    def sort_val
        if artist_pxvid.presence
            1
        else
            0
        end
    end

    def sort_cond(cnt)
        #[x.drawing_method||"", x.prediction, x.rating||0, x.last_access_datetime]}.reverse
        [
            drawing_method||"", 
            status||"", 
            rating||0, 
            #last_access_datetime,
            prediction,
            last_access_datetime,
            -(cnt),
            r18
        ]
    end

    def update_chk?
        pat = {
            TWT_STATUS::STATUS_PATROL => false,
            TWT_STATUS::STATUS_NO_PATROL => false,
            TWT_STATUS::STATUS_NO_UPDATE_LT => true,
            TWT_STATUS::STATUS_NO_PATROL_PXV_CHECK => false,
            TWT_STATUS::STATUS_NO_UPDATE_IM => true,
            TWT_STATUS::STATUS_DELETED => false,#存在しないのでチェック不能
            TWT_STATUS::STATUS_NOT_EXIST => false,#存在しないのでチェック不能
            TWT_STATUS::STATUS_FROZEN => true,#凍結は解除される場合がある？
            TWT_STATUS::STATUS_PRIVATE => true,#フォロー申請通った？
            TWT_STATUS::STATUS_WAITING => true,#フォロー申請通った？
            TWT_STATUS::STATUS_ANOTHER => true,#
            TWT_STATUS::STATUS_SCREEN_NAME_CHANGED => false,
        }

        if pat[status]
            true
        else
            false
        end
    end

    COND_DATA_HD = [
        #r, [pred, day, intvl]
        [95, [10,  40, 10]],
        [90, [10,  60, 20]],
        [85, [20,  90, 30]],
        [80, [30, 120, 40]],
        [70, [30, 150, 50]],
        [ 0, [60, 180,100]],
    ]
    COND_DATA_AI = [
        #r, [pred, day, intvl]
        [99, [30, 10, 1]],
        [98, [35, 15, 2]],
        [95, [40, 20, 3]],
        [91, [40, 25, 3]],
        #------------
        [90, [40, 25, 5]],
        #------------
        [89, [55, 30, 7]],
        [88, [60, 30, 7]],
        [87, [60, 30, 7]],
        [85, [65, 35, 10]],
        #------------
        [83, [75, 45, 15]],
        [82, [80, 50, 20]],
        [80, [90, 60, 20]],
        #------------
        [75, [100, 75, 25]],
        [70, [150, 90, 30]],
        #------------
        [60, [150, 120, 40]],
        [50, [150, 150, 50]],
        [10, [100, 360, 90]],
        [0,  [200, 360, 100]],
    ]
    def select_cond_aio(pred_cond_gt)
        if rating == nil
            return true
        end

        if drawing_method == DRAWING_METHOD::DM_AI
            cond_data = COND_DATA_AI
        else
            cond_data = COND_DATA_HD
        end

        cond_data.each do |x|
            rat = x[0]
            if rating >= rat
                pred = x[1][0]
                days = x[1][1]
                min_intvl = x[1][2]
                elapsed = last_access_datetime_days_elapsed

                if min_intvl > elapsed
                    STDERR.puts %!#{rating}:"#{twtname}(@#{twtid})":#{min_intvl} > #{elapsed}!
                    return false
                end

                if pred_cond_gt > 0 and prediction < pred_cond_gt
                end

                if prediction > pred
                    #STDERR.puts %!#{rating}:"#{twtname}(@#{twtid})":#{prediction}/#{last_access_datetime_days_elapsed}|#{pred}/#{days}!
                    return true
                end

                if elapsed > days
                    #STDERR.puts %!#{rating}:"#{twtname}(@#{twtid})":#{prediction}/#{last_access_datetime_days_elapsed}|#{pred}/#{days}!
                    return true
                end
            end
        end
        false
    end

    def select_cond_post_date
        num_of_days_elapased = get_date_delta(last_post_datetime)

        cond_day = num_of_days_elapased / 3
        #cond_day = 30
        if last_access_datetime_p(cond_day)
            #指定日以内にアクセスしているので対象外

            #STDERR.puts %!@#{twtid}[#{status}]:#{num_of_days_elapased}(#{cond_day}):最近更新してない・対象外!
            #STDERR.puts %![select_cond_post_date]@#{twtid}:\t\t#{num_of_days_elapased}(#{cond_day}):最近更新してない・対象外!
            false
        else
            true
        end
    end

    def select_cond_no_pxv(days = 150)
        if artists_last_ul_datetime.presence
        else
            return true
        end

        artists_last_access_dayn = Util::get_date_delta(artists_last_access_datetime)

        if (Util::get_date_delta(artists_last_ul_datetime) > days and
            artists_last_access_dayn > days)
            return true
        end

        false
    end

    def key_for_group_by
        case status
        when Twitter::TWT_STATUS::STATUS_PATROL
            case drawing_method 
            when DRAWING_METHOD::DM_REPRINT
                %!b:#{drawing_method}!
            else
                %!x:#{drawing_method}-#{rating}-#{r18}!
            end
        when nil
            "a:nil"
        when ""
            %!a:"()"!
        else
            %!a:"#{status}"!
        end
    end

    def group_key(count, rating_arg, add_count = false)
        
        if drawing_method == "パクリ"
            return drawing_method
        end

        case status
        when Twitter::TWT_STATUS::STATUS_PATROL
            if rating.presence
                case drawing_method
                when "AI"
                    #method = "102:AI"
                    method = "AI"
                when "パクリ"
                    #method = "101:paku"
                    method = "paku"
                else
                    #method = "109:手"
                    method = ""
                end
                
                days_accs = Util::get_date_delta(last_access_datetime)
                if days_accs < 2
                    key = %!080:2日以内!
                    add_count = false
                elsif days_accs < 7
                    #key = %!080:#{days_accs}日以内!
                    key = %!080:7日以内!
                    add_count = false
                    #return %!#{key}!
                elsif days_accs < 30
                    nweek = (days_accs + 6) / 7
                    key = %!090:#{nweek}週間以内!
                    add_count = false
                elsif days_accs > 365 #* 2
                    year = sprintf("%03d", days_accs / 365)
                    key = %!991:#{year}年以上!
                elsif days_accs > 90
                    month = sprintf("%03d", days_accs / 30)
                    key = %!990:#{month}ヶ月以上!
                else
                    month = sprintf("%03d", days_accs / 30)
                    #key = "901:評価#{rating}(#{month}ヶ月)"
                    key = "901:評価#{rating}"
                end
                #key = %!#{method}|#{key}!
            else
                key = "999.未設定(総ファイル数約#{(filenum||0) / 10}0-)"
            end
        when Twitter::TWT_STATUS::STATUS_NOT_EXIST
        when Twitter::TWT_STATUS::STATUS_FROZEN
        when Twitter::TWT_STATUS::STATUS_PRIVATE
            key = %!000:"#{status}"!
            #return %!#{key}!
        #when Twitter::TWT_STATUS::STATUS_SCREEN_NAME_CHANGED
        when "", nil
            days_accs = Util::get_date_delta(last_access_datetime)
            if days_accs < 30
                key = %!000:#{days_accs / 7}(総ファイル数約#{(filenum||0) / 10}0-)!
            else
                key = %!000:#{9}(総ファイル数約#{(filenum||0) / 10}0-)!
            end
        else
            key = %!000:"#{status}"(総ファイル数約#{(filenum||0) / 10}0-)!
        end

        if add_count
            key = sprintf("<%03d>:%s", count / 5 * 5, key)
        else
            key = sprintf("<%03d>:%s", 0, key)
        end

        if drawing_method == "手描き"
            key = %!手|#{key}!
        elsif drawing_method == ""
            key = %![未設定]|#{key}!
        else
            key = (drawing_method||"") + "|" + key
        end

        if rating and rating_arg > 0 and rating < rating_arg
            #key = "!評価規定以下|#{rating}|#{key}"
            key = "!評価規定以下|#{key}|#{rating}"
        end

        key
    end
end
