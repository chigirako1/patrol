# coding: utf-8

#require "active_support/core_ext/numeric/conversions"

# =============================================================================
# 
# =============================================================================
module Twt
    extend ActiveSupport::Concern

    TWT_DOMAIN_NAME_ORIG = %!twitter.com!
    TWT_DOMAIN_NAME_ELON = %!x.com!
    TWT_DOMAIN_NAME = TWT_DOMAIN_NAME_ELON

    TMP_DIR_PATH = "public/d_dl/"
    
    #TWT_CURRENT_DIR_PATH = "public/d_dl/Twitter/"
    #TWT_TMP_DIR_PATH     = "public/d_dl/Twitter-/"
    #TWT_TMP_DIR_PATH_A   = "public/d_dl/Twitter-/a/"
    TWT_CURRENT_DIR_PATH = TMP_DIR_PATH + "Twitter/"
    TWT_TMP_DIR_PATH     = TMP_DIR_PATH + "Twitter-/"
    TWT_TMP_DIR_PATH_A   = TMP_DIR_PATH + "Twitter-/a/"

    TWT_ARCHIVE_DIR_PATH = "public/twt"
    TWT_DIRLIST_TXT_PATH = "#{TWT_ARCHIVE_DIR_PATH}/dirlist.txt"

    def self.get_twt_tweet_ids_from_txts(twtid)
        #txt_sum = UrlTxtReader::get_url_txt_contents("")
        txt_sum = UrlTxtReader::get_url_txt_contents([])
        twt_ids = get_tweet_ids(txt_sum.split(/\R/).sort_by{|s| [s.downcase, s]}.uniq, twtid)
        twt_ids
    end
    
    def self.get_tweet_ids(txts, twtid)
        twt_ids = []
        txts.each do |line|
            line.chomp!
            if line =~ %r!https?://(?:x|twitter)\.com/#{twtid}/status/(\d+)!
                tweet_id = $1.to_i
                twt_ids << tweet_id
            else
                #puts line
            end
        end
        twt_ids.sort.uniq
    end

    def self.get_twt_user_path_list(path, wc, twtid)
        twt_root = Rails.root.join(path).to_s + wc
        dirpath = Util::get_dir_path_by_twtid(twt_root, twtid)
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

            dirpath = Util::get_dir_path_by_twtid(twt_root, twtid)
            path_list << UrlTxtReader::get_path_list(dirpath)
        elsif Dir.exist?(TWT_TMP_DIR_PATH)
            twt_root = Rails.root.join(TWT_TMP_DIR_PATH).to_s + "*/"
            STDERR.puts %![get_pic_filelist] "#{TWT_TMP_DIR_PATH}"\ttwt_root="#{twt_root}"!

            dirpath = Util::get_dir_path_by_twtid(twt_root, twtid)
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
            STDERR.puts %!rgx="#{rgx}"!
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

    def self.twt_user_infos()
        path_list = []
        path_list << Util::glob(TWT_CURRENT_DIR_PATH)

        artist_hash = {}
        path_list.flatten.each do |path|
            dirname = File.basename path
            if dirname =~ /^(\w+)$/
                twtid = $1

                twt = Twitter.find_by_twtid_ignore_case(twtid)
                if twt.presence and (twt.rating != nil and twt.rating != 0)
                    #puts %!known @#{twtid}!
                    next
                end

                artist_hash[twtid] = TwtArtist.new(twtid, "", path)
                artist_hash[twtid].set_filenum
            else
                puts %!invalid format:"#{path}" (#{__FILE__}:#{__LINE__})!
            end
        end
        artist_hash.sort_by{|_, v| -v.num_of_files}.to_h
    end

    def self.user_exist?(twtid)
        path_list = Util::glob(TWT_CURRENT_DIR_PATH)
        list = path_list.map {|x| File.basename(x).downcase}
        return list.include? twtid.downcase
    end

    def self.twt_user_url(twtid)
        %!https://x.com/#{twtid}!
    end

    def self.twt_tweet_url(screen_name, tweet_id)
        %!https://x.com/#{screen_name}/status/#{tweet_id}!
    end

    def self.twt_tweet_url_dev(tweet_id)
        twt_tweet_url("TwitterDev", tweet_id)
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
            msg = "@#{key}:更新内容 =>\t#{twt_params}"
            #STDERR.puts msg
            Rails.logger.info(msg)

            #twt.update(twt_params)
        end

        twt.update(twt_params)
    end

    def self.db_update_by_newdir()
        twt_id_list = twt_user_list("new")

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

        if tweet_id != 0
            ul_datestr = timestamp_str(tweet_id)
            date_str = %!【#{ul_datestr}】!
        else
            fullpath = Rails.root.join("public/" + path)
            mtime = File::mtime(fullpath)
            date_str = %![#{mtime.strftime("%Y-%m-%d")}]!
        end
        #twt_id_str = tweet_id.to_s(:delimited)
        #twt_id_str = tweet_id.to_s.reverse.gsub(/\d{3}/, '\0,').reverse
        twt_id_str = tweet_id_with_comma(tweet_id)
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
        if str =~ /(\w+)/
            result = $1
            if result != str
                puts %![LOG] "#{$1}" <= "#{str}"!
                return result
            end
        end
        return str
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

