# coding: utf-8

#require "active_support/core_ext/numeric/conversions"

module Twt
    extend ActiveSupport::Concern

    TWT_DOMAIN_NAME_ORIG = %!twitter.com!
    TWT_DOMAIN_NAME_ELON = %!x.com!
    TWT_DOMAIN_NAME = TWT_DOMAIN_NAME_ELON

    TWT_CURRENT_DIR_PATH = "public/d_dl/Twitter/"
    TWT_TMP_DIR_PATH     = "public/d_dl/Twitter-/"
    TWT_TMP_DIR_PATH_A   = "public/d_dl/Twitter-/a/"
    TWT_ARCHIVE_DIR_PATH = "public/twt"
    TWT_DIRLIST_TXT_PATH = "#{TWT_ARCHIVE_DIR_PATH}/dirlist.txt"

    def self.get_twt_tweet_ids_from_txts(twtid)
        txt_sum = UrlTxtReader::get_url_txt_contents("")
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
        UrlTxtReader::get_path_list(dirpath)
    end

    def self.get_pic_filelist(twtid)
        path_list = []

        tpath = get_twt_path_from_dirlist(twtid)
        puts %!archive dir path=#{tpath}!

        path_list << UrlTxtReader::get_path_list(tpath)

=begin
        twt_root = Rails.root.join(TWT_CURRENT_DIR_PATH).to_s + "*/"
        dirpath = Util::get_dir_path_by_twtid(twt_root, twtid)
        path_list << UrlTxtReader::get_path_list(dirpath)
=end
        path_list << get_twt_user_path_list(TWT_CURRENT_DIR_PATH, "*/", twtid)

        if Dir.exist?(TWT_TMP_DIR_PATH_A)
            twt_root = Rails.root.join(TWT_TMP_DIR_PATH).to_s + "*/*/"
            dirpath = Util::get_dir_path_by_twtid(twt_root, twtid)
            path_list << UrlTxtReader::get_path_list(dirpath)
        elsif Dir.exist?(TWT_TMP_DIR_PATH)
            twt_root = Rails.root.join(TWT_TMP_DIR_PATH).to_s + "*/"
            dirpath = Util::get_dir_path_by_twtid(twt_root, twtid)
            path_list << UrlTxtReader::get_path_list(dirpath)
        end

        path_list.flatten.sort.reverse
    end

    def self.get_twt_path_from_dirlist(twtid)
        path = ""
        txtpath = Rails.root.join(TWT_DIRLIST_TXT_PATH).to_s
        File.open(txtpath) { |file|
            while line = file.gets
                #if line =~ %r!#{TWT_ARCHIVE_DIR_PATH}/./#{twtid}!
                if line.downcase =~ %r!#{TWT_ARCHIVE_DIR_PATH}/./#{twtid.downcase}!
                    path << line.chomp
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

        artist_hash = {}
        path_list.flatten.each do |path|
            set_twt_user(artist_hash, path)
        end
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
                artist_hash[id].append_path(path)
            else
                #artist_hash[id] = TwtArtist.new(id, name, path)
                artist_hash[id] = TwtArtist.new(twtid, name, path)
                artist_hash[id].set_filenum
            end
        else
            puts %!invalid format:"#{path}" (#{__FILE__}:#{__LINE__})!
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
        %!http://x.com/#{screen_name}/status/#{tweet_id}!
    end

    def self.twt_tweet_url_dev(tweet_id)
        twt_tweet_url("TwitterDev", tweet_id)
    end

    def self.db_update_by_newdir()
        twt_id_list = twt_user_list("new")
        twt_id_list.each do |key, val|
            twt = Twitter.find_by_twtid_ignore_case(key)
            if twt == nil
                # 新規追加
                pic_path_list = val.twt_pic_path_list
                if pic_path_list.size == 0
                    STDERR.puts %!ファイルなし: @#{key}!
                    next
                end

                twt_params = {}
                twt_params[:twtid] = val.twt_id
                twt_params[:last_dl_datetime] = val.ctime
                twt_params[:last_access_datetime] = val.ctime
                twt_params[:last_post_datetime] = val.last_post_datetime(pic_path_list)
                twt_params[:filenum] = val.num_of_files
                twt_params[:recent_filenum] = val.num_of_files
                twt_params[:update_frequency] = val.calc_freq(pic_path_list)
                pxv = Artist.find_by_twtid_ignore_case(val.twt_id)
                if pxv
                    twt_params[:pxvid] = pxv.pxvid
                end
                puts %!new. "#{key}"!
                twt = Twitter.new(twt_params)
                twt.save
            else
                pic_path_list = val.twt_pic_path_list
                twt_params = {}
                last_post_datetime = Time.at(val.last_post_datetime(pic_path_list).to_i)
                if twt.last_post_datetime.presence
                    #p twt.last_post_datetime
                    #p last_post_datetime
                    #puts %!i=#{twt.last_post_datetime.to_i}, class=#{twt.last_post_datetime.class}!
                    #puts %!i=#{last_post_datetime.to_i}, class=#{last_post_datetime.class}!
                    if last_post_datetime.after? (twt.last_post_datetime)
                        puts %!update:"#{pic_path_list[0]}"\told="#{twt.last_post_datetime}",new="#{last_post_datetime}"!
                        twt_params[:last_post_datetime] = last_post_datetime
                    else
                        #更新しない
                        #puts %![no update] "#{key}":"#{twt.last_post_datetime}":"#{last_post_datetime}"!
                        next
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

                if twt.filenum == nil
                    twt_params[:filenum] = val.num_of_files
                else
                    #あほかtwt_params[:filenum] = 
                end

                if twt.recent_filenum == nil
                    twt_params[:recent_filenum] = val.num_of_files
                end
                twt.update(twt_params)
            end
        end
    end

    def self.db_update_dup_files()
        hash_hash = Hash.new { |h, k| h[k] = [] }
        i = 0
        dir_path = TWT_CURRENT_DIR_PATH
        pic_list = UrlTxtReader::get_path_list(dir_path)
        pic_list.each do |path|
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

        hash_hash.each do |k, v|
            if v.size < 2
                next
            end
            hash_val = k[0]
            filesize = k[1]

            puts
            puts "#" * 100
            puts "key=#{hash_val}/filesize=#{filesize}"
            puts "#" * 100

            dup_tweet_list = []
            tweet_id_hash = {}
           
            v.each do |path|
                tweet_id, pic_no = get_tweet_info_from_filepath(path)
                if tweet_id_hash.has_key? tweet_id
                    # 同一のTweet idの場合は単純に同じツイートを多重で保存しただけとして記録しない
                    puts %!DLミス(重複):"#{path}"!
                    next
                end
                tweet_id_hash[tweet_id] = true
                dirname = File.basename(File.dirname path)
                puts %!@#{dirname}:#{tweet_id}:#{pic_no} "#{path}"!
                dup_tweet_list << [dirname, tweet_id, pic_no]
            end
            puts ""

            scrn_names = dup_tweet_list.map {|x| x[0]}
            if scrn_names.uniq.size != 1
                puts %!異なるスクリーンネームに保存されているファイルがあります:#{scrn_names.uniq}!
            end

            dup_tweet_list = dup_tweet_list.sort_by {|x| x[1]}[1..-1]
            dup_tweet_list.each do |x|
                #twt_screen_name = x[0]
                #tweet_id = x[1]
                #pic_no = x[2]
                twt_screen_name, tweet_id, pic_no = x
                tweet = Tweet.find_by(tweet_id: tweet_id)
                if tweet == nil
                    Tweet::create_record(twt_screen_name, tweet_id, Tweet::StatusEnum::DUPLICATE, pic_no)
                    #puts %!同一のファイルです:#{tweet_id}-#{pic_no}(@#{twt_screen_name})!
                else
                    puts "すでに登録済みです:#{tweet_id}"
                end
            end
        end
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

    class TwtDirs
        def initialize
            path_list = Util::glob(TWT_CURRENT_DIR_PATH)
            @twt_user_list = path_list.map {|x| File.basename(x).downcase}
        end
    
        def user_exist?(twtid)
            puts %!#{twtid}!
            return @twt_user_list.include? twtid.downcase
        end
    end
end

class TwtArtist
    #attr_accessor :twt_id, :twt_name, :path_list, :ctime, :num_of_files
    attr_accessor :twt_id, :twt_name, :path_list, :num_of_files

    def initialize(id, name, path)
        @twt_id = id
        @twt_name = name
        @path_list = []
        @path_list << path

        #@ctime = File.birthtime path
        @ctime = nil
        @num_of_files = nil
    end

    def ctime
        if @ctime == nil
            wpath = twt_pic_path_list[0]
            if wpath
                path = Util::get_public_path(wpath)
                @ctime = File.birthtime(path)
            else
                STDERR.puts %!#{twt_name} @#{twt_id}!
                @ctime = Time.now
            end
        end
        @ctime
    end

    def append_path(path)
        @path_list << path
    end

    def twt_pic_path_list()
        pic_list = []
        path_list.each do |path|
            #puts path
            pic_list << UrlTxtReader::get_path_list(path)
        end
        #pic_list.flatten.sort.reverse
        Twt::sort_by_tweet_id(pic_list.flatten)
    end

    def calc_freq(pic_path_list = nil)
        if pic_path_list
            pl = pic_path_list
        else
            #pl = Twt::sort_by_tweet_id(twt_pic_path_list)
            pl = twt_pic_path_list
        end
        Twt::calc_freq(pl, 30)
    end
    
    def set_filenum
        #if @num_of_files == nil
        #end
        @num_of_files = twt_pic_path_list.size
    end

=begin ???バグでは？
    def twt_view_list(piclist)
        artlist = {}
        piclist.each do |path|
            dirname = File.basename File.dirname(path)
            if dirname =~ /(\d{4}-\d\d-\d\d) \((\d+)\) (.*)/
                date = $1
                artid = $2.to_i
                title = $3
            else
                filename = File.basename path
                if filename =~ /(\d{4}-\d\d-\d\d) \((\d+)\) (.*)/
                    date = $1
                    artid = $2.to_i
                    title = $3
                else
                    puts %!unmatch "#{path}"!
                    next
                end
            end
            
            if artlist.include? artid
                artlist[artid].append(path)
            else
                artlist[artid] = TwtArtwork.new(artid, title, date, path)
            end
        end
        artlist.sort.reverse.to_h
    end

    def twt_view_list_ex
        twt_view_list(twt_pic_path_list)
    end
=end

    def last_post_datetime(pic_path_list)
        Twt::get_time_from_path(pic_path_list[0])
    end
end

class TwtArtwork
    attr_accessor :art_id, :date, :title, :path_list

    def initialize(id, title, date, path)
        @art_id = id
        @title = title
        @date = date
        @path_list = []
        @path_list << path
    end

    def append(path)
        #@path_list.unshift path
        @path_list << path
    end
end
