# coding: utf-8

module Pxv
    extend ActiveSupport::Concern
    
    PXV_DIRLIST_PATH = "public/pxv/dirlist.txt"
    PXV_ARCHIVE_DIR_PATH = "public/pxv/"
    PXV_ARCHIVE_DIR_WC = "*/*/*"
    PXV_WORK_DIR_PATH = "public/f_dl/PxDl/"
    PXV_WORK_TMP_DIR_PATH = "public/f_dl/PxDl-/"
    PXV_WORK_TMP_DIR_F_PATH = "public/f_dl/PxDl-/alphabet"
    PXV_WORK_TMP_DIR_F_WC = "*/*/*"
    PXV_WORK_TMP_DIR_WC = "*"
    ARCHIVE_PATH = "D:/r18/dlPic"

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

    def self.stock_dir_list()
        current_work_dir_root = Rails.root.join(PXV_WORK_DIR_PATH).to_s + "*/"
        dir_list = Dir.glob(current_work_dir_root)

        if Dir.exist?(PXV_WORK_TMP_DIR_F_PATH)
            dir_list_tmp = Util::glob(PXV_WORK_TMP_DIR_PATH, PXV_WORK_TMP_DIR_F_WC)
        elsif Dir.exist?(PXV_WORK_TMP_DIR_PATH)
            dir_list_tmp = Util::glob(PXV_WORK_TMP_DIR_PATH, PXV_WORK_TMP_DIR_WC)
            #puts %![]dir_list_tmp=#{dir_list_tmp}!
        else
            dir_list_tmp = []
        end

        [dir_list, dir_list_tmp].flatten
    end

    def self.current_dir_pxvid_list
        idlist = []

        stock_dir_list.each do |path|
            if File.basename(path) =~ /\((\d+)\)-?$/
                id = $1
                idlist << id.to_i
                #puts %!#{path},#{id}!
            end
        end
        idlist
    end

    def self.pxvid_exist?(path, pxvid)
        File.basename(path) =~ /\(#{pxvid}\)/
    end

    def self.get_pxv_user_id(path)
        if File.basename(path) =~ /\(#?(\d+)\)-?$/
            return $1.to_i
        else
            return ""
        end
    end

    def self.get_user_name_from_path(path)
        if File.basename(path) =~ /(.*?)\(\d+\)$/
            username = $1
        else
            STDERR.puts %!can't find user name:"#{path}"!
            username = ""
        end
        username
    end
    
    def self.user_name(pathlist, pxvid)
        pathlist.each do |path|
            if File.basename(path) =~ /(.*?)\(#{pxvid}\)$/
                #puts %!#{path}:#{pxvid}!
                return $1
            end
        end

        #puts %!user name not found. pxvid=#{pxvid}!
        return ""
    end

    def self.get_pathlist(pxvid, archive_dir=true)
        path_list = []

        dir_list = stock_dir_list()
        dir_list.each do |path|
            if pxvid_exist?(path, pxvid)
                puts %![get_pathlist]path=#{path}!
                path_list << UrlTxtReader::get_path_list(path)
                #break
            end
        end

        if archive_dir
            rpath_list = get_path_from_dirlist(pxvid)
            rpath_list.each do |rpath|
                puts %![get_pathlist]rpath="#{rpath}"!
                path_list << UrlTxtReader::get_path_list(rpath)
            end
        end

        #path_list.flatten.sort.reverse

        #path_list = path_list.flatten.map {|x| [get_pxv_art_id(x), File::basename(x), x]}.sort.reverse.map {|x| x[2]}
        sort_pathlist(path_list.flatten)
    end

    def self.sort_pathlist(path_list)
        path_list.map {|x| [get_pxv_art_id(x), File::basename(x), x]}.sort.reverse.map {|x| x[2]}
    end

    def self.get_pxv_art_id(path)
=begin
        id = 0
        #if x =~ /\d\d-\d\d-\d\d.*\((\d+)\)/
        if x =~ /\d\d-\d\d-\d\d.*?\((\d+)\)/
            id = $1
        end
        id.to_i
=end
        artwork_id, date_str, artwork_title = get_pxv_artwork_info_from_path(path)
        artwork_id
    end

    def self.get_date_title_id_str_from_path(path)
        filename = File.basename(path)
        if filename =~ /\d\d-\d\d-\d\d/
            #ファイル名を返す
            return filename
        else
            #フォルダ名を返す
            return File.basename(File.dirname(path))
        end
    end

    def self.get_pxv_artwork_info_from_path(path)
        if path == nil
            STDERR.puts %!get_pxv_artwork_info_from_path:path is nil"!
            return [nil, nil, nil]
        end
        artwork_id = 0
        artwork_str = get_date_title_id_str_from_path(path)
        
        #STDERR.puts %!"#{artwork_str}"!

=begin
        #if artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*?)\((\d+)\)/
        if artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d\d+)\)\s*\(\d+\)/
            date_str = $1
            artwork_title = $2
            artwork_id = $3.to_i
            STDERR.puts %![get_pxv_artwork_info_from_path]#{date_str}/#{artwork_title}/#{artwork_id}"!
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d\d+)\)/
=end
        if artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d\d+)\)/
            date_str = $1
            artwork_title = $2
            artwork_id = $3.to_i
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d+)\)\(\d+\)/
            date_str = $1
            artwork_title = $2
            artwork_id = $3.to_i
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*\((\d+)\)\s*(.*)/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = $3
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+.*(\d+)_p\d+_master/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        # 22-08-05 100x3x4x5_p0.png
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+.*(\d{8,9})_p\d/
            #https://www.pixiv.net/artworks/8235311x
            #                               8083357x
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+\d{4}(\d+)/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        #22-06-20 9x17x5x2_p0_master1200.jpg"
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s+(\d+)/
            date_str = $1
            artwork_id = $2.to_i
            artwork_title = "(*不明*)"
        elsif artwork_str =~ /(\d\d-\d\d-\d\d)\s*(.*)/
            #STDERR.puts %!artwork id not found:"#{path}"!
            date_str = $1
            artwork_title = $2
        else
            STDERR.puts %!regex no hit:"#{artwork_str}"\t"#{path}"!
            date_str = ""
        end

        if artwork_id < 10 and artwork_id != 0
            STDERR.puts %!ID取得に失敗した可能性があります。artwork_id=#{artwork_id}?|"#{path}"|"#{artwork_str}"!
            artwork_id = 0
        end
        [artwork_id, date_str, artwork_title]
    end

    def self.archive_dir_id_list
        id_list = []
        dir_list = Util::glob(PXV_ARCHIVE_DIR_PATH, PXV_ARCHIVE_DIR_WC)
        dir_list.each do |path|
            pxv_user_id = get_pxv_user_id(path)
            if pxv_user_id != ""
                id_list << pxv_user_id
            else
                #STDERR.puts %!no hit path=#{path}!
            end
        end
        id_list.sort.uniq
    end

    def self.db_update_by_newdir
        new_list = []
        dir_list = stock_dir_list()
        dir_list.each do |path|
            pxv_user_id = get_pxv_user_id(path)
            if pxv_user_id != ""
                p = Artist.find_by(pxvid: pxv_user_id)
                if p
                    STDERR.puts %!user:#{p.pxvname}(#{p.pxvid})!
                    update_table(p, path)
                    #break
                else
                    new_list << [pxv_user_id, path]
                end
            end
        end

        new_list.each do |x|
            STDERR.puts %!new user:#{x[0]}|#{x[1]}!
            register_to_table(x[0], x[1])
            #break
        end
    end
    def self.register_to_table(pxv_user_id, path)
        pxv_params = {}

        pxv_artist = PxvArtist.new(pxv_user_id, path)
        pxv_params[:pxvname] = pxv_artist.pxv_name
        pxv_params[:pxvid] = pxv_artist.pxv_user_id
        pxv_params[:filenum] = pxv_artist.path_list.size
        pxv_params[:last_dl_datetime] = pxv_artist.last_dl_datetime #???
        pxv_params[:last_ul_datetime] = pxv_artist.last_ul_datetime
        pxv_params[:last_access_datetime] = pxv_artist.last_access_datetime
        pxv_params[:priority] = 0
        pxv_params[:furigana] = ""
        pxv_params[:circle_name] = ""
        pxv_params[:comment] = ""
        pxv_params[:recent_filenum] = pxv_artist.path_list.size
        pxv_params[:status] = ""
        twt = Twitter.find_by(pxvid: pxv_user_id)
        if twt
            pxv_params[:twtid] = twt.twtid
        else
            pxv_params[:twtid] = ""
        end
        pxv_params[:njeid] = ""
        pxv_params[:warnings] = ""
        pxv_params[:remarks] = ""
        pxv_params[:rating] = 0
        pxv_params[:r18] = ""
        pxv_params[:feature] = ""
        pxv_params[:chara] = ""
        pxv_params[:work] = ""
        pxv_params[:altname] = ""
        pxv_params[:oldname] = ""
        pxv_params[:earliest_ul_date] = pxv_artist.earliest_ul_date
        pxv_params[:pxv_path] = ""
        pxv_params[:tech_point] = 0
        pxv_params[:sense_point] = 0
        pxv_params[:good_point] = ""
        pxv_params[:bad_point] = ""
        pxv_params[:pxv_fav_artwork_id] = 0
        pxv_params[:fetish] = ""
        pxv_params[:obtain_direction] = ""
        pxv_params[:next_obtain_artwork_id] = ""
        pxv_params[:twt_check] = ""
        pxv_params[:web_url] = ""
        pxv_params[:djn_check_date] = ""
        pxv_params[:zip] = ""
        pxv_params[:append_info] = ""
        pxv_params[:twt_checked_date] = ""
        pxv_params[:nje_checked_date] = ""
        pxv_params[:show_count] = 0#""
        pxv_params[:reverse_status] = ""
        pxv_params[:latest_artwork_id] = pxv_artist.latest_artwork_id
        pxv_params[:oldest_artwork_id] = pxv_artist.oldest_artwork_id
        pxv_params[:zipped_at] = nil
    
        STDERR.puts %!#{pxv_params}!
        #pxv_artist.path_list.each do |path|
        #    btime = File.birthtime(Util::get_public_path(path))
        #    STDERR.puts %!#{btime}"#{path}":!
        #end
#=begin
        pxv = Artist.new(pxv_params)
        pxv.save
#=end
    end

    def self.update_table(pxv, path)
        pxv_params = {}

        pxv_artist = PxvArtist.new(pxv.pxvid, path)
        if pxv_artist.path_list.size == 0
            return
        end

        #STDERR.print %!最古UL日:\t#{pxv.earliest_ul_date.strftime("%Y-%m-%d")} => #{pxv_artist.earliest_ul_date.strftime("%Y-%m-%d")}!
        if pxv_artist.earliest_ul_date < pxv.earliest_ul_date
            pxv_params[:earliest_ul_date] = pxv_artist.earliest_ul_date
            #print " 更新"
        end
        puts

        #STDERR.print %!最終UL日:\t#{pxv.last_ul_datetime.strftime("%Y-%m-%d")} => #{pxv_artist.last_ul_datetime.strftime("%Y-%m-%d")}!
        if pxv_artist.last_ul_datetime > pxv.last_ul_datetime
            pxv_params[:last_ul_datetime] = pxv_artist.last_ul_datetime
            #print " 更新"
        end
        puts

        #STDERR.print %!最新DL日:\t#{pxv.last_dl_datetime.strftime("%Y-%m-%d")} => #{pxv_artist.last_dl_datetime.strftime("%Y-%m-%d")}!
        if pxv_artist.last_dl_datetime > pxv.last_dl_datetime
            pxv_params[:last_dl_datetime] = pxv_artist.last_dl_datetime
            #print " 更新"
        end
        puts

        #if pxv_artist.last_access_datetime < pxv.last_access_datetime
        #    pxv_params[:last_access_datetime] = pxv_artist.last_access_datetime
        #    print "更新"
        #end
        #STDERR.puts %!last_access_datetime:\t#{pxv.last_access_datetime.strftime("%Y-%m-%d")} => #{pxv_artist.last_access_datetime.strftime("%Y-%m-%d")}!

        unless pxv.twtid.presence
            twt = Twitter.find_by(pxvid: pxv.pxvid)
            if twt
                pxv_params[:twtid] = twt.twtid
                STDERR.puts %!@#{twt.twtid}!
            end
        end

        STDERR.puts %!#{pxv_params}!
        #pxv_artist.path_list.each do |path|
        #    btime = File.birthtime(Util::get_public_path(path))
        #    STDERR.puts %!#{btime}"#{path}":!
        #end
#=begin
        pxv.update(pxv_params)
#=end
    end
end

class PxvArtist
    attr_accessor :pxv_user_id, :pxv_name, :path_list,
                :last_dl_datetime, :last_ul_datetime, 
                :earliest_ul_date, :last_access_datetime,
                :oldest_artwork_id, :latest_artwork_id

    def initialize(id, path)
        @pxv_user_id = id
        @pxv_name = Pxv::get_user_name_from_path(path)
        @path_list = []
        filepath_list = UrlTxtReader::get_path_list(path)
        @path_list = Pxv::sort_pathlist(filepath_list)

        if @path_list.size == 0
            STDERR.puts %!ファイルが存在しません!
            return
        end

        fpath = Util::get_public_path(@path_list[-1]) #正確ではないが大体で良い
        @last_dl_datetime = File.birthtime(fpath.gsub("%23", "#"))
        @last_access_datetime = @last_dl_datetime


        @latest_artwork_id, date_str, _ = Pxv::get_pxv_artwork_info_from_path(@path_list[0])
        @last_ul_datetime = Time.parse(date_str)
        @oldest_artwork_id, date_str, _ = Pxv::get_pxv_artwork_info_from_path(@path_list[-1])
        @earliest_ul_date = Time.parse(date_str)

        if @last_ul_datetime < @earliest_ul_date
            STDERR.puts %!????#{@last_ul_datetime}|#{@earliest_ul_date}!
        end

        if @latest_artwork_id < @oldest_artwork_id
            STDERR.puts %!????#{@latest_artwork_id}|#{@oldest_artwork_id}!
        end
    end

    def to_s
        %!#{pxv_name}(#{pxv_user_id})\nDL日:#{last_dl_datetime}\n最新UL日:#{last_ul_datetime}\n最古UL日:#{earliest_ul_date}\nアクセス日時:#{last_access_datetime}!
    end
end

=begin
class PxvArtwork
    attr_accessor :art_id, :publish_date, :title, :path_list

    def initialize(id, title, date, path)
        @art_id = id
        @title = title
        @publish_date = date
        @path_list = []
        @path_list << path
    end

    def append(path)
        @path_list << path
    end
end
=end
