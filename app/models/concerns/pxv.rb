# coding: utf-8

module Pxv
    extend ActiveSupport::Concern

    PXV_ARCHIVE_DIR_PATH = "public/pxv/"
    #PXV_DIRLIST_PATH = "public/pxv/dirlist.txt"
    PXV_DIRLIST_PATH = PXV_ARCHIVE_DIR_PATH + "dirlist.txt"

    PXV_ARCHIVE_DIR_WC = "*/*/*"

    PXV_TMP_DIR_PATH = "public/f_dl/"
    #PXV_WORK_DIR_PATH = "public/f_dl/PxDl/"
    #PXV_WORK_TMP_DIR_PATH = "public/f_dl/PxDl-/"
    #PXV_WORK_TMP_DIR_F_PATH = "public/f_dl/PxDl-/alphabet"
    PXV_WORK_DIR_PATH       = PXV_TMP_DIR_PATH + "PxDl/"
    PXV_WORK_TMP_DIR_PATH   = PXV_TMP_DIR_PATH + "PxDl-/"
    PXV_WORK_TMP_DIR_F_PATH = PXV_TMP_DIR_PATH + "PxDl-/alphabet"

    PXV_WORK_TMP_DIR_F_WC = "*/*/*"
    PXV_WORK_TMP_DIR_WC = "*"

    ARCHIVE_PATH = "D:/r18/dlPic"
    PXV_TMP_PATH = "D:/data/src/ror/myapp/public"

    def self.pxv_user_url(pxvid)
        %!https://www.pixiv.net/users/#{pxvid}!
    end

    def self.pxv_artwork_url(artwork_id)
        %!https://www.pixiv.net/artworks/#{artwork_id}!
    end

    def self.get_path_from_dirlist(pxvid)
        txtpath = Rails.root.join(PXV_DIRLIST_PATH).to_s
        unless File.exist? txtpath
            return []
        end

        rpath = []
        File.open(txtpath) { |file|
            while line  = file.gets
                #if line.include?(search_str)
                if line =~ /\(#{pxvid}\)|\(\##{pxvid}\)/
                    rpath << line.chomp
                end
            end
        }
        rpath
    end

    def self.stock_dir_list()
        current_work_dir_root = Rails.root.join(PXV_WORK_DIR_PATH).to_s + "*/"
        dir_list = Dir.glob(current_work_dir_root)

        if Dir.exist?(PXV_WORK_TMP_DIR_F_PATH)
            dir_list_tmp = Util::glob(PXV_WORK_TMP_DIR_PATH, PXV_WORK_TMP_DIR_F_WC)
        elsif Dir.exist?(PXV_WORK_TMP_DIR_PATH)
            dir_list_tmp = Util::glob(PXV_WORK_TMP_DIR_PATH, PXV_WORK_TMP_DIR_WC)
            #puts %![]dir_list_tmp=#{dir_list_tmp}!
        else
            dir_list_tmp = []
        end

        [dir_list, dir_list_tmp].flatten.select {|path| FileTest.directory? path}
    end

    def self.current_dir_pxvid_list
        idlist = []

        stock_dir_list.each do |path|
            if File.basename(path) =~ /\((\d+)\)-?$/
                id = $1
                idlist << id.to_i
                #puts %!#{path},#{id}!
            end
        end
        idlist
    end

    def self.pxvid_exist?(path, pxvid)
        File.basename(path) =~ /\(#{pxvid}\)/
    end

    def self.get_pxv_user_id(path)
        if File.basename(path) =~ /\(#?(\d+)\)-?$/
            return $1.to_i
        else
            return ""
        end
    end

    def self.get_user_name_from_path(path)
        if File.basename(path) =~ /(.*?)\(\d+\)$/
            username = $1
        else
            STDERR.puts %!get_user_name_from_path():can't find user name:"#{path}"!
            username = ""
        end
        username
    end
    
    def self.user_name(pathlist, pxvid)
        pathlist.each do |path|
            if File.basename(path) =~ /(.*?)\(#{pxvid}\)$/
                #puts %!#{path}:#{pxvid}!
                return $1
            end
        end

        #puts %!user name not found. pxvid=#{pxvid}!
        return ""
    end

    def self.get_pathlist(pxvid, archive_dir=true)
        path_list = []

        dir_list = stock_dir_list()
        dir_list.each do |path|
            if pxvid_exist?(path, pxvid)
                puts %![get_pathlist] path="#{path}"!
                path_list << UrlTxtReader::get_path_list(path)
                #break
            end
        end

        if archive_dir
            rpath_list = get_path_from_dirlist(pxvid)
            rpath_list.each do |rpath|
                puts %![get_pathlist] rpath="#{rpath}"!
                path_list << UrlTxtReader::get_path_list(rpath)
            end
        end

        #path_list.flatten.sort.reverse

        #path_list = path_list.flatten.map {|x| [get_pxv_art_id(x), File::basename(x), x]}.sort.reverse.map {|x| x[2]}
        pathlist = sort_pathlist(path_list.flatten)
        puts %![get_pathlist] pathlist size=#{pathlist.size}/pxvid=(#{pxvid})!
        pathlist
    end

    def self.get_artwork_info(pxv_user_id, pxv_artwork_id)
        artwork_info = nil
        path_list = get_pathlist(pxv_user_id)
        path_list.each do |path|
            artwork_id, date_str, artwork_title = get_pxv_artwork_info_from_path(path)
            if get_pxv_art_id(path) == pxv_artwork_id
                if artwork_info
                    artwork_info.append_path(path)
                else
                    begin
                        date = Date.parse(date_str)
                    rescue Date::Error => ex
                        STDERR.puts %!get_artwork_info("#{date_str}"):#{ex}!
                        date = nil
                    end

                    artwork_info = PxvArtworkInfo.new(artwork_id, artwork_title, date, path)
                end
            end
        end
        artwork_info
    end

    def self.sort_pathlist(path_list)
        path_list.map {|x| [get_pxv_art_id(x), File::basename(x), x]}.sort.reverse.map {|x| x[2]}
    end

    def self.get_pxv_art_id(path)
=begin
        id = 0
        #if x =~ /\d\d-\d\d-\d\d.*\((\d+)\)/
        if x =~ /\d\d-\d\d-\d\d.*?\((\d+)\)/
            id = $1
        end
        id.to_i
=end
        artwork_id, date_str, artwork_title = get_pxv_artwork_info_from_path(path)
        artwork_id
    end

    def self.get_date_title_id_str_from_path(path)
        filename = File.basename(path)
        if filename =~ /\d\d-\d\d-\d\d/
            #ファイル名を返す
            return filename
        else
            #フォルダ名を返す
            return File.basename(File.dirname(path))
        end
    end

    def self.get_oldest_pxv_artwork_id(pathlist)
        artwork_id = 0
        pathlist.reverse.each do |path|
            artwork_id, _, _ = Pxv::get_pxv_artwork_info_from_path(path)
            if artwork_id != 0
                break
            end
        end
        artwork_id
    end

    def self.get_pxv_artwork_info_from_path(path)
        if path == nil
            STDERR.puts %!get_pxv_artwork_info_from_path:path is nil"!
            return [nil, nil, nil]
        end
        artwork_id = 0
        artwork_str = get_date_title_id_str_from_path(path)
        
        #STDERR.puts %!"#{artwork_str}"!

=begin
        #if artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*?)\((\d+)\)/
        if artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d\d+)\)\s*\(\d+\)/
            date_str = $1
            artwork_title = $2
            artwork_id = $3.to_i
            STDERR.puts %![get_pxv_artwork_info_from_path]#{date_str}/#{artwork_title}/#{artwork_id}"!
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d\d+)\)/
=end
        if artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d\d+)\)/
            date_str = $1
            artwork_title = $2
            artwork_id = $3.to_i
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d+)\)\(\d+\)/
            date_str = $1
            artwork_title = $2
            artwork_id = $3.to_i
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*\((\d+)\)\s*(.*)/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = $3
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+.*?(\d+)_p\d+_master/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+.*?(\d+)_p\d+/
            STDERR.puts %!"#{artwork_str}"/#{$1}/#{$2}!
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        # 22-08-05 100x3x4x5_p0.png
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+.*(\d{8,9})_p\d/
            #https://www.pixiv.net/artworks/8235311x
            #                               8083357x
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+\d{4}(\d+)/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        #22-06-20 9x17x5x2_p0_master1200.jpg"
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+(\d+)/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)/
            #STDERR.puts %!artwork id not found:"#{path}"!
            date_str = $1
            artwork_title = $2
        else
            STDERR.puts %!regex no hit:"#{artwork_str}"\t"#{path}"!
            date_str = ""
        end

        if artwork_id < 10 and artwork_id != 0
            STDERR.puts %!ID取得に失敗した可能性があります。artwork_id=#{artwork_id}?|"#{path}"|"#{artwork_str}"!
            artwork_id = 0
        end
        [artwork_id, date_str, artwork_title]
    end

    def self.archive_dir_id_list
        id_list = []
        dir_list = Util::glob(PXV_ARCHIVE_DIR_PATH, PXV_ARCHIVE_DIR_WC)
        dir_list.each do |path|
            pxv_user_id = get_pxv_user_id(path)
            if pxv_user_id != ""
                id_list << pxv_user_id
            else
                #STDERR.puts %!no hit path=#{path}!
            end
        end
        id_list.sort.uniq
    end

    def self.name_test

        STDERR.puts %!### test ### >>>!
        PxvArtist.init_exception_name_list

        dir_list = stock_dir_list()
        dir_list.each do |path|
            pxv_user_id = get_pxv_user_id(path)
            if pxv_user_id == ""
                STDERR.puts %!"#{path}"(#{pxv_user_id}) 不正フォルダ名!
            end
            pxv_artist = PxvArtist.new(pxv_user_id, path)
        end

        PxvArtist.print_chg_list
    end

    def self.db_update_by_newdir(update_record=true)
        new_list = []
        dir_list = stock_dir_list()

        if false
            # pxv user id重複チェック
            hash = {}
            dir_list.each do |path|
                pxv_user_id = get_pxv_user_id(path)
                if hash.has_key?(pxv_user_id)
                else
                    hash[pxv_user_id] = []
                end
                hash[pxv_user_id] << path
            end

            dup = false
            hash.each do |k, paths|
                if paths.size > 1
                    dup = true
                    STDERR.puts %!重複するIDがあります:key=#{k}("#{paths}")!
                    paths.each do |path|
                        STDERR.puts %!"#{path}"!
                    end
                end
            end

            if dup
                STDERR.puts %!重複するIDがあるので処理を中止しました。!
                raise "dup"
            end
        end

        PxvArtist.init_exception_name_list

        # ディレクトリごとの処理
        dir_list.each do |path|
            pxv_user_id = get_pxv_user_id(path)
            if pxv_user_id != ""
                p = Artist.find_by(pxvid: pxv_user_id)
                if p
                    if update_record
                        STDERR.puts %!user:#{p.pxvname}(#{p.pxvid})!
                        update_table(p, path)
                    end
                else
                    new_list << [pxv_user_id, path]
                end
            end
        end
        
        new_list.each do |x|
            STDERR.puts %!new user:#{x[0]}|#{x[1]}!
            register_to_table(x[0], x[1])
            #break
        end
    end

    def self.update_record_by_dir(pxv_user_id_arg)
        PxvArtist.init_exception_name_list

        dir_list = stock_dir_list()
        dir_list.each do |path|
            pxv_user_id = get_pxv_user_id(path)
            if pxv_user_id == pxv_user_id_arg
                p = Artist.find_by(pxvid: pxv_user_id)
                if p
                    STDERR.puts %!user:#{p.pxvname}(#{p.pxvid})!
                    update_table(p, path)
                else
                    STDERR.puts %!new user:#{pxv_user_id}|#{path}!
                    register_to_table(pxv_user_id, path)
                end
                break
            end
        end
    end
    
    def self.register_to_table(pxv_user_id, path)
        pxv_params = {}

        pxv_artist = PxvArtist.new(pxv_user_id, path)
        pxv_params[:pxvname] = pxv_artist.pxv_name
        pxv_params[:pxvid] = pxv_artist.pxv_user_id
        pxv_params[:filenum] = pxv_artist.path_list.size
        pxv_params[:last_dl_datetime] = pxv_artist.last_dl_datetime #???
        pxv_params[:last_ul_datetime] = pxv_artist.last_ul_datetime
        pxv_params[:last_access_datetime] = pxv_artist.last_access_datetime
        pxv_params[:priority] = 0
        pxv_params[:furigana] = ""
        pxv_params[:circle_name] = ""
        pxv_params[:comment] = ""

        alist = Artist.artwork_list(pxv_artist.path_list)
        recent_filenum = Artist.artwork_list_recent_file_num(alist)

        STDERR.puts %!recent_filenum=#{recent_filenum}(filenum=#{pxv_artist.path_list.size})!

        pxv_params[:recent_filenum] = recent_filenum
        pxv_params[:status] = ""
        twt = Twitter.find_by(pxvid: pxv_user_id)
        if twt
            pxv_params[:twtid] = twt.twtid
        else
            pxv_params[:twtid] = ""
        end
        pxv_params[:njeid] = ""
        pxv_params[:warnings] = ""
        pxv_params[:remarks] = ""
        pxv_params[:rating] = 0
        pxv_params[:r18] = ""
        pxv_params[:feature] = ""
        pxv_params[:chara] = ""
        pxv_params[:work] = ""
        pxv_params[:altname] = ""
        pxv_params[:oldname] = ""
        pxv_params[:earliest_ul_date] = pxv_artist.earliest_ul_date
        pxv_params[:pxv_path] = ""
        pxv_params[:tech_point] = 0
        pxv_params[:sense_point] = 0
        pxv_params[:good_point] = ""
        pxv_params[:bad_point] = ""
        pxv_params[:pxv_fav_artwork_id] = 0
        pxv_params[:fetish] = ""
        pxv_params[:obtain_direction] = ""
        pxv_params[:next_obtain_artwork_id] = ""
        pxv_params[:twt_check] = ""
        pxv_params[:web_url] = ""
        pxv_params[:djn_check_date] = ""
        pxv_params[:zip] = ""
        pxv_params[:append_info] = ""
        pxv_params[:twt_checked_date] = ""
        pxv_params[:nje_checked_date] = ""
        pxv_params[:show_count] = 0#""
        pxv_params[:reverse_status] = ""
        pxv_params[:latest_artwork_id] = pxv_artist.latest_artwork_id
        pxv_params[:oldest_artwork_id] = pxv_artist.oldest_artwork_id
        pxv_params[:zipped_at] = nil
    
=begin
        STDERR.puts %!#{pxv_params}!
        #pxv_artist.path_list.each do |path|
        #    btime = File.birthtime(Util::get_public_path(path))
        #    STDERR.puts %!#{btime}"#{path}":!
        #end
=end

        STDERR.puts %!新規ユーザー("#{}") => \t#{pxv_params}!

        pxv = Artist.new(pxv_params)
        pxv.save
    end

    def self.update_table(pxv, path)
        pxv_params = {}

        pxv_artist = PxvArtist.new(pxv.pxvid, path)
        if pxv_artist.path_list.size == 0
            return
        end

        if pxv.pxvname != pxv_artist.pxv_name
            msg = %!名前変更あり「#{pxv.pxvname}」=>「#{pxv_artist.pxv_name}」!
            Rails.logger.info(msg)

            #pxv_params[:pxvname] = pxv_artist.pxv_name

            if pxv.oldname.presence
                oldnames = pxv.oldname.split(/\//)
                if oldnames.include?(pxv.pxvname)
                    #すでに記録済みの名称のためなにもしない
                else
                    updated_oldname = pxv.oldname + "/" + pxv.pxvname
                    #pxv_params[:oldname] = updated_oldname
                    
                    msg =  %!名前:oldname「#{pxv.oldname}」=>「#{updated_oldname}」!
                    Rails.logger.info(msg)
                end
            else
                pxv_params[:pxvname] = pxv_artist.pxv_name#zantei

                pxv_params[:oldname] = pxv.pxvname
                #STDERR.puts %!oldname:「#{pxv.oldname}」new\!!
            end
        end

        if pxv_artist.path_list.size > pxv.filenum
            if pxv.filenum.presence
            else
                pxv_params[:filenum] = pxv_artist.path_list.size

                msg = %!filenum:"#{pxv_params[:filenum]}" <= #{pxv_artist.path_list.size}!
                Rails.logger.info(msg)
            end
            
            if pxv.recent_filenum.presence
            else
                alist = Artist.artwork_list(pxv_artist.path_list)
                recent_filenum = Artist.artwork_list_recent_file_num(alist)
                pxv_params[:recent_filenum] = recent_filenum

                msg = %!recent_filenum:"#{pxv_params[:recent_filenum]}" <= #{recent_filenum}!
                Rails.logger.info(msg)
            end
        end

        #STDERR.print %!最古UL日:\t#{pxv.earliest_ul_date.strftime("%Y-%m-%d")} => #{pxv_artist.earliest_ul_date.strftime("%Y-%m-%d")}!
        if pxv_artist.earliest_ul_date < pxv.earliest_ul_date
            pxv_params[:earliest_ul_date] = pxv_artist.earliest_ul_date
        end

        #STDERR.print %!最終UL日:\t#{pxv.last_ul_datetime.strftime("%Y-%m-%d")} => #{pxv_artist.last_ul_datetime.strftime("%Y-%m-%d")}!
        if pxv_artist.last_ul_datetime > pxv.last_ul_datetime
            pxv_params[:last_ul_datetime] = pxv_artist.last_ul_datetime
        end

        #STDERR.print %!最新DL日:\t#{pxv.last_dl_datetime.strftime("%Y-%m-%d")} => #{pxv_artist.last_dl_datetime.strftime("%Y-%m-%d")}!
        #if pxv_artist.last_dl_datetime > pxv.last_dl_datetime
        if pxv_artist.last_dl_datetime.round > pxv.last_dl_datetime.round
            #STDERR.puts %!"#{pxv_artist.last_dl_datetime}"\t"#{pxv.last_dl_datetime}"!
            puts pxv_artist.last_dl_datetime.strftime("%Y-%m-%d %H:%M:%S.%L %z")
            puts pxv.last_dl_datetime.strftime("%Y-%m-%d %H:%M:%S.%L %z")
            pxv_params[:last_dl_datetime] = pxv_artist.last_dl_datetime
        end

        if pxv.latest_artwork_id
            if pxv_artist.latest_artwork_id > pxv.latest_artwork_id
                pxv_params[:latest_artwork_id] = pxv_artist.latest_artwork_id
            end
        else
            pxv_params[:latest_artwork_id] = pxv_artist.latest_artwork_id
        end

        if pxv.oldest_artwork_id
            if pxv_artist.oldest_artwork_id != 0 and pxv_artist.oldest_artwork_id < pxv.oldest_artwork_id
                pxv_params[:oldest_artwork_id] = pxv_artist.oldest_artwork_id
            end
        else
            pxv_params[:oldest_artwork_id] = pxv_artist.oldest_artwork_id
        end

        #if pxv_artist.last_access_datetime < pxv.last_access_datetime
        #    pxv_params[:last_access_datetime] = pxv_artist.last_access_datetime
        #    print "更新"
        #end
        #STDERR.puts %!last_access_datetime:\t#{pxv.last_access_datetime.strftime("%Y-%m-%d")} => #{pxv_artist.last_access_datetime.strftime("%Y-%m-%d")}!

        unless pxv.twtid.presence
            twt = Twitter.find_by(pxvid: pxv.pxvid)
            if twt
                pxv_params[:twtid] = twt.twtid
                STDERR.puts %!@#{twt.twtid}!
            end
        end

        if pxv_params.size > 0
            msg = %!"#{pxv.pxvname}(#{pxv.pxvid})":更新内容 => #{pxv_params}!
            Rails.logger.info(msg)
            pxv.update(pxv_params)
        end
    end

    def self.get_key(rating, str)
        r = (rating||0)
        point = sprintf("%03d:評価%03d", 100 - r, r)
        #key_str = %!\!#{point}(#{rating}):#{str}アクセスしてない!
        #key_str = %!\!#{point}.#{rating}:#{str}アクセスしてない!
        key_str = %!#{point}!
        key_str
    end

    def self.get_key_term(rating, str)
        r = (rating||0)
        point = sprintf("%03d:評価%03d", 100 - r, r)
        key_str = %!\!#{str}アクセスしてない!
        key_str
    end

    def self.hash_group2(pxv_group, pxv_list_tmp)
        key_pxv_list_from_twt_list_a = "141.twt url list high"
        key_pxv_list_from_twt_list_a2= "142.twt url list low"
        key_pxv_list_from_twt_list_b = "143.twt url list 状態"
        key_pxv_list_from_twt_list_z = "149.twt url list 最近アクセス"
        key_pxv_list_from_twt_list_zz = "150.twt url list 極最近アクセス"

        twt_list_z, tmp_ltns = pxv_list_tmp.partition {|x| x.p.last_access_datetime_p(60)}
        tmp_a, tmp_st = tmp_ltns.partition {|x| x.p.status == ""}
        tmp_high, tmp_low = tmp_a.partition {|x| x.p.rating >= 80}
        pxv_group[key_pxv_list_from_twt_list_a] = tmp_high.sort_by {|z|
            x = z.p;
            [
                x.rating||0,
                x.last_access_datetime,
                x.status||"", 
                x.feature||"",
                -(x.prediction_up_cnt(true)), 
            ]
        }
       
        pxv_group[key_pxv_list_from_twt_list_b] = tmp_st
        pxv_group[key_pxv_list_from_twt_list_a2] = tmp_low

        twt_list_zz, twt_list_z1 = twt_list_z.partition {|x| x.p.last_access_datetime_p(7)}
        pxv_group[key_pxv_list_from_twt_list_z] = twt_list_z1.sort_by {|z|
            x = z.p;
            [
                #x.last_access_datetime||"",
                x.last_access_datetime||Time.new(2001,1,1),
                x.status||"", 
                x.feature||"",
                -(x.prediction_up_cnt(true)), 
                x.rating||0, 
            ]
        }
        pxv_group[key_pxv_list_from_twt_list_zz] = twt_list_zz.sort_by {|z|
            x = z.p;
            [
                #x.last_access_datetime||"",
                x.last_access_datetime||Time.new(2001,1,1),
                x.status||"", 
                x.feature||"",
                -(x.prediction_up_cnt(true)), 
                x.rating||0, 
            ]
        }
    end

    def self.hash_group(known_pxv_user_id_list, pxv_group, hide_day)
        key_pxv_list_no_access_1y    = "101.12ヶ月(1年以上)"
        key_pxv_list_no_access_6m    = "102.6ヶ月(半年以上)"
        key_pxv_list_no_access_5m    = "103.5ヶ月以上"
        key_pxv_list_no_access_4m    = "104.4ヶ月以上"
        key_pxv_list_no_access_3m    = "105.3ヶ月以上"
        key_pxv_list_no_access_2m    = "106.2ヶ月以上"
        key_pxv_list_pred            = "199.わりと最近アクセス"
    
        key_pxv_list_unset           = "!未設定|総ファイル数"
    
        key_pxv_list_no_update_6m    = "902.#{ArtistsController::Status::SIX_MONTH_NO_UPDATS}"
        key_pxv_list_no_update_long  = "903.#{ArtistsController::Status::LONG_TERM_NO_UPDATS}"
        key_pxv_list_no_artworks     = "904.#{ArtistsController::Status::NO_ARTWORKS}"
    
        recent_pxv_list = []

        if false
            method_proc = Proc.new {|a,b|
                get_key_term(a, b)
            }
        else
            method_proc = Proc.new {|a,b|
                get_key(a, b)
            }
        end

        known_pxv_user_id_list.each do |elem|
            p = elem.p
            pred = p.prediction_up_cnt(true)

            if p.last_access_datetime_p(hide_day)
                recent_pxv_list << elem
                next
            end

            if p.rating.presence and p.rating == 0
                key = key_pxv_list_unset
                unit = 10
                fn = (p.filenum||0) / unit
                #key = %!#{key}(#{fn}f)!
                key = key + sprintf("%04d～", fn * unit)
                pxv_group[key] << elem
                next
            end

            case p.status
            when ArtistsController::Status::LONG_TERM_NO_UPDATS
                pxv_group[key_pxv_list_no_update_long] << elem
                next
            when ArtistsController::Status::SIX_MONTH_NO_UPDATS
                pxv_group[key_pxv_list_no_update_6m] << elem
                next
            when ArtistsController::Status::NO_ARTWORKS
                pxv_group[key_pxv_list_no_artworks] << elem
                next
            when ArtistsController::Status::SUSPEND
                pxv_group["905.#{p.status}"] << elem
                next
            else
            end

            if true
                if !(p.last_access_datetime_p(365))
                    #key_str = get_key_term(p.rating, key_pxv_list_no_access_1y)
                    str = key_pxv_list_no_access_1y
                    key_str = "!ご無沙汰" + method_proc.call(p.rating, str)
                    pxv_group[key_str] << elem
                elsif !(p.last_access_datetime_p(180))
                    #key_str = get_key_term(p.rating, key_pxv_list_no_access_6m)
                    str = key_pxv_list_no_access_6m
                    key_str = method_proc.call(p.rating, str)
                    pxv_group[key_str] << elem
                elsif !(p.last_access_datetime_p(150))
                    #key_str = get_key_term(p.rating, key_pxv_list_no_access_5m)
                    str = key_pxv_list_no_access_5m
                    key_str = method_proc.call(p.rating, str)
                    pxv_group[key_str] << elem
                elsif !(p.last_access_datetime_p(120))
                    #key_str = get_key_term(p.rating, key_pxv_list_no_access_4m)
                    str = key_pxv_list_no_access_4m
                    key_str = method_proc.call(p.rating, str)
                    pxv_group[key_str] << elem
                elsif !(p.last_access_datetime_p(90))
                    #key_str = get_key_term(p.rating, key_pxv_list_no_access_3m)
                    str = key_pxv_list_no_access_3m
                    key_str = method_proc.call(p.rating, str)
                    pxv_group[key_str] << elem
                elsif !(p.last_access_datetime_p(60))
                    #key_str = get_key_term(p.rating, key_pxv_list_no_access_2m)
                    str = key_pxv_list_no_access_2m
                    key_str = method_proc.call(p.rating, str)
                    pxv_group[key_str] << elem
                else
                    #key = key_pxv_list_pred + ":予測#{pred / 5 * 5}"
                    key = key_pxv_list_pred + sprintf(":予測%03d", pred / 5 * 5)
                   
                    pxv_group[key] << elem
                end
            else
                pxv_group[get_key(p.rating, "")] << elem
            end
        end

        recent_pxv_list
    end
end

class PxvArtist
    #extend ArtistName

    def self.init_exception_name_list()
        @@exception_name_list = Util::exception_name_list
        @@remove_word_list = Util::words_to_remove

        #@@remove_word_list.each do |x|
            #STDERR.puts %!"#{x}"!
        #end

        @@chg_list = []
    end

    def self.special_str_p(x)
        rgx_han = %r|[｡-ｦｧ-ｯｱ-ﾝﾞﾟ･ｰϘàäåÏïÜüËéëêÖö♾©♥ø² ₀ᵕ̈🩵]|
        #rgx_han2 = /\p{Emoji_Modifier_Base}\p{Emoji_Modifier}?|\p{Emoji_Presentation}|\p{Emoji}\uFE0F|\p{In_Letterlike_Symbols}|\p{In_Mathematical_Alphanumeric_Symbols}|\p{Egyptian_Hieroglyphs}|\p{Old_Italic}|\p{In_Enclosed_Alphanumerics}|\p{In_Enclosed_Alphanumeric_Supplement}/
        if x =~ rgx_han
        #if x =~ rgx_han or x =~ rgx_han2
            return true
        end
        false
    end

    def self.screen_width(str)
		ascii_len = str.each_char.count{|x| x.ascii_only?}
		hankaku_len = ascii_len + str.each_char.count{|x| special_str_p(x)}
		zenkaku_len = (str.size - hankaku_len) * 2

		result = hankaku_len + zenkaku_len
		result
	end

    def self.print_chg_list
        len_max = @@chg_list.map {|x| screen_width(x[1])}.max if @@chg_list.size > 0

        ##TODO: 文字スペースカウントする関数
        @@chg_list.each do |x|
            #spc1 = " "
            #spc2 = " "
            spc1 = " " * (len_max - screen_width(x[0]) + 1)
            spc2 = " " * (len_max - screen_width(x[1]) + 1)

            #str = x[1]
            #STDERR.puts %!"#{str}" => #{screen_width(str)}!

            STDERR.puts %!"#{x[0]}"! + spc1 + %!"#{x[1]}"! +spc2 + %!"#{x[2]}"!
        end
    end

    attr_accessor :pxv_user_id, :pxv_name, :path_list,
                :last_dl_datetime, :last_ul_datetime, 
                :earliest_ul_date, :last_access_datetime,
                :oldest_artwork_id, :latest_artwork_id

    def initialize(id, path)
        @pxv_user_id = id

        user_name = Pxv::get_user_name_from_path(path)
        @pxv_name = ArtistName::get_name_part_only(user_name, @@exception_name_list, @@remove_word_list)

        if user_name != @pxv_name
            removed_str = user_name.gsub(@pxv_name, "")
            @@chg_list << [removed_str, user_name, @pxv_name]
        end

        #@pxv_name = user_name #### TODO:
        @path_list = []
        filepath_list = UrlTxtReader::get_path_list(path)
        @path_list = Pxv::sort_pathlist(filepath_list)

        if @path_list.size == 0
            STDERR.puts %!PxvArtist#ctor:ファイルが存在しません(#{id})"#{path}"!
            return
        end

        fpath = Util::get_public_path(@path_list[-1]) #正確ではないが大体で良い
        @last_dl_datetime = File.birthtime(fpath.gsub("%23", "#"))
        @last_access_datetime = @last_dl_datetime


        @latest_artwork_id, date_str, _ = Pxv::get_pxv_artwork_info_from_path(@path_list[0])
        @last_ul_datetime = Time.parse(date_str)
        @oldest_artwork_id, date_str, _ = Pxv::get_pxv_artwork_info_from_path(@path_list[-1])
        @earliest_ul_date = Time.parse(date_str)

        if @last_ul_datetime < @earliest_ul_date
            STDERR.puts %!????#{@last_ul_datetime}|#{@earliest_ul_date}!
        end

        if @latest_artwork_id < @oldest_artwork_id
            STDERR.puts %!????#{@latest_artwork_id}|#{@oldest_artwork_id}!
        end
    end

    def to_s
        %!#{pxv_name}(#{pxv_user_id})\nDL日:#{last_dl_datetime}\n最新UL日:#{last_ul_datetime}\n最古UL日:#{earliest_ul_date}\nアクセス日時:#{last_access_datetime}!
    end
end

class PxvArtworkInfo
    attr_accessor :art_id, :publication_date, :title, :path_list

    def initialize(artwork_id, title, date, path)
        @art_id = artwork_id
        @title = title
        @publication_date = date
        @path_list = []
        @path_list << path
    end

    def append_path(path)
        @path_list << path
    end
end
