# coding: utf-8

#require "active_support/core_ext/numeric/conversions"

module Twt
    extend ActiveSupport::Concern

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
            #if line =~ %r!https?://twitter\.com/#{twtid}/status/(\d+)!
            if line =~ %r!https?://(?:x|twitter)\.com/#{twtid}/status/(\d+)!
                tweet_id = $1.to_i
                twt_ids << tweet_id
            else
                #puts line
            end
        end
        twt_ids.sort.uniq
    end

    def self.get_pic_filelist(twtid)
        path_list = []

        tpath = get_twt_path_from_dirlist(twtid)
        puts %!archive dir path=#{tpath}!

        path_list << UrlTxtReader::get_path_list(tpath)

=begin
        twt_root = Rails.root.join(TWT_CURRENT_DIR_PATH).to_s + "*/"
        Dir.glob(twt_root).each do |path|
            if twtid == File.basename(path)
                puts %!path=#{path}!
                path_list << UrlTxtReader::get_path_list(path)
                break
            end
        end
=end
        twt_root = Rails.root.join(TWT_CURRENT_DIR_PATH).to_s + "*/"
        dirpath = Util::get_dir_path_by_twtid(twt_root, twtid)
        path_list << UrlTxtReader::get_path_list(dirpath)

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
            while line  = file.gets
                if line =~ %r!#{TWT_ARCHIVE_DIR_PATH}/./#{twtid}!
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

        artist_list = {}
        path_list.flatten.each do |path|
            set_twt_user(artist_list, path)
        end
        #artist_list.sort_by{|s| [s[0].downcase, s[0]]}.to_h
        artist_list.sort_by{|_, v| v.ctime}.to_h
    end

    def self.set_twt_user(artist_hash, path)
        dirname = File.basename path
        if dirname =~ /(\w+)\s*(.*)/
            id = $1
            name = $2.strip

            if artist_hash.include? id
                artist_hash[id].append_path(path)
            else
                artist_hash[id] = TwtArtist.new(id, name, path)
                artist_hash[id].set_filenum
            end
        else
            puts %!invalid format:"#{path}" (#{__FILE__}:#{__LINE__})!
        end
    end

    def self.twt_user_infos()
        path_list = []
        path_list << Util::glob(TWT_CURRENT_DIR_PATH)

        artist_list = {}
        path_list.flatten.each do |path|
            dirname = File.basename path
            if dirname =~ /^(\w+)$/
                twtid = $1

                twt = Twitter.find_by_twtid_ignore_case(twtid)
                if twt.presence and (twt.rating != nil and twt.rating != 0)
                    #puts %!known @#{twtid}!
                    next
                end

                artist_list[twtid] = TwtArtist.new(twtid, "", path)
                artist_list[twtid].set_filenum
            else
                puts %!invalid format:"#{path}" (#{__FILE__}:#{__LINE__})!
            end
        end
        artist_list.sort_by{|_, v| -v.num_of_files}.to_h
    end

    def self.twt_user(twtid)
        puts twtid
        list = Twt::twt_user_list
        user = list[twtid.to_i]
        #puts user
        user
    end

    def self.twt_user_url(twtid)
        #%!https://twitter.com/#{twtid}!
        %!https://x.com/#{twtid}!
    end

    def self.twt_tweet_url(screen_name, tweet_id)
        %!http://x.com/#{screen_name}/status/#{tweet_id}!
    end

    def self.db_update_by_newdir()
        twt_id_list = twt_user_list("new")
        twt_id_list.each do |key, val|
            twt = Twitter.find_by_twtid_ignore_case(key)
            if twt == nil
                # 新規追加
                twt_params = {}
                twt_params[:twtid] = key
                twt_params[:last_dl_datetime] = val.ctime
                twt_params[:last_access_datetime] = val.ctime
                twt_params[:filenum] = val.num_of_files
                twt_params[:recent_filenum] = val.num_of_files
                twt_params[:update_frequency] = val.calc_freq()
                puts %!new. "#{key}"!
                twt = Twitter.new(twt_params)
                twt.save
            else
                puts %!update;#{key}:filenum=#{val.num_of_files}!
                if twt.filenum == val.num_of_files
                    #更新しない
                    next
                end
                twt_params = {}
                twt_params[:last_dl_datetime] = val.ctime
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

    def self.get_tweet_id_from_filepath(filepath)
        fn = File.basename filepath
        get_tweet_id(fn)
    end

    def self.sort_by_tweet_id(pic_path_list)
        pic_path_list.sort_by {|x| [Twt::twt_path_str(x)]}.reverse
    end

    def self.get_tweet_id(filename)
        tweet_id = 0
        pic_no = 0
        if filename =~ /(\d+)\s(\d+)\s(\d+\-\d+\-\d+)/
            #puts fn
            tweet_id = $1.to_i
            pic_no = $2.to_i
        elsif filename =~ /(\d+)\s(\d+)\s(\d+)/
            dl_date_str = $1
            begin
                #dl_date = Date.parse(dl_date_str)
            rescue Date::Error => ex

            end
            tweet_id = $2.to_i
            pic_no = $3.to_i
        elsif filename =~ /\d+-\d+-\d+\s+\((\d+)\)/
            tweet_id = $1.to_i
        elsif filename =~ /(\d\d\d+)-(\d+)/
            tweet_id = $1.to_i
            pic_no = $2.to_i
        elsif filename =~ /TID\-unknown\-/
        else
            STDERR.puts %!regex no hit:#{filename}!
        end
        [tweet_id, pic_no]
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

    def self.twt_path_str(path)
        fn = File.basename path

        tweet_id, pic_no = get_tweet_id(fn)

        if tweet_id != 0
            ul_datestr = timestamp_str(tweet_id)
            date_str = %!【#{ul_datestr}】!
        else
            fullpath = Rails.root.join("public/" + path)
            mtime = File::mtime(fullpath)
            date_str = %![#{mtime.strftime("%Y-%m-%d")}]!
        end
        #twt_id_str = tweet_id.to_s(:delimited)
        twt_id_str = tweet_id.to_s.reverse.gsub(/\d{3}/, '\0,').reverse
        %!<#{twt_id_str}>#{4 - pic_no}#{date_str}[#{fn})(#{File.dirname path}]!
    end

    def self.get_time_from_path(filepath)
        filename = File.basename(filepath)
        tweet_id, _  = get_tweet_id(filename)
        time = get_timestamp(tweet_id)
        if tweet_id == 0
            STDERR.puts %!#{tweet_id}=#{time}!
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

end

class TwtArtist
    attr_accessor :twt_id, :twt_name, :path_list, :ctime, :num_of_files

    def initialize(id, name, path)
        @twt_id = id
        @twt_name = name
        @path_list = []
        @path_list << path

        @ctime = File.birthtime path
        @num_of_files = nil
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
        pic_list.flatten.sort.reverse
    end

    def calc_freq
        pl = Twt::sort_by_tweet_id(twt_pic_path_list)
        Twt::calc_freq(pl, 30)
    end
    
    def set_filenum
        #if @num_of_files == nil
        #end
        @num_of_files = twt_pic_path_list.size
    end

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
                    puts %!uncatch "#{path}"!
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