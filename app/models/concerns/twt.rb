# coding: utf-8

module Twt
    extend ActiveSupport::Concern
    
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
            #9715239224554008999 0 2023-11-12
            #puts fn
            tweet_id = $1.to_i
            pic_no = $2.to_i
        elsif filename =~ /(\d+)\s(\d+)\s(\d+)/
            #2023-11-12 9715239224554008999 0 
            dl_date_str = $1
            begin
                #dl_date = Date.parse(dl_date_str)
            rescue Date::Error => ex

            end
            tweet_id = $2.to_i
            pic_no = $3.to_i
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

    def self.get_timestamp_from_path(filepath)
        filename = File.basename(filepath)
        tweet_id, _  = get_tweet_id(filename)
        time = get_timestamp(tweet_id)
        time
    end

    def self.calc_freq(pic_path_list)
        latest_time = get_timestamp_from_path pic_path_list[0]

        days = 1
        cnt = 0
        pic_path_list.each do |path|
            time = get_timestamp_from_path path
            #puts latest_time.to_date
            #puts time.to_date
            tmp_days =  (latest_time.to_date - time.to_date).to_i + 1
            if tmp_days >= 14
                break
            end
            days = tmp_days
            cnt += 1
            puts %!#{cnt}:#{days}[#{path}]!
        end
        point = (cnt * 100 / days)
        puts %!#point=#{point}, cnt=#{cnt}, days=#{days}!
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