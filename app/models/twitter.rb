class Twitter < ApplicationRecord
    include UrlTxtReader

    belongs_to :artists, :class_name => 'Artist', optional: true

    STATUS_PATROL = "TWT巡回"
    STATUS_NOT_EXIST = "存在しない"

    def self.find_by_twtid_ignore_case(twtid, ignore=true)
        if twtid == nil
            return nil
        end

        if ignore
            records = Twitter.where('UPPER(twtid) = ?', twtid.upcase)
            if records.size > 1
                puts %!"#{twtid}":#{records.size}件のレコードが見つかりました !
            end
            records.first
        else
            Twitter.find_by(twtid: twtid)
        end
    end

    def self.looks(target_col, search_word, match_method)
        search_word.strip!
        puts %!#{target_col}, #{search_word}, #{match_method}!

        if target_col == "(自動判断)"
            if search_word =~ /^\w+$/
                target_col = "twitter_twtid"
            elsif search_word =~ /@(\w+)/
                target_col = "twitter_twtid"
                search_word = $1
            elsif search_word =~ %r!www\.twitter\.com/(\d+)! or
                search_word =~ %r!www\.x\.com/(\d+)!
                target_col = "twitter_twtid"
                search_word = $1
            else
                target_col = "twtname"
            end
        end

        if match_method == "auto"
            case target_col
            when "twitter_twtid"
                #match_method = "perfect_match"
                match_method = "partial_match"
            else
                match_method = "partial_match"
            end
        end

        puts %!#{target_col}, #{search_word}, #{match_method}!

        search_word_p = ""
        case match_method
        when "perfect_match"
            search_word_p = search_word
        when "begin_match"
            search_word_p = "#{search_word}%"
        when "end_match"
            search_word_p = "%#{search_word}"
        when "partial_match"
            search_word_p = "%#{search_word}%"
        else
            search_word_p = search_word
        end
        ["#{target_col} LIKE?", search_word_p]
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
                pxvid_list << pxv.pxvid
                #registered_twt_acnt_list[twt_id] = twt_url_info.url_list
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

    def twt_user_url
        Twt::twt_user_url(twtid)
    end

    def get_pic_filelist(read_all=true)
        if filenum == nil or filenum < 500 or read_all
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

    def select_cond_post_date
        num_of_days_elapased = get_date_delta(last_post_datetime)
        cond_day = 30
        if last_access_datetime_p(cond_day)
            #指定日以内にアクセスしているので対象外
            false
        else
            true
        end
    end
end
