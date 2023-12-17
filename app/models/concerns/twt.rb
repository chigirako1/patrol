# coding: utf-8

module Twt
    extend ActiveSupport::Concern

    TWT_DIRLIST_PATH = "public/twt/dirlist.txt"
    
    def self.get_pic_filelist(twtid)
        path_list = []

        tpath = get_twt_path_from_dirlist(twtid)
        puts %!tpath=#{tpath}!

        path_list << UrlTxtReader::get_path_list(tpath)

        twt_root = Rails.root.join("public/d_dl/Twitter/").to_s + "*/"
        Dir.glob(twt_root).each do |path|
            if twtid == File.basename(path)
                puts %!path=#{path}!
                path_list << UrlTxtReader::get_path_list(path)
                break
            end
        end

        path_list.flatten.sort.reverse
    end

    def self.get_twt_path_from_dirlist(twtid)
        path = ""
        txtpath = Rails.root.join(TWT_DIRLIST_PATH).to_s
        File.open(txtpath) { |file|
            while line  = file.gets
                if line =~ %r!public/twt/./#{twtid}!
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
            path_list << Util::glob("public/d_dl/Twitter/")
        elsif target_dir == "old"
            path_list << Util::glob("public/twt/", "*/*")
        else
            path_list << Util::glob("public/d_dl/Twitter/")
            path_list << Util::glob("public/twt/", "*/*")
        end

        artist_list = {}
        path_list.flatten.each do |path|
            dirname = File.basename path
            if dirname =~ /(\w+)\s*(.*)/
                id = $1
                name = $2.strip

                if artist_list.include? id
                    artist_list[id].append_path(path)
                else
                    artist_list[id] = TwtArtist.new(id, name, path)
                end
            else
                puts %!invalid format:"#{path}" (#{__FILE__}:#{__LINE__})!
            end
        end
        #artist_list.sort_by{|s| [s[0].downcase, s[0]]}.to_h
        artist_list.sort_by{|_, v| v.ctime}.to_h
    end


    def self.twt_user(twtid)
        puts twtid
        list = Twt::twt_user_list
        user = list[twtid.to_i]
        #puts user
        user
    end

    def self.twt_user_url(twtid)
        %!https://twitter.com/#{twtid}!
    end

    def self.twt_tweet_url(tweet_id)
        %!https://nijie.info/view.php?id=#{tweet_id}!
    end

    def self.db_update_by_newdir()
        twt_id_list = twt_user_list("new")
        twt_id_list.each do |key, val|
            twt = Twitter.find_by(twtid: key)
            if twt == nil
                # 新規追加
                puts %!new;#{key}:#{val}!
                twt_params = {}
                twt_params[:twtid] = key
                twt_params[:last_dl_datetime] = val.ctime
                twt_params[:last_access_datetime] = val.ctime
                twt = Twitter.new(twt_params)
                twt.save
            else
                # 既存更新
                #puts %!exist;#{key}:#{val}!
            end
        end
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
        elsif filename =~ /(\d+)-(\d+)/
            tweet_id = $1.to_i
            pic_no = $2.to_i
        else
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
        date_str + %!#{4 - pic_no} (#{fn})(#{File.dirname path})!
    end

    def self.get_time_from_path(filepath)
        filename = File.basename(filepath)
        tweet_id, _  = get_tweet_id(filename)
        time = get_timestamp(tweet_id)
        time
    end

    CALC_FREQ_DAY_NUM = 30
    CALC_FREQ_UNIT = 100

    def self.calc_freq(pic_path_list, calc_freq_day_num=CALC_FREQ_DAY_NUM)
        if pic_path_list == nil or pic_path_list.size == 0
            return 0
        end
        latest_time = get_time_from_path(pic_path_list[0])

        days = 1
        cnt = 0
        pic_path_list.each do |path|
            post_time = get_time_from_path(path)
            #puts latest_time.to_date
            #puts time.to_date
            tmp_days =  (latest_time.to_date - post_time.to_date).to_i + 1
            if tmp_days >= calc_freq_day_num
                break
            end
            days = tmp_days
            cnt += 1
            #puts %!#{cnt}:#{days}<#{post_time.strftime("%Y-%m-%d %H:%M")}>:[#{path}]!
        end
        point = (cnt * CALC_FREQ_UNIT / days)
        puts %!point=#{point}, cnt=#{cnt}, days=#{days}!
        point
    end
end

class TwtArtist
    attr_accessor :twt_id, :twt_name, :path_list, :ctime

    def initialize(id, name, path)
        @twt_id = id
        @twt_name = name
        @path_list = []
        @path_list << path

        @ctime = File.birthtime path
    end

    def append_path(path)
        @path_list << path
    end

    def twt_pic_path_list()
        pic_list = []
        path_list.each do |path|
            puts path
            pic_list << UrlTxtReader::get_path_list(path)
        end
        pic_list.flatten.sort.reverse
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