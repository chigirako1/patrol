class Twitter < ApplicationRecord
    include UrlTxtReader

    validates :twtid, uniqueness: true
    belongs_to :artists, :class_name => 'Artist', optional: true

    TWT_H_SEPARATOR = "::"

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
        STATUS_WAITING = "フォロー許可待ち"#承認？
        STATUS_ANOTHER = "別アカウントに移行"
        STATUS_SCREEN_NAME_CHANGED = "アカウントID変更"
    end

    module TWT_VISIBILITY
        TV_OPEN = "公開"
        TV_PRIVATE = "非公開"
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
        TWT_ID_AND_NAME = "(both)"
    end

    module MATCH_METHOD
        AUTO = "auto"
        PARTIAL_MATCH = "partial_match"
        PERFECT_MATCH = "perfect_match"
        BEGIN_MATCH = "begin_match"
        END_MATCH = "end_match"
    end

    module RESTRICT
        R18 = "R18"
        R15 = "R15"
        R12 = "R12"
        NOTHING = "全年齢"
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
                #target_col = SEARCH_TARGET::TWT_TWTID
                target_col = SEARCH_TARGET::TWT_ID_AND_NAME
            elsif search_word =~ /@(\w+)/
                target_col = SEARCH_TARGET::TWT_TWTID
                search_word = $1
            #elsif search_word =~ %r!twitter\.com/(\w+)! or
            #    search_word =~ %r!x\.com/(\w+)!
            elsif search_word =~ Twt::TWT_URL_SCREEN_NAME_RGX
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

        if target_col != SEARCH_TARGET::TWT_ID_AND_NAME
            col = "#{target_col} LIKE?"
            puts %!対象="#{col}"\t検索ワード="#{search_word_p}"!
            [col, search_word_p]
        else
            col = nil
            where_phrase = %!#{SEARCH_TARGET::TWT_TWTID} LIKE "#{search_word_p}" OR #{SEARCH_TARGET::TWT_TWTNAME} LIKE "#{search_word_p}"!
            [col, where_phrase]
        end
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

    def self.url_list(filename)
        STDERR.puts %!Twitter::url_list="#{filename}"!
        path = UrlTxtReader::get_path(filename)
        _, twt_url_infos, _ = UrlTxtReader::get_url_txt_info(path)
        
        pxv_chk = false
        known_twt_url_list, unknown_twt_url_list, _ = Twitter::twt_user_classify(twt_url_infos, pxv_chk)
        [known_twt_url_list, unknown_twt_url_list]
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
                if pxv.active?
                    pxvid_list << pxv.pxvid
                else
                    registered_twt_acnt_list[twt_id] = twt_url_info.url_list
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
            pxv_feature = pxv.feature if pxv;

            [
                pxv_exist,
                pxv_feature,
                pxv_status||"",
                pxv_e,
                twt.drawing_method||"",
                twt.status||"",
                -url_list.size,
                -(twt.rating || 0),
                twt.r18||"",
                twt.last_access_datetime||"",
                twt.last_post_datetime||"",
            ]
        }
    end

=begin
    def twt_screen_name
        twtname
        if twtname == ""
            return ""
        else
            return twtname
        end
    end
=end

    def last_dl_datetime_disp
        get_date_info(last_dl_datetime)
    end

    def last_access_datetime_disp
        get_date_info(last_access_datetime)
    end

=begin
    def last_access_datetime_days_elapsed
        get_date_delta(last_access_datetime)
    end
=end

    def filesize_huge?
        if Twt::filesize_huge?(self.filesize)
            true
        else
            false
        end
    end

    def filesize_kb
        sprintf("(%d KB)", filesize / 1024)
    end

    def ul_freq_low?
        unless  self.update_frequency
            return nil
        end

        if self.update_frequency < Twt::UL_FREQUECNTY_THRESHOLD
            true
        else
            false
        end
    end

    def sp?
        if filesize_huge?
            if ul_freq_low?
                false
            else
                true
            end
        else
            false
        end
    end

    def has_unaccessible_tweet?
        if self.unaccessible_tweet_count > 0
            true
        else
            false
        end
    end

    def unaccessible_tweet_count
        h = Tweet::summary_hash(self.twtid)
        #p h
        if h and h[Tweet::StatusEnum::UNACCESSIBLE]
            h[Tweet::StatusEnum::UNACCESSIBLE]
        else
            0
        end
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
        #list = get_pic_filelist
        list = get_pic_filelist(false)
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

    def point
        pt = self.rating||0
        
        case self.r18
        when RESTRICT::R18
            pt += 10
        when RESTRICT::R15
            pt += 5
        when RESTRICT::R12
        else
        end

        pt += self.prediction / 100

        lan = self.last_access_day_num
        if lan > 30
            pt += 20
        elsif lan > 20
            pt += 10
        elsif lan <= 1
            pt -= 10
        elsif lan <= 3
            pt -= (lan * 3)
        else
        end

        cdn = self.created_at_day_num
        if cdn < 7
            pt += 16
        elsif cdn < 14
            pt += 12
        elsif cdn < 21
            pt += 8
        elsif cdn < 28
            pt += 4
        elsif cdn > 365
            pt -= (cdn / (365 / 2))
        elsif cdn > 180
            pt -= 1
        else
        end

        pd = self.prediction
        if pd > 30
            pt += 15
        elsif pd > 20
            pt += 10
        elsif pd > 10
            pt += 5
        else
        end

        pt
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
        #r, [pred, max, min-intvl]
        [95, [10,  40, 10]],
        [90, [10,  60, 20]],
        [85, [20,  90, 30]],
        [80, [30, 120, 40]],
        [70, [30, 150, 50]],
        [ 0, [60, 180,100]],
    ]
    COND_DATA_AI = [
        #r, [pred, max, min]
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
        [84, [70, 40, 14]],
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
                max_intvl = x[1][1]
                min_intvl = x[1][2]
                elapsed = last_access_datetime_days_elapsed

                # インターバル
                if min_intvl > elapsed
                    #STDERR.puts %!#{rating}:"#{twtname}(@#{twtid})":#{min_intvl} > #{elapsed}!
                    return false
                end

                if elapsed > max_intvl
                    #STDERR.puts %!#{rating}:"#{twtname}(@#{twtid})":#{prediction}/#{elapsed}|#{pred}/#{max_intvl}!
                    return true
                end

                if pred_cond_gt > 0 and prediction < pred_cond_gt
                    #STDERR.puts %!#{rating}:"#{twtname}(@#{twtid})":#{prediction}/#{elapsed}|#{pred}/#{max_intvl}!
                    return false
                end

                if prediction > pred
                    #STDERR.puts %!#{rating}:"#{twtname}(@#{twtid})":#{prediction}/#{elapsed}|#{pred}/#{max_intvl}!
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

    def group_key_rap
        r_unit = 5
        rate_n = Util::format_num(self.rating, r_unit)
        lad_n = sprintf("%3d", self.last_access_datetime_days_elapsed / 7)
        pred_n = Util::format_num(self.prediction, 10)
        %!#{rate_n}#{Twitter::TWT_H_SEPARATOR}#{lad_n}週|#{pred_n}!
    end

    def group_sub(unit, number, gkey_work, x, digit=3)
        w = Util::format_num(number, unit, digit)
        gkey_work.gsub(x, w)
    end

    #
    # ""
    #
    def group_spec(grp_sort_spec_arg, total_cnt)
        gkey_work = grp_sort_spec_arg.gsub(/#.*/, "")

        #regexp_pattern = /\{\w+\d*\}/
        regexp_pattern = /\{[a-zA-Z_]+\d*\}/
        matches = grp_sort_spec_arg.scan(regexp_pattern)

        #STDERR.puts %!"#{gkey_work}"!

        matches.each do |x|
            if x =~ /([a-zA-Z_]+)(\d*)/
                start_str = $1
                unit = $2.to_i if $2 != ""
            end

            #STDERR.puts %!"#{x}" => "#{start_str}|#{unit}"!

            case start_str
            when "ad"
                unit = 1 unless unit
                number = self.last_access_datetime_days_elapsed
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "am", "m"
                unit = 1 unless unit
                number = self.last_access_datetime_days_elapsed / 30
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "aw", "w"
                unit = 1 unless unit
                number = self.last_access_datetime_days_elapsed / 7
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "cd"
                unit = 1 unless unit
                number = self.created_at_day_num
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "cm", "c"
                unit = 1 unless unit
                number = self.created_at_day_num / 30
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "cw"
                unit = 1 unless unit
                number = self.created_at_day_num / 7
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "cyymm"
                yymm = self.created_at.strftime("%Y-%m")
                gkey_work.gsub!(x, yymm)
                #STDERR.puts %!"#{x}"\t"#{yymm}"\t"#{gkey_work}"!
            when "f"
                unit = 500 unless unit
                number = self.filenum
                gkey_work = group_sub(unit, number, gkey_work, x, 4)
            when "p"
                unit = 10 unless unit
                number = self.prediction
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "q"
                unit = 500 unless unit
                number = self.update_frequency
                gkey_work = group_sub(unit, number, gkey_work, x, 4)
            when "qq"
                unit = 500 unless unit
                if self.update_frequency >= unit
                    number = self.update_frequency
                    w = Util::format_num(number, unit, 4)

                    unit2 = 500
                    num2 = self.filenum / unit2 * unit2
                    digit = 4
                    max_n = 10 ** digit
                    f = Util::format_num(max_n - num2, unit2, digit)

                    gkey_work = "あとまわし(#{f})[約#{num2}ファイル～]" + TWT_H_SEPARATOR + "更新頻度#{w}～"
                    break
                else
                    gkey_work.gsub!(x, "")
                end
            when "r"
                unit = 1 unless unit
                number = self.rating
                gkey_work = group_sub(unit, number, gkey_work, x)
            when "method"
                gkey_work.gsub!(x, self.drawing_method||"")
            when "restrict"
                gkey_work.gsub!(x, self.r18||"")
            else
                msg = %!wrong opt:"#{start_str}"!
                Rails.logger.error(msg)
            end
        end

        if self.sp?
            "ファイルサイズ大#{TWT_H_SEPARATOR}."# + gkey_work
        else
            gkey_work
        end
    end

    def created_d_s(months)
        if months >= 12
            work = 12
            n = 1
        elsif months >= 6
            work = 6
            n = 2
        elsif months >= 3
            work = 3
            n = 3
        else
            work = months
            n = 9 - work
        end
        "登録[#{n}]" + Util::format_num(work, 1)
    end

    def newcomer?
        if created_at_day_num <= 30
            true
        else
            false
        end
    end

    def a1o_auto_group_key(r_unit=5, newc=true, fs_chk=true)
        if fs_chk and sp?
            return "00.ファイルサイズ大#{Twitter::TWT_H_SEPARATOR}更新頻度#{Util::format_num(self.update_frequency, 100, 4)}"
        end

        daysn =  self.last_access_datetime_days_elapsed
        lad_n = sprintf("%3d週", daysn / 7)
        lad_n2 = ""

        ndays_s = 7
        rat_1 = 90
        rat_a = 87
        rat_b = 85
        if daysn <= ndays_s
            if daysn < 1
                recent = "[20.本日アクセス]"
                p_unit = 1
            elsif self.rating >= rat_1
                recent = "[91.高評価(#{rat_1}↑)]最近アクセス"
                p_unit = 5
            elsif daysn < 2
                recent = "[21.昨日アクセス]"
                p_unit = 2
            elsif daysn < 3
                recent = "[22.一昨日アクセス]"
                p_unit = 3
            elsif self.rating >= rat_a
                #recent = "[56.高評価(#{rat_a}↑)]最近アクセス"
                recent = "[56.高評価(#{self.rating})]最近アクセス"
                p_unit = 5
            elsif rating < 85
                recent = "[24.1週間以内アクセス](#{rat_b}↓)"
                p_unit = 5
            else
                recent = "[25.1週間以内アクセス](#{rat_b}↑)"
                p_unit = 5
            end

            if false
                #created_n = Util::format_num(self.created_at_day_num / 30, 1)
                created_s = created_d_s(self.created_at_day_num / 30)
                key = %!#{created_s}ヶ月～|予測#{pred_n}～!
            elsif false
                pred_n = Util::format_num(self.prediction, p_unit)
                #key = "#{daysn}日|予測#{pred_n}～"
                rate_n = Util::format_num(self.rating, 10)
                key = %!評価#{rate_n}～|予測#{pred_n}～!
            else
                pred_n = Util::format_num(self.prediction, 3)
                key = %!予測#{pred_n}～!
            end
            rate_n = ""
        else
            p_unit = 20
            if daysn >= 365
                recent = "[59.数年経過]"
            elsif daysn >= 180
                recent = "[58.半年以上経過]"
            elsif daysn >= 90
                recent = "[57.数カ月経過]"
            elsif rating >= 90
                recent = "[95.高評価]最近アクセス"
                p_unit = 5
            elsif rating >= rat_a
                recent = "[56.高評価(#{rat_a}↑)]"
                p_unit = 10

                lad_n2 = %!|#{Util::format_num(daysn / 7, 4)}週～!
            elsif daysn >= 30
                recent = "[55.1カ月以上経過]"
            elsif self.prediction > 40
                recent = "[54.予測多い]"
            elsif daysn < 7 and self.prediction < 10
                recent = "[51.1週間以内アクセス&予測少]"
            else
                recent = "[52.#{ndays_s}日以上経過]"
            end
            pred_nn = Util::format_num(self.prediction, 40)
            pred_n = Util::format_num(self.prediction, p_unit)
            rate_n = %!評価#{Util::format_num(self.rating, r_unit)}～!
            key = %!<#{pred_nn}～>#{lad_n}|予測#{pred_n}～!
        end

        if newc
            if created_at_day_num <= 60
                newcomer = "90.新参|"
            elsif created_at_day_num > 365
                newcomer = "01.古株|"
            else
                newcomer = "50.中堅|"
            end
        else
            newcomer = ""
        end

        recent + newcomer + "|" + rate_n + lad_n2 + Twitter::TWT_H_SEPARATOR + key
    end

    def group_key_test(grp_sort_by, status=false)
        gkey = ""
        if self.sp?
            uf = Util::format_num(self.update_frequency, 100, 4)
            gkey = "ファイルサイズ大&更新頻度高め#{Twitter::TWT_H_SEPARATOR}更新頻度#{uf}"
        else
            case grp_sort_by
            when TwittersController::GRP_SORT::GRP_SORT_PRED
                p = Util::format_num(self.prediction, 10)
                gkey = %!予測#{Twitter::TWT_H_SEPARATOR}#{p}!
            when TwittersController::GRP_SORT::GRP_SORT_ACCESS_W
                w = %!#{sprintf("%3d", self.last_access_datetime_days_elapsed / 7)}週!
                p = %!#{Util::format_num(self.prediction, 10)}!
                gkey = %!#{w}#{Twitter::TWT_H_SEPARATOR}#{p}!
            when TwittersController::GRP_SORT::GRP_SORT_ACCESS_W_P
                w = %!#{sprintf("%3d", self.last_access_datetime_days_elapsed / 7)}週!
                p = %!#{Util::format_num(self.prediction, 10)}!
                gkey = %!#{w}#{Twitter::TWT_H_SEPARATOR}#{p}!
            when TwittersController::GRP_SORT::GRP_SORT_R_P
                p = Util::format_num(self.prediction, 10)
                r = Util::format_num(self.rating, 1)
                gkey = %!#{r}#{Twitter::TWT_H_SEPARATOR}#{p}!
            when TwittersController::GRP_SORT::GRP_SORT_R_A
                w = %!#{sprintf("%3d", self.last_access_datetime_days_elapsed / 7)}週!
                r = Util::format_num(self.rating, 1)
                gkey = %!#{r}#{Twitter::TWT_H_SEPARATOR}#{w}!
            when TwittersController::GRP_SORT::GRP_SORT_RATE
                r = Util::format_num(self.rating, 1)
                self.last_access_datetime_days_elapsed / 30
                #gkey = %!#{r}!
                gkey = %!#{self.status}#{Twitter::TWT_H_SEPARATOR}#{r}!
            else
            end
        end
        gkey
    end

    def days_str(daysn)
        daysn = 
        if daysn < 3
            month_n = Util::format_num(daysn, 1)
            month_s = %!1.#{month_n}日!
            p_unit = 5
        elsif daysn < 30
            month_n = Util::format_num(daysn / 7, 1)
            month_s = %!5.#{month_n}週!
            p_unit = 5
        elsif daysn < 365
            month_n = Util::format_num(daysn / 30, 1)
            month_s = %!8.#{month_n}ヶ月!
            p_unit = 30
        else
            month_n = Util::format_num(daysn / 365, 1)
            month_s = %!9.#{month_n}年!
            p_unit = 60
        end

        p = Util::format_num(self.prediction, p_unit)
        "#{month_s}:#{p}件～"
    end

    def a1o_auto_group_key_xx(e, hide_within_days, rating_gt, sort_by)
        detail = true
        case self.status
        when Twitter::TWT_STATUS::STATUS_PATROL
            case sort_by
            when TwittersController::SORT_BY::PRED
                gkey = ""
            when TwittersController::SORT_BY::ACCESS
                gkey = ""
            when TwittersController::SORT_BY::TODO_CNT
                if self.sp?
                    gkey = "ファイルサイズ大&更新頻度高め"
                    detail = false
                else
                    gkey = sprintf("残:%3d件", e.todo_cnt)
                end
            when TwittersController::SORT_BY::TOTAL_CNT
                gkey = sprintf("全:%3d件", e.url_cnt)
            else
                gkey = ""
            end
            
            gkey += self.a1o_auto_group_key(5, false) if detail
            gkey
        when "", nil
            daysn = self.last_access_datetime_days_elapsed

            d = 60
            if daysn < d
                pxv = "09.未設定|#{d / 30}ヶ月以内"
            else
                file_num_s = Util::format_num(self.filenum, 25)

                #todo_cnt_str = sprintf("残:%3d件", e.todo_cnt)
                todo_cnt_str = "残:" +  Util::format_num(e.todo_cnt, 3) + "件↑"
                if self.pxvid.presence
                    pxv = %!05.[#{file_num_s}ファイル]pxvあり<#{todo_cnt_str}>!
                else
                    pxv = %!08.[#{file_num_s}ファイル]pxvなし<#{todo_cnt_str}>!
                end
            end

            t = Util::format_num(e.todo_cnt, 3)
            p = days_str(daysn)

            gkey = pxv + TWT_H_SEPARATOR + %!#{t}件～|! + p
        else
            #self.group_key2(hide_within_days, rating_gt)
            %!00.#{self.drawing_method}#{TWT_H_SEPARATOR}#{self.status}!
        end
    end

    def group_key()

        case drawing_method
        when DRAWING_METHOD::DM_HAND
            if self.pxvid
                dm = %!970.手(pxvあり)!
            else
                dm = %!975.手!
            end
        when DRAWING_METHOD::DM_AI
            dm = %!980.AI!
        when DRAWING_METHOD::DM_3D, DRAWING_METHOD::DM_REPRINT
            return %!910.その他#{TWT_H_SEPARATOR}#{drawing_method}!
        when "", nil
            daysn = self.last_access_datetime_days_elapsed
            if daysn > 90
                dm = %!998.未設定(古め)!
            else
                dm = %!999.未設定(最近)!
            end

            if self.pxvid
                dm += "pxvあり"
            else
                dm += "pxvなし"
            end

            key = days_str(daysn)
        else
            dm = %!990.#{drawing_method}!
        end

        case status
        when Twitter::TWT_STATUS::STATUS_PATROL
            #r = Util::format_num(self.rating, 5)
            #key = %!999.#{a1o_auto_group_key(3, false)}!
            #r = 999
            #key = %!評価#{r}～.#{a1o_auto_group_key(5, false)}!
            key = a1o_auto_group_key(5, false)
        else
            key = status unless key
        end

        %!#{dm}#{TWT_H_SEPARATOR}#{key}!
    end

    def self.access_str(lad_n)
        tbl = [
            1,
            3,
            7,
            14,
            20,
            30,
        ]

        i = 0
        tbl.each do |x|
            i += 1
            if lad_n < x
                return "#{tbl.size - i}:#{x}日以内"
            end
        end

        month = lad_n / 30
        return "0:(#{99 - month})#{month}ヶ月"
    end

    def group_key2(hide_within_days, rating_gt)
        
        if created_at_day_num > 60
            created_at_str = "0旧"
        else
            created_at_str = "1新"
        end

        accs = ""

        rating_w = rating||0
        if rating_w >= rating_gt * 1.1
            rat_str = "0V高"
        elsif rating_w >= rating_gt * 1.05
            rat_str = "1高"
        elsif rating_w >= rating_gt
            rat_str = "5中"
        else
            rat_str = "9低"
        end

        accs_rec = Twitter::access_str(last_access_day_num)
        if last_access_day_num < 1
            top_s = "9:今日"
        elsif last_access_day_num < 7
            top_s = "8:今週"
        elsif last_access_day_num > 360
            top_s = "0:大昔"
        elsif last_access_day_num > 30
            top_s = "1:昔"
        else
            top_s = "2:中間"
        end

        if self.select_cond_aio(0)
            obj = "0対象"
            pred_str = ""
        else
            obj = "1対象外"
            if prediction >= 50
                pred_str = "0かなり多い"
            elsif prediction >= 40
                pred_str = "1多"
            elsif prediction >= 30
                pred_str = "2多め"
            elsif prediction >= 20
                pred_str = "3若干多め"
            elsif prediction >= 10
                pred_str = "4中"
            elsif prediction >= 5
                pred_str = "8少"
            else
                pred_str = "9極少"
            end
        end

        if self.status == Twitter::TWT_STATUS::STATUS_PATROL
            [
                top_s,
                rat_str,
                self.status||"",
                self.drawing_method||"",
                obj,
                accs_rec,
                pred_str,
                created_at_str,
            ].join("-")
        else
            [
                self.drawing_method||"",
                TWT_H_SEPARATOR,
                self.status||"",
            ].join("-")
        end
    end

    def self.url_list_work_to_hash(url_list_work, hide_within_days, rating_gt, sort_by)
        hash = {}
        hash = url_list_work.group_by {|x|
            e = x[0]
            twt = x[1]
            twt.a1o_auto_group_key_xx(e, hide_within_days, rating_gt, sort_by)
        }
        hash.sort_by {|k,v| k}.reverse.to_h
    end
end
