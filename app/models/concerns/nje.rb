# coding: utf-8

module Nje
    extend ActiveSupport::Concern
    #include Util
    
    def self.nje_user_list
        path_list = []

        path_list << Util::glob("public/d_dl/Nijie/")
        path_list << Util::glob("public/nje/nje/")

        artist_list = {}
        path_list.flatten.each do |path|
            dirname = File.basename path
            if dirname =~ /(.*)\((\d+)\)/
                name = $1.strip
                id = $2.to_i

                if artist_list.include? id
                    artist_list[id].append_path(path)
                else
                    artist_list[id] = NjeArtist.new(id, name, path)
                end
            else
                puts %!invalid format:"#{path}" (#{__FILE__}:#{__LINE__})!
            end
        end
        #artist_list.sort.to_h
        artist_list.sort_by {|k, v| v.nje_name.downcase}.to_h
    end

    def self.update_db_by_fs()
    end

    def self.nje_user(njeid)
        puts njeid
        list = Nje.nje_user_list
        user = list[njeid.to_i]
        #puts user
        user
    end

    def self.nje_member_url(nje_id)
        %!https://nijie.info/members.php?id=#{nje_id}!
    end

    def self.nje_artwork_url(art_id)
        %!https://nijie.info/view.php?id=#{art_id}!
    end
end

class NjeArtist
    attr_accessor :nje_id, :nje_name, :path_list

    def initialize(id, name, path)
        @nje_id = id
        @nje_name = name
        @path_list = []
        @path_list << path
    end

    def append_path(path)
        @path_list << path
    end

    def nje_pic_path_list()
        pic_list = []
        path_list.each do |path|
            puts path
            pic_list << UrlTxtReader::get_path_list(path)
        end
        pic_list.flatten.sort.reverse
    end

    def nje_view_list(piclist)
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
                artlist[artid] = NjeArtwork.new(artid, title, date, path)
            end
        end
        artlist.sort.reverse.to_h
    end

    def nje_view_list_ex
        nje_view_list(nje_pic_path_list)
    end
end

class NjeArtwork
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