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
        artist_list.sort_by{|s| [s[0].downcase, s[0]]}.to_h
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
end

class TwtArtist
    attr_accessor :twt_id, :twt_name, :path_list

    def initialize(id, name, path)
        @twt_id = id
        @twt_name = name
        @path_list = []
        @path_list << path
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
        @path_list.unshift path
    end
end