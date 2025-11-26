# coding: utf-8

#require "active_support/core_ext/numeric/conversions"

require_relative "url_txt_reader"

# =============================================================================
# 
# =============================================================================
module Twt
    extend ActiveSupport::Concern

    TWT_DOMAIN_NAME_ORIG = %!twitter.com!
    TWT_DOMAIN_NAME_ELON = %!x.com!
    TWT_DOMAIN_NAME = TWT_DOMAIN_NAME_ELON

    TWT_HTTP_URL = %!https://#{TWT_DOMAIN_NAME}!

    TWT_USER_DEV = "TwitterDev" #"i"でよい?

    TWT_RGX_URL_BASE = ""
    TWT_RGX_URL = %r!https?://(?:x|twitter)\.com/\w+/status/(\d+)!
    TWT_URL_SCREEN_NAME_RGX = %r!(?:x|twitter)\.com/(\w+)!
    TWT_TOP_SCREEN_NAME_RGX = /^(\w+)\s?/
    TWT_AT_SCREEN_NAME_RGX = /\(@(\w+)\)/

    TWT_SP_FILENAME_RGX = /(\d{8}_\d{6})/

    TMP_DIR_PATH = "public/d_dl/"

    TWT_CURRENT_DIR_PATH = TMP_DIR_PATH + "Twitter/"
    TWT_TMP_DIR_PATH     = TMP_DIR_PATH + "Twitter-/"
    TWT_TMP_DIR_PATH_A   = TMP_DIR_PATH + "Twitter-/a/"
    TWT_SP_DIR_PATH      = TMP_DIR_PATH + "twitter_sp/"

    TWT_ARCHIVE_DIR_PATH = "public/twt"
    TWT_DIRLIST_TXT_PATH = "#{TWT_ARCHIVE_DIR_PATH}/dirlist.txt"

    UL_FREQUECNTY_THRESHOLD = 150
    RATING_THRESHOLD = 80

    FILESIZE_THRESHOLD_KB = 600
    FILESIZE_THRESHOLD = FILESIZE_THRESHOLD_KB * 1024


    def self.get_twt_tweet_ids_from_txts(twtid)
        txts = UrlTxtReader::get_url_txt_contents_uniq_ary([])
        twt_ids = get_tweet_ids(txts, twtid)
        twt_ids
    end

    def self.get_tweet_id_from_url(url)
        tweet_id = nil
        if url =~ TWT_RGX_URL
            tweet_id = $1.to_i
        end
        tweet_id
    end
    
    def self.get_tweet_ids(txts, twtid)
        twt_ids = []
        rgx = %r!https?://(?:x|twitter)\.com/#{twtid}/status/(\d+)!
        txts.each do |line|
            line.chomp!
            if line =~ rgx
                tweet_id = $1.to_i
                twt_ids << tweet_id
            else
                #puts line
            end
        end
        twt_ids.sort.uniq
    end

    def self.get_dir_path_by_twtid(twt_root, twtid)
        puts %!twt_root="#{twt_root}", twtid="#{twtid}"!
        wk_twt_screen_name = twtid.downcase
        Dir.glob(twt_root).each do |path|
            if File.basename(path).downcase =~ TWT_TOP_SCREEN_NAME_RGX
                #STDERR.puts %!"#{path}"!
                id = $1
                if wk_twt_screen_name == id
                    puts %!get_dir_path_by_twtid("#{twtid}"):path="#{path}"!
                    return path
                end
            end
        end
        ""
    end

    def self.get_twt_user_path_list(path, wc, twtid)
        twt_root = Rails.root.join(path).to_s + wc
        dirpath = get_dir_path_by_twtid(twt_root, twtid)
        if dirpath != ""
            STDERR.puts %!"#{twt_root}"/@#{twtid}!
        end
        UrlTxtReader::get_path_list(dirpath)
    end

    def self.get_pic_filelist(twtid, read_archive=true)
        path_list = []

        if read_archive
            tpath = get_twt_path_from_dirlist(twtid)
            STDERR.puts %![get_pic_filelist] twtid="#{twtid}" archive dir path="#{tpath}"!

            path_list << UrlTxtReader::get_path_list(tpath)
        end

        path_list << get_twt_user_path_list(TWT_CURRENT_DIR_PATH, "*/", twtid)

        if Dir.exist?(TWT_TMP_DIR_PATH_A)
            #twt_root = Rails.root.join(TWT_TMP_DIR_PATH).to_s + "*/*/"
            twt_root = Rails.root.join(TWT_TMP_DIR_PATH).to_s + "*/*/"
            STDERR.puts %![get_pic_filelist] "#{TWT_TMP_DIR_PATH_A}"\ttwt_root="#{twt_root}"!

            dirpath = get_dir_path_by_twtid(twt_root, twtid)
            path_list << UrlTxtReader::get_path_list(dirpath)
        elsif Dir.exist?(TWT_TMP_DIR_PATH)
            twt_root = Rails.root.join(TWT_TMP_DIR_PATH).to_s + "*/"
            STDERR.puts %![get_pic_filelist] "#{TWT_TMP_DIR_PATH}"\ttwt_root="#{twt_root}"!

            dirpath = get_dir_path_by_twtid(twt_root, twtid)
            path_list << UrlTxtReader::get_path_list(dirpath)
        else
            STDERR.puts %![get_pic_filelist] どっちもない:"#{TWT_TMP_DIR_PATH_A}"/"#{TWT_TMP_DIR_PATH}"!
        end

        path_list.flatten.sort.reverse
    end

    def self.get_twt_path_from_dirlist(twtid)
        path = ""
        unless File.exist? TWT_DIRLIST_TXT_PATH
            STDERR.puts %!ファイルがない:"#{TWT_DIRLIST_TXT_PATH}"!
            return path
        end

        txtpath = Rails.root.join(TWT_DIRLIST_TXT_PATH).to_s
        File.open(txtpath) { |file|
            rgx = %r!#{TWT_ARCHIVE_DIR_PATH}\/.\/#{twtid.downcase}!
            STDERR.puts %![get_twt_path_from_dirlist] rgx="#{rgx}"!
            while line = file.gets
                #if line =~ %r!#{TWT_ARCHIVE_DIR_PATH}/./#{twtid}!
                if line.downcase =~ rgx
                    path << line.chomp
                    STDERR.puts %!"#{line}"!
                    break
                end
            end
        }
        path
    end

    def self.twt_user_list(target_dir)
        path_list = []

        if target_dir == "new"
            path_list << Util::glob(TWT_CURRENT_DIR_PATH)
        elsif target_dir == "old"
            path_list << Util::glob("#{TWT_ARCHIVE_DIR_PATH}/", "*/*")
        else
            path_list << Util::glob(TWT_CURRENT_DIR_PATH)
            path_list << Util::glob("#{TWT_ARCHIVE_DIR_PATH}/", "*/*")
        end

        STDERR.puts %!path_list=#{path_list.size}!
        artist_hash = {}
        path_list.flatten.each do |path|
            STDERR.print "."
            set_twt_user(artist_hash, path)
        end
        STDERR.puts

        #artist_hash.sort_by{|s| [s[0].downcase, s[0]]}.to_h
        artist_hash.sort_by{|_, v| v.ctime}.to_h
    end

    def self.set_twt_user(artist_hash, path)
        dirname = File.basename path
        if dirname =~ /(\w+)\s*(.*)/
            twtid = $1
            id = twtid.downcase
            name = $2.strip

            if artist_hash.include? id
                STDERR.puts %!+:@#{id}!
                artist_hash[id].append_path(path)
            else
                #STDERR.puts %!\!:@#{id}!
                #artist_hash[id] = TwtArtist.new(id, name, path)
                artist_hash[id] = TwtArtist.new(twtid, name, path)
                artist_hash[id].set_filenum
            end
        else
            msg = %!invalid format:"#{path}" (#{__FILE__}:#{__LINE__})!
            Rails.logger.warning(msg)
        end
    end

    def self.get_twtid_list(path_list)
        id_list = {}
        path_list.flatten.each do |path|
            if FileTest.file? path
                STDERR.puts %!not direcotry. "#{path}"!
                next
            end

            dirname = File.basename path
            if dirname =~ /^(\w+)/
                #TODO:同じIDが複数あったときの対応
                twtid = $1
                id_list[twtid] = path
            else
                STDERR.puts %!invalid format:"#{dirname}"\t"#{path}"\t(#{__FILE__}:#{__LINE__})!
            end
        end
        id_list
    end

    def self.archive_check()
        path_list = []
        path_list << Util::glob("#{TWT_ARCHIVE_DIR_PATH}/", "*/*")
        
        twtid_list = get_twtid_list(path_list.flatten)
        twtid_list.each do |twtid, path|

            twt = Twitter.find_by_twtid_ignore_case(twtid)
            if twt
            else
                STDERR.puts %!unknonw id:"#{twtid}"|"#{path}"!
            end
        end
    end

    def self.parse_dirname(path)
        tmp_struct = Struct.new(:path, :dirname, :screen_name, :twt)

        dirname = File.basename path
        if dirname =~ TWT_AT_SCREEN_NAME_RGX
            screen_name = $1
            twt = Twitter.find_by_twtid_ignore_case(screen_name)
        else
            screen_name = ""
        end
        tmp_struct.new(path, dirname, screen_name, twt)
    end

    def self.sp_dirs()
        path_list = Util::glob("#{TWT_SP_DIR_PATH}")
        #path_list.map {|path| parse_dirname path}.sort_by {|x| x.screen_name}
        tmp = path_list.map {|path| parse_dirname path}
        tmp.sort_by {|x|
            if x.twt
                x.twt.last_access_datetime
            else
                Time.new(2001,1,1)
            end
        }
    end

    def self.get_sp_path(twtid)
        target_path = nil
        base_path = UrlTxtReader::public_path(TWT_SP_DIR_PATH) + "*/"
        Dir.glob(base_path).each do |path|
            if File.basename(path) =~ TWT_AT_SCREEN_NAME_RGX
                id = $1
                #STDERR.puts %!"#{path}", "#{id}"!
                if twtid == id
                    target_path = path
                    break
                end
            end
        end

        STDERR.puts %!twtid=@#{twtid}, base_path="#{base_path}", target_path="#{target_path}"!

        target_path
    end

    def self.get_sp_pic_filelist(target_path)
        if target_path
            path_list = UrlTxtReader::get_path_list(target_path)
        end
        STDERR.puts %!twtid="#{twtid}", target_path="#{target_path}", #{path_list.size if path_list}!
        path_list
    end

    def self.sp_datetime_str_to_datetime(datetime_str)
        Util::string_to_datetime(datetime_str).in_time_zone('Tokyo')
    end

    def self.get_sp_tweet_id_from_filename(filename)
        if filename =~ TWT_SP_FILENAME_RGX
            datetime_str = $1
            datetime = sp_datetime_str_to_datetime(datetime_str)
            time2tweet_id(datetime)
        else
            nil
        end
    end

    def self.get_sp_tweet_id_from_filepath(fpath)
        filename = File.basename(fpath)
        get_sp_tweet_id_from_filename(filename)
    end
    
    def self.get_tweet_info_from_path(path)
        path_list = UrlTxtReader::get_path_list(path)
        if path_list and path_list.size > 0
            path_list = path_list.sort
            fpath_last = path_list.last
            fpath_first = path_list.first
            tweet_id = get_sp_tweet_id_from_filepath(fpath_last)
        end
        [tweet_id, fpath_last, fpath_first]
    end

    def self.sp_tweet_id_with_comma(twtid)
        dirpath = Twt::get_sp_path(twtid)
        if dirpath
            tinfo = Twt::get_tweet_info_from_path(dirpath)
            puts %!sp_tweet_id_with_comma:"#{}"!
            Twt::tweet_id_with_comma tinfo[0]
        else
            nil
        end
    end

    def self.get_sp_pic_filelist_by_twtid(twtid)
        dirpath = Twt::get_sp_path(twtid)
        if dirpath
            path_list = UrlTxtReader::get_path_list(dirpath)
        else
            nil
        end
    end

    def self.twt_user_infos()
        path_list = []
        path_list << Util::glob(TWT_CURRENT_DIR_PATH)

        artist_hash = {}

        twtid_list = get_twtid_list(path_list.flatten)
        twtid_list.each do |twtid, path|
            twt = Twitter.find_by_twtid_ignore_case(twtid)
            if twt.presence and (twt.rating != nil and twt.rating != 0)
                #puts %!known @#{twtid}!
                next
            end

            artist_hash[twtid] = TwtArtist.new(twtid, "", path)
            artist_hash[twtid].set_filenum
        end

        artist_hash.sort_by{|_, v| -v.num_of_files}.to_h
    end

    def self.user_exist?(twtid)
        path_list = Util::glob(TWT_CURRENT_DIR_PATH)
        list = path_list.map {|x| File.basename(x).downcase}
        return list.include? twtid.downcase
    end

    def self.twt_user_url(screen_name)
        %!#{TWT_HTTP_URL}/#{screen_name}!
    end

    def self.twt_user_media_url(screen_name)
        %!#{TWT_HTTP_URL}/#{screen_name}/media!
    end

    def self.twt_tweet_url(screen_name, tweet_id)
        %!#{TWT_HTTP_URL}/#{screen_name}/status/#{tweet_id}!
    end

    def self.twt_tweet_url_dev(tweet_id)
        twt_tweet_url(TWT_USER_DEV, tweet_id)
    end

    def self.get_tweet_id_from_url(url)
        search_tweet_id = nil
        if url =~ /status\/(\d+)/
            search_tweet_id = $1.to_i
        elsif url =~ /(\d+)/
            search_tweet_id = $1.to_i
        else
        end
        search_tweet_id
    end

    def self.search_tweet(twt_pic_path_list, search_tweet_id)
        if search_tweet_id == nil
            STDERR.puts %![search_tweet]:"#{search_tweet_id}"!
        end

        paths = []

        twt_pic_path_list.each do |x|
            tweet_id, _ = get_tweet_info_from_filepath(x)
            if tweet_id == search_tweet_id
                paths << x
            end
        end

        paths
    end

    def self.db_update_new_user(key, val)
        #STDERR.puts %![db_update_new_user] @#{key}!
        pic_path_list = val.twt_pic_path_list
        if pic_path_list.size == 0
            STDERR.puts %!ファイルなし: @#{key}!
            return
        end

        twt_params = {}
        twt_params[:twtid] = val.twt_id
        twt_params[:last_dl_datetime] = val.ctime
        twt_params[:last_access_datetime] = val.ctime
        twt_params[:last_post_datetime] = val.last_post_datetime(pic_path_list)

        twt_params[:latest_tweet_id] = val.get_last_post_tweet_id(pic_path_list)
        twt_params[:oldest_tweet_id] = val.get_oldest_post_tweet_id(pic_path_list)

        twt_params[:filenum] = val.num_of_files
        twt_params[:recent_filenum] = val.num_of_files
        twt_params[:update_frequency] = val.calc_freq(pic_path_list)
        pxv = Artist.find_by_twtid_ignore_case(val.twt_id)
        if pxv
            twt_params[:pxvid] = pxv.pxvid
        end
        
        old_twt = Twitter.find_by(new_twtid: val.twt_id)
        if old_twt
            twt_params[:old_twtid] = old_twt.twtid
        end

        msg = %!新規登録アカウント => "@#{key}"!
        Rails.logger.info(msg)

        twt = Twitter.new(twt_params)
        twt.save
    end

    def self.db_update_user_update(key, val, twt)
        #STDERR.puts %![db_update_user_update] @#{key}!

        pic_path_list = val.twt_pic_path_list
        twt_params = {}

        last_post_datetime = Time.at(val.last_post_datetime(pic_path_list).to_i)
        if twt.last_post_datetime.presence
            #p twt.last_post_datetime
            #p last_post_datetime
            #puts %!i=#{twt.last_post_datetime.to_i}, class=#{twt.last_post_datetime.class}!
            #puts %!i=#{last_post_datetime.to_i}, class=#{last_post_datetime.class}!
            if last_post_datetime.after? (twt.last_post_datetime)
                #puts %!update[last_post_datetime]:"#{pic_path_list[0]}"\told="#{twt.last_post_datetime}",new="#{last_post_datetime}"!
                twt_params[:last_post_datetime] = last_post_datetime
            else
                #更新しない
                #STDERR.puts %![no update] "#{key}":"#{twt.last_post_datetime}":"#{last_post_datetime}"!
                
                #######################
                ##### 
                ######################
                return
            end
        else
            puts %!update(new):"#{pic_path_list[0]}"\t=>"#{last_post_datetime}"!
            twt_params[:last_post_datetime] = last_post_datetime
        end

        if twt.last_dl_datetime.presence
            if twt.last_dl_datetime < val.ctime
                twt_params[:last_dl_datetime] = val.ctime
            end
        else
            twt_params[:last_dl_datetime] = val.ctime
        end

        last_post_tweet_id = val.get_last_post_tweet_id(pic_path_list)
        if twt.latest_tweet_id.presence
            if twt.latest_tweet_id < last_post_tweet_id
                twt_params[:latest_tweet_id] = last_post_tweet_id
            end
        else
            twt_params[:latest_tweet_id] = last_post_tweet_id
        end
        #if twt_params[:latest_tweet_id]
        #    STDERR.puts %!"#{twt.latest_tweet_id}" => "#{twt_params[:latest_tweet_id]}"!
        #end

        oldest_post_tweet_id = val.get_oldest_post_tweet_id(pic_path_list)
        if twt.oldest_tweet_id.presence
            if twt.oldest_tweet_id > oldest_post_tweet_id
                twt_params[:oldest_tweet_id] = oldest_post_tweet_id
            end
        else
            twt_params[:oldest_tweet_id] = oldest_post_tweet_id
        end
        #if twt_params[:oldest_tweet_id]
        #    STDERR.puts %!"#{twt.oldest_tweet_id}" => "#{twt_params[:oldest_tweet_id]}"!
        #end

        if twt.filenum == nil or twt.filenum < val.num_of_files
            twt_params[:filenum] = val.num_of_files
        else
            #あほかtwt_params[:filenum] = 
        end

        if twt.recent_filenum == nil or twt.recent_filenum < val.num_of_files
            twt_params[:recent_filenum] = val.num_of_files
        end

        if twt.update_frequency == nil #or pic_path_list.size > 10
            update_frequency = val.calc_freq(pic_path_list)
            twt_params[:update_frequency] = update_frequency
            msg = %!(@#{key}) update_frequency:"#{twt.update_frequency}" => "#{update_frequency}"!
            Rails.logger.info(msg)
        end

        if twt_params.size > 0
            msg = "更新内容 => #{twt_params}\t@#{key}(#{twt.twtname})"
            #STDERR.puts msg
            Rails.logger.info(msg)

            #twt.update(twt_params)
        end

        twt.update(twt_params)
    end

    def self.db_update_by_newdir()
        twt_id_list = twt_user_list("new")

        STDERR.puts %!db_update_by_newdir:xx!
        twt_id_list.each do |key, val|
            twt = Twitter.find_by_twtid_ignore_case(key)
            if twt == nil
                # 新規追加
                db_update_new_user(key, val)
            else
                db_update_user_update(key, val, twt)
            end
        end
    end

    def self.db_update_dup_files_current_all()
        dir_path = TWT_CURRENT_DIR_PATH
        pic_list = UrlTxtReader::get_path_list(dir_path)

        #TODO:???未実装???
    end

    def self.update_tweet_records_by_fs()
        tweet_list = TweetList.new

        dir_path = TWT_CURRENT_DIR_PATH
        pic_list = UrlTxtReader::get_path_list(dir_path)

        #STDERR.puts %!#{pic_list.size}!
        pic_list.each do |path|
            tweet_id, pic_no = get_tweet_info_from_filepath(path)
            tweet_rcd = Tweet.find_by(tweet_id: tweet_id)
            if tweet_rcd
                # DBに登録済み
                STDERR.puts %!登録済み => #{tweet_id}\t##{pic_no}\t"#{path}"!
            else
                if tweet_list.tweet_id_exist? tweet_id
                    # DBに登録
                    twt_screen_name = Util.parent_dirname path
                    Tweet::create_record(twt_screen_name, tweet_id, Tweet::StatusEnum::SAVED, pic_no)
                    STDERR.puts %!@#{twt_screen_name}\t#{tweet_id}\t##{pic_no}\t"#{path}"!
                end
            end

            #break
        end
        [pic_list, tweet_list]
    end

    def self.get_hash_val_hash(pic_list)
        hash_hash = Hash.new { |h, k| h[k] = [] }
        i = 0
        pic_list.each do |path|
            #unless db_update
                #STDERR.puts %!(#{pic_list.size})"#{path}"!
            #end
            hash_val = Util::file_hash path
            filesize = FileTest.size(path)
            hash_hash[[hash_val, filesize]] << path

            i += 1
            if i % 100 == 0
                print "."
            end
            if i % 1000 == 0
                puts i
            end
        end
        puts ""

        hash_hash
    end

    def self.get_dup_tweet_list(v, screen_name_arg)
        dup_tweet_list = []
        tweet_id_hash = {}

        v.each do |path|
            tweet_id, pic_no = get_tweet_info_from_filepath(path)
            if tweet_id_hash.has_key? tweet_id
                # 同一のTweet idの場合は単純に同じツイートを多重で保存しただけとして記録しない
                puts %!重複DL(DLミス[同一ID]):"#{path}"!
                next
            end
            tweet_id_hash[tweet_id] = true

            if screen_name_arg.presence
                dirname = screen_name_arg
            else
                dirname = File.basename(File.dirname path)
            end

            puts %!@#{dirname}:#{tweet_id}:#{pic_no} "#{path}"!
            dup_tweet_list << [dirname, tweet_id, pic_no]
        end

        dup_tweet_list
    end

    def self.create_tweet_record(dup_tweet_list, db_update)
        dup_tweet_list2 = dup_tweet_list.sort_by {|x| x[1]}[1..-1]
        dup_tweet_list2.each do |x|
            twt_screen_name, tweet_id, pic_no = x
            tweet_rcd = Tweet.find_by(tweet_id: tweet_id)
            if tweet_rcd == nil
                if db_update
                    Tweet::create_record(twt_screen_name, tweet_id, Tweet::StatusEnum::DUPLICATE, pic_no)
                else
                    puts %!同一のファイルです:#{tweet_id}-#{pic_no}(@#{twt_screen_name})!
                end
            else
                puts %!すでに登録済みです:@#{twt_screen_name}:#{tweet_id}:#{pic_no}/#{tweet_rcd}"!
                if db_update
                    #Tweet::update_tweet_record(tweet_rcd, tweet_id, status: Tweet::StatusEnum::DUPLICATE, rating: nil, remarks: nil)
                end
            end
        end
    end

    def self.db_update_dup_files(pic_list, screen_name_arg="", db_update=true)
        STDERR.puts %!### 重複チェック ### ===>!
        puts %!(#{__FILE__}:#{__LINE__}) #{__method__}():n=#{pic_list.size}!

        dup_path_list = []
        hash_hash = get_hash_val_hash(pic_list)
        hash_hash.each do |k, v|
            if v.size < 2
                #重複してないので次へ
                next
            end

            dup_path_list << v

            hash_val = k[0]
            filesize = k[1]

            puts
            puts "#" * 100
            puts "key=#{hash_val}/filesize=#{filesize}"
            puts "#" * 100

            dup_tweet_list = get_dup_tweet_list(v, screen_name_arg)
            puts ""

            scrn_names = dup_tweet_list.map {|x| x[0]}
            if scrn_names.uniq.size != 1
                puts %!異なるスクリーンネームに保存されているファイルがあります:#{scrn_names.uniq}!
            end

            create_tweet_record(dup_tweet_list, db_update)
        end
        dup_path_list.flatten
    end

    def self.get_tweet_info_from_filepath(filepath)
        fn = File.basename filepath
        get_tweet_info(fn)
    end

    def self.sort_by_tweet_id(pic_path_list)
        pic_path_list.sort_by {|x| [Twt::twt_path_str(x)]}.reverse
    end

    def self.get_tweet_info(filename)
        TweetInfo::get_tweet_info(filename)
    end

    TW_EPOCH = 1288834974657  # 単位：ミリ秒
    def self.get_timestamp(tweet_id)
        timestamp = Time.at(((tweet_id >> 22) + TW_EPOCH) / 1000.0)
    end

    def self.time2tweet_id(time)
        (time.to_f * 1000 - TW_EPOCH).to_i << 22
    end

    def self.timestamp_str(tweet_id)
        ts = get_timestamp(tweet_id)
        #ts.strftime("%Y-%m-%d %H:%M:%S.%L %Z")
        ts.strftime("%Y-%m-%d %H:%M")
    end

    def self.date_info(tweet_id)
        ts = get_timestamp(tweet_id)
        Util::get_date_info(ts)
    end

    def self.twt_path_str(path)
        fn = File.basename path

        tweet_id, pic_no = get_tweet_info(fn)

        if tweet_id == 0
            if fn =~ TWT_SP_FILENAME_RGX
                datetime = sp_datetime_str_to_datetime($1)
                date_str = %![#{datetime.strftime("%Y-%m-%d")}]!
                tweet_id2 = time2tweet_id(datetime)
                twt_id_str = tweet_id_with_comma(tweet_id2)
            else
                fullpath = Rails.root.join("public/" + path)
                mtime = File::mtime(fullpath)
                date_str = %![#{mtime.strftime("%Y-%m-%d")}]!
                twt_id_str = tweet_id_with_comma(tweet_id)
            end
        else
            twt_id_str = tweet_id_with_comma(tweet_id)
            ul_datestr = timestamp_str(tweet_id)
            date_str = %!【#{ul_datestr}】!
        end
        %!<#{twt_id_str}>#{4 - pic_no}#{date_str}[#{fn})(#{File.dirname path}]!
    end

    def self.tweet_id_with_comma(tweet_id)
        tweet_id.to_s.reverse.gsub(/\d{3}/, '\0,').reverse
    end

    def self.get_time_from_path(filepath)
        if filepath == nil
            STDERR.puts %!"err:#{filepath}"! #nilがでるだけ...
            return nil
        end
        filename = File.basename(filepath)
        tweet_id, _  = get_tweet_info(filename)
        time = get_timestamp(tweet_id)
        if tweet_id == 0
            STDERR.puts %!#{tweet_id}:#{time}!
        end
        time
    end

    CALC_FREQ_DAY_NUM = 30
    CALC_FREQ_UNIT = 100

    # pic_path_listはソートされている必要がある（新しい順）
    def self.calc_freq(pic_path_list, calc_freq_day_num=CALC_FREQ_DAY_NUM)
        if pic_path_list == nil or pic_path_list.size == 0
            return 0
        end
        latest_time = get_time_from_path(pic_path_list[0])

        days = 1
        cnt = 0
        pic_path_list.each do |path|
            post_time = get_time_from_path(path)
            
            #puts time.to_date
            tmp_days =  (latest_time.to_date - post_time.to_date).to_i + 1
            if tmp_days >= calc_freq_day_num
                break
            end
            days = tmp_days
            cnt += 1
            #puts %!#{cnt}:#{days}<#{post_time.strftime("%Y-%m-%d %H:%M")}>:[#{path}]!
        end
        if cnt == 1 and days == 1
            point = (cnt * CALC_FREQ_UNIT / calc_freq_day_num)
        else
            point = (cnt * CALC_FREQ_UNIT / days)
            puts %!calc_freq_day_num=#{calc_freq_day_num} : point=#{point} <= cnt=#{cnt}, days=#{days}, 最新：#{latest_time.to_date}!
        end
        point
    end

    def self.image_num_a_post(tweet_id_list)
        hash = Hash.new {|h, k| h[k] = []}

        tweet_id_list.each do |x|
            tweet_id, pic_no = x
            
            if hash.has_key?(tweet_id)
                hash[tweet_id] += 1
            else
                hash[tweet_id] = 1
            end
        end

        v = hash.values
        if v.size > 0
            (v.sum * 10 / v.size + 5) / 10
        else
            0
        end
    end

    def self.get_screen_name(str)
        if str =~ TWT_URL_SCREEN_NAME_RGX
            screen_name = $1
        elsif str =~ /^@(\w+)/ #/(\w+)/ではだめ？？？
            result = $1
            screen_name = result
        elsif str =~ /(\w+)/
            result = $1
            if result != str
                screen_name = result
            else
                screen_name = str
            end
        else
            screen_name = str
        end

        if str != screen_name
            puts %![LOG]変更あり "#{screen_name}" <= "#{str}"!
        end

        return screen_name
    end

    def self.sanitize_filename(filename)
        # 禁止文字とその代替全角文字のマッピング
        # 必要に応じて、他の文字もここに追加してください
        replacements = {
            "/" => "／",
            "?" => "？",
            "\\" => "＼",
            ":" => "：",
            "*" => "＊",
            "\"" => "”",
            "<" => "＜",
            ">" => "＞",
            "|" => "｜"
        }

        sanitized_name = filename.dup # 元の文字列を変更しないために複製

        replacements.each do |forbidden_char, replacement_char|
            sanitized_name.gsub!(forbidden_char, replacement_char)
        end

        sanitized_name
    end

    def self.get_pic_info_path_list()
        base_path = UrlTxtReader::public_path(TWT_CURRENT_DIR_PATH)
        rg_filename = %r%!pic_infos!.*\.tsv%

        STDERR.puts %!"#{base_path}"/"#{rg_filename}"!

        path_list = []
        Dir.glob(base_path + "*") do |path|
            if path =~ rg_filename
                path_list << path
                #break
            else
           end
        end
        path_list
    end

    def self.get_pic_infos(path_list, scrn_name=nil)

        exist_chk = false
        twtdirs = TwtDirs.new
        hash = Hash.new { |h, k| h[k] = [] }
        path_list.each do |fpath|
            STDERR.puts %!get_pic_infos:=== "#{fpath}" ===>!
            tsv = CSV.read(fpath, headers: false, col_sep: "\t")
            tsv.each do |row|
                path = row[0]
                screen_name = Util::parent_dirname(path) #BUG:階層が深いとだめ

                if scrn_name and screen_name != scrn_name
                    next
                end

                if exist_chk
                    # TODO:毎回チェックするのは無駄
                    user_exist = twtdirs.user_exist?(screen_name)
                    if user_exist
                    else
                        next
                    end
                end

                #TODO: 1pixelあたりのバイトサイズ計算
                
                picpath = row[0]
                filesize = row[1].to_i
                width = row[2].to_i
                height = row[3].to_i
                hash_val = row[4]

                #tinfo = get_tweet_info_from_filepath(path)
                #STDERR.puts %!@#{screen_name} #{tinfo}!
                hash[screen_name] << filesize
            end
        end

        STDERR.puts %!get_pic_infos: size=#{hash.size}!

        hash
    end

    @@hoge = nil #controllerからだと毎回初期化される？？？よくわからん。DBに保存しないとだめぽい

    def self.get_pic_infos_ex()
=begin
        AppData::FILESIZE_HASH.each do |k,v|
            puts %!@#{k}:#{v}!
        end
=end
        #AppData::FILESIZE_HASH

        if @@hoge == nil or @@hoge.size == 0
            @@hoge = init_pic_infos
        else
            STDERR.puts "get_pic_infos_ex(): #{@@hoge.size}"
        end
        @@hoge
    end

    def self.init_pic_infos()
        STDERR.puts "init_pic_infos()"
        path_list = get_pic_info_path_list
        hash = get_pic_infos(path_list)
        hash
    end

    Tmp_struct = Struct.new(:avg, :max, :min, :cnt)

    def self.map_pic_infos(hash, threshold_kb)

        hash2 = hash.map {|k,v|
            [
                k,
                Tmp_struct.new(v.sum / v.size, v.max, v.min, v.size)
            ]
        }.select {|x|
            x[1].cnt > 30 and x[1].avg > threshold_kb
        }.map {|x|
            [
                x[0],
                [
                    x[1],
                    Twitter.find_by(twtid: x[0])
                ]
            ]
        }.to_h

        STDERR.puts %!#{hash.size} => #{hash2.size}!

        hash2
    end

    def self.list_pic_infos(hash2)
        hash2.each do |k,val|
            v = val[0]
            #twt = Twitter.find_by(twtid: k)
            twt = val[1]
            if twt
                if twt.status != Twitter::TWT_STATUS::STATUS_PATROL
                    next
                end

                if twt.drawing_method and twt.drawing_method != Twitter::DRAWING_METHOD::DM_AI
                    next
                end

                if (twt.rating||0) < RATING_THRESHOLD
                    next
                end

                pred_str = sprintf(%!%3d!, twt.update_frequency)
                postdate = twt.last_post_datetime.in_time_zone('Tokyo').strftime("%y/%m/%d")
                dayn = sprintf("%3d", Util::get_date_delta(twt.last_post_datetime))
                inf = %![#{pred_str}] #{postdate}(#{dayn})【#{twt.rating}/#{twt.r18}】#{twt.twtname}(@#{k})!
            else
                inf = %!"@#{k}"!
            end
            msg = sprintf(%!%5d %10s %s!,
                v.cnt,
                Util::formatFileSizeKB(v.avg),
                inf)
            STDERR.puts(msg)
        end
    end

    def self.get_key_elem(twt, k, v, url_list)
        postdate = twt.last_post_datetime.in_time_zone('Tokyo').strftime("%y/%m/%d %H:%M")
        dayn = Util::get_date_delta(twt.last_post_datetime)
        avg = v.avg / 1024
        pred = twt.prediction

        elem = []
        elem << k
        elem << %!"#{twt.twtname}"!
        elem << twt.update_frequency
        elem << postdate
        elem << dayn
        elem << twt.rating
        elem << twt.r18
        elem << avg
        elem << v.cnt
        elem << pred
        if url_list
            elem << url_list.todo_cnt
            elem << url_list.url_cnt
        else
            elem << 0
            elem << 0
        end

        d_unit = 15
        elapse = dayn / d_unit
        unit = 10
        if pred >= unit
            pr = pred / unit * unit
        else
            pr = pred / 5 * 5
            if pr == 0 and pred > 0
                pr = 1
            end
        end

        key = "#{Util::format_num(twt.update_frequency, 100, 4)}|||更新頻度:#{Util::format_num(twt.update_frequency, 50, 4)}"

        [key, elem]
    end

    def self.build_pic_info_list(hash)

        known_twt_url_list, _ = Twitter::url_list("all")
        #url_list_summary = Tweet::url_list_summary(known_twt_url_list)
        #url_list_summary_h = url_list_summary.map {|x| [x.screen_name, x]}.to_h
        url_list_summary_h = Tweet::url_list_summary_hash(known_twt_url_list)

        list = Hash.new { |h, k| h[k] = [] }
        hash.each do |k,val|
            v = val[0]
            twt = val[1]
            unless twt
                next
            end

            if twt.status != Twitter::TWT_STATUS::STATUS_PATROL
                next
            end

            if twt.drawing_method and twt.drawing_method != Twitter::DRAWING_METHOD::DM_AI
                next
            end

            if (twt.rating||0) < 80
                next
            end

            if twt.ul_freq_low?
                next
            end

            key, elem = get_key_elem(twt, k, v, url_list_summary_h[k])

            list[key] << elem
        end

        list
    end

    def self.output_csv(list)
        screen_names = []
        list2 = list.sort_by {|k,v| k}.reverse.to_h
        list2.each do |k, v|
            v.each do |line|
                #puts line
                #STDERR.puts "########################"
                STDERR.puts(%!#{k}(#{v.size}),#{line.join(",")}!)
                #STDERR.puts "########################"

                screen_names << line[0]
            end
        end

        screen_names
    end

    def self.load_pic_info_tsv()
        hash = get_pic_infos_ex

        threshold_kb = FILESIZE_THRESHOLD
        hash2 = map_pic_infos(hash, threshold_kb)

        if hash2
            hash3 = hash2.sort_by {|k, x|
                x[1]?(x[1].rating||0):0
            }.reverse.to_h
            list = build_pic_info_list(hash3)

            keys = output_csv(list)
        end
        keys
    end

    def self.get_pic_filesize_list()
        hash = get_pic_infos_ex

        hash2 = hash.map {|k,v|
            [
                k,
                v.sum / v.size
            ]
        }.to_h

        hash2
    end

    def self.reg_filesize()
        STDERR.puts "### reg_filesize >>>"
        pic_infos = init_pic_infos
        pic_infos.each do |k,v|
            twt = Twitter.find_by(twtid: k)
            if twt
                twt_params = {}
                avg = v.sum / v.size

                if twt.filesize 
                    if avg > twt.filesize
                        twt_params[:filesize] = avg
                    elsif avg == twt.filesize
                    else
                        msg = %!サイズが小さくなっているため保留:#{twt.filesize} -> #{avg}!
                        Rails.logger.warn(msg)
                    end
                else
                    twt_params[:filesize] = avg
                end

                if twt_params.size > 0
                    msg = %!更新内容 => #{twt_params}\t@#{k}(#{twt.twtname})!
                    #Rails.logger.info(msg)

                    twt.update(twt_params)
                end
            else
                msg = %!不明なID:"#{k}"!
                Rails.logger.warn(msg)
            end
        end

        STDERR.puts "### reg_filesize <<<"
    end

    def self.list_vid
        twts = Twitter.select {|x| (x.video_cnt||0) > 0}.sort_by {|x| x.video_cnt}.reverse
        twts.each do |twt|
            puts %!#{twt.twtid},"#{twt.twtname}",#{twt.video_cnt},#{twt.private_account}!
        end

        twts.map {|x| x.twtid}
    end

    # =========================================================================
    # 
    # =========================================================================
    class TwtDirs
        def initialize
            path_list = Util::glob(TWT_CURRENT_DIR_PATH)
            @twt_user_list = path_list.map {|x| File.basename(x).downcase}
        end
    
        def user_exist?(twtid)
            #STDERR.puts %![dbg y]#{twtid}!
            return @twt_user_list.include? twtid.downcase
        end
    end
end

