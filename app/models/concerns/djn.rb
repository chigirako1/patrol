# coding: utf-8

#------------------------------------------------------------------------------
# :
#------------------------------------------------------------------------------
module Djn
    extend ActiveSupport::Concern

    DJN_ARCHIVE_PATH = "public/djn_arcv/"
    #DJN_CRNT_PATH = "public/xxx"

    DJN_ARCHIVE_DIR_F_WC = "*/*/*"

    DJN_DIRLIST_TXT_PATH = "#{DJN_ARCHIVE_PATH}/dirlist.txt"

    def self.djn_artist_list
        path_list = []
        path_list << Util::glob(DJN_ARCHIVE_PATH, DJN_ARCHIVE_DIR_F_WC)

        artist_list = {}
        path_list.flatten.each do |path|
            dirname = File.basename path
            artist_list[dirname] = DjnArtist.new(dirname, path)
        end
        artist_list
    end

    def self.djn_artist(djnid)
        #puts %!=== #{djnid} ====!
        list = Djn.djn_artist_list
        artist = list[djnid]
        artist
    end

    def self.get_djn_path_from_dirlisttxt(djnid)
        path = ""
        txtpath = Rails.root.join(DJN_ARCHIVE_PATH).to_s
        File.open(txtpath) { |file|
            while line = file.gets
                if false#line.downcase =~ %r!#{DJN_ARCHIVE_PATH}/./#{twtid.downcase}!
                    path << line.chomp
                    break
                end
            end
        }
        path
    end
end

#------------------------------------------------------------------------------
# class:
#------------------------------------------------------------------------------
class DjnArtist
    attr_accessor :djn_name, :path, :num_art, :latest_p_date, :latest_access_date

    def initialize(name, path)
        @djn_name = name
        @path = path

        #puts path
    end

    def artworks
        path = @path + "/"
        puts path

        artwork_list = []
        artwork_paths = Util::glob(path)
        artwork_paths.each do |wpath|
            artwork_list << DjnArtwork.new(wpath)
        end

        artwork_paths = Util::glob(path, "*.zip")
        artwork_paths.each do |wpath|
            artwork_list << DjnArtwork.new(wpath)
        end
        
        artwork_list
    end
end

#------------------------------------------------------------------------------
# class:
#------------------------------------------------------------------------------
class DjnArtwork
    attr_accessor :path, :author_name, :artwork_title, :publish_date, :event_name, :archive_date, :orig_work_name, :chara

    def initialize(path)
        @path = path

        dirname = File.basename path
        if dirname =~ /\[(.+)\]\s+同人誌\#(.+?)-(.+?)-(.*)-(\d+)/
            #puts $1
            @author_name = $1
            publish_date = $2
            @orig_work_name = $3
            work = $4
            begin
                @archive_date = Date.parse $5
            rescue Date::Error => ex
                @archive_date = Date.parse "20010101"
            end

            if publish_date =~ /(\d{6})(.*)/
                yyyymm = $1
                begin
                    @publish_date = Date.parse yyyymm + "01"
                rescue Date::Error => ex
                    STDERR.puts %!??? #{dirname}!
                    @publish_date = Date.parse yyyymm[0..3] + "0101"
                end
                @event_name = $2
            else
                @publish_date = publish_date
            end

            if work =~ /(.*)「(.*)」/
                @chara = $1
                @artwork_title = $2
            elsif work =~ /「(.*)」/
                @chara = $1
            else
                @artwork_title = work
            end
        elsif dirname =~ /\[(.+)\]\s+同人誌\#(.*)/
            #puts $1
            @author_name = $1
            work = $4
        else
            STDERR.puts %!??? #{dirname}!
        end
    end

    def cover_path
        #"test"
        if File.extname(@path) == ".zip"
            return ""
        end
        pic_path_list = UrlTxtReader::get_path_list(path)
        pic_path_list[0]
    end
end

