# coding: utf-8

module Pxv
    extend ActiveSupport::Concern
    
    PXV_DIRLIST_PATH = "public/pxv/dirlist.txt"
    PXV_ARCHIVE_DIR_PATH = "public/f_dl/PxDl/"
    ARCHIVE_PATH = "F:/dPxv"

    def self.pxv_user_url(pxvid)
        %!https://www.pixiv.net/users/#{pxvid}!
    end

    def self.pxv_artwork_url(artwork_id)
        %!https://www.pixiv.net/artworks/#{artwork_id}!
    end

    def self.get_path_from_dirlist(pxvid)
        rpath = []
        txtpath = Rails.root.join(PXV_DIRLIST_PATH).to_s
        unless File.exist? txtpath
            return rpath
        end

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

    def self.get_pathlist(pxvid)
        path_list = []

        current_work_dir_root = Rails.root.join(PXV_ARCHIVE_DIR_PATH).to_s + "*/"
        Dir.glob(current_work_dir_root).each do |path|
            if File.basename(path) =~ /\(#{pxvid}\)/
                puts %!path=#{path}!
                path_list << UrlTxtReader::get_path_list(path)
                break
            end
        end

        rpath_list = get_path_from_dirlist(pxvid)
        rpath_list.each do |rpath|
            puts %!path="#{rpath}"!
            path_list << UrlTxtReader::get_path_list(rpath)
        end

        #path_list.flatten.sort.reverse

        path_list = path_list.flatten.map {|x| [get_pxv_art_id(x), File::basename(x), x]}.sort.reverse.map {|x| x[2]}
    end

    def self.get_pxv_art_id(x)
        id = 0
        if x =~ /\d\d-\d\d-\d\d.*\((\d+)\)/
            id = $1
        end
        id.to_i
    end

end