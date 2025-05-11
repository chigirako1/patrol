# coding: utf-8

require "csv"
require 'find'

module UrlTxtReader
    extend ActiveSupport::Concern

    def get_date_delta(date)
        Util::get_date_delta(date)
    end

    def get_year_delta(date)
        Util::get_date_delta(date) / 365
    end

    def last_access_datetime_p(day = 13)
        delta = Util::get_date_delta(last_access_datetime)
        if day < 0
            #delta < -day
            delta > -day
        else
            delta < day
        end
    end

    def get_date_info(date)
        Util::get_date_info(date)
    end

    def get_date_info_days(date)
        days = Util::get_date_delta(date)
        "#{days}日以内"
    end

    def get_datetime_string(datetime, day_disp = false)
        #if datetime.class.name == "String"
        #    return "string"
        #end
        if datetime == nil
            return "(未設定)"
        end

        now = Time.zone.now
        if datetime.year == now.year
          ym_format = "%m月%d日"
        elsif day_disp
            ym_format = "%Y年%m月%d日"
        else
            ym_format = "%Y年%m月"
        end
        datetime_str = datetime.in_time_zone('Tokyo').strftime(ym_format)
    end

    def select_group(pxvname)
        group = ""
        fl = pxvname[0]
        case fl
        when /[A-Za-z]/
            group = fl.downcase
        when /\p{katakana}/
            fl = NKF.nkf('-w -X', fl) #半角を全角に変換
            fl = fl.tr('ァ-ン','ぁ-ん')
            group = "あ"
        when /\p{hiragana}/
            group = "あ"
        when /[:digit:]/
            group = "0"
        when /[0-9]/
            group = "0"
        when /[가-힣]/
            group = "ハングル"
        else
            group = "他"
        end
        group
    end
  
    def judge_number(filenum)
        if filenum >= 100
            "3多"
        elsif filenum >= 30
            "2中"
        elsif filenum >= 10
            "1小"
        else
            "0"
        end
    end

    def self.public_path
        Rails.root.join("public").to_s
    end

    def self.txt_file_list(rgx="\\d+")
        path_list = []
        base_path = public_path
        puts %!basepath="#{base_path}"!
        rg_filename = %r!get illust url_#{rgx}\.txt!
        p rg_filename
        Dir.glob(base_path + "/*") do |path|
            if path =~ rg_filename
                path_list << path
                #puts %!txt_file_list: path="#{path}"!
            else
           end
        end
        path_list
    end



    def self.get_path_list(tpath)
        tmp_list = []

        if tpath == ""
            puts %!tpath="#{tpath}"!
            return tmp_list
        end

        unless Dir.exist?(tpath)
            puts %!tpath="#{tpath}"!
            return tmp_list
        end

        base_path = UrlTxtReader::public_path
        Find.find(tpath) do |path|
            #puts path
            if [".jpg", ".png", ".jpeg"].include?(File.extname(path))
                #ファイル名に"#"が含まれるとだめ。マシな方法ないの？
                #tmp_list << path.gsub(base_path, "").gsub("#", "%23")
                tmp_list << Util::escape_path(path.gsub(base_path, ""))
            end
        end
        tmp_list
    end

    def self.get_latest_txt(filecnt=1)
        path_list = txt_file_list.sort
        path_list.last(filecnt)
    end

    def self.authors_list(filename, type)
        list = []
        done_list = {}

        base_path = public_path
        tsv_file_path = base_path + "/" + filename
        tsv = CSV.read(tsv_file_path, headers: true, col_sep: "\t")
        tsv.each do |row|
            #no.	cnt	name	old	new	get	yobi	work
            case type
            when "djn"
                name = row["work"]#name
                cnt = row["cnt"]
            when "mag"
                name = row[0]
                cnt = row[1]
            else
                name = row["著者名"]
                cnt = row["数"]
            end

            if done_list.has_key? name
                next
            end
            done_list[name] = ""

            artists = Artist.looks("pxvname", name, "partial_match")
            if artists.size == 0
                artists = Artist.looks("altname", name, "partial_match")
                puts "alt:#{name}"
            end
            list << [name, cnt.to_i, artists]
        end
        
        list.sort_by {|x| [x[2].size, -x[1]]}
    end

    def self.id_from_tsv(tsv_file_path, column_no)
        id_list = []
        tsv = CSV.read(tsv_file_path, headers: true, col_sep: "\t")
        tsv.each do |row|
            id = row[column_no]
            if id =~ /^\d+$/
                id_list << id.to_i
            end
        end
        id_list
    end

    def self.same_name(artists)
        names = artists.map {|x| x.pxvname}
        #puts "names=#{names}"
        chunks = names.chunk(&:itself)
        #puts "chunks=#{chunks}"
        dup_pxvnames = chunks.select{|_, v| v.size > 1}.map(&:first)
        #puts "dup name=#{dup_pxvnames}"
        dup_pxvnames
    end
    
    def self.same_twtid(artists)
        ids = artists.map {|x| x.twtid}
        #puts "names=#{names}"
        chunks = ids.chunk(&:itself)
        #puts "chunks=#{chunks}"
        dup_twtids = chunks.select{|_, v| v.size > 1}.map(&:first)
        #puts "dup name=#{dup_pxvnames}"
        dup_twtids
    end

    def self.get_url_txt_contents(filepath)
        puts %!get_url_txt_contents:"#{filepath}"!
        if filepath
            if filepath.size == 0
                path_list = UrlTxtReader::txt_file_list
            else
                path_list = []
                filepath.each do |path|
                    path_list << Rails.root.join(path).to_s
                end
            end
        else
            path_list = UrlTxtReader::txt_file_list
            path_list = [path_list.last]#最後だけにする
        end

        txt_sum = ""
        path_list.each do |txtpath|
            #puts %!path="#{txtpath}"!
            File.open(txtpath) {|txts|
                txt_sum << txts.read
            }
        end
        txt_sum
    end

    def self.get_url_list(filepath, db_check=false)
        txt_sum = get_url_txt_contents(filepath)
        #id_list, twt_urls, misc_urls = get_ulrs(txt_sum.split(/\R/).sort_by{|s| [s.downcase, s]}.uniq)
        id_list, twt_urls, misc_urls = get_ulrs(txt_sum.split(/\R/), db_check)
        [id_list, twt_urls, misc_urls]
    end

    def self.get_twt_id_list(filepath)
        txt_sum = get_url_txt_contents(filepath)
        twt_user_id_list = get_twt_user_id_list(txt_sum.split(/\R/).sort.uniq)
        twt_user_id_list
    end

    def self.get_twt_user_id_list(lines)
        twt_user_id_list = []

        lines.each do |line|
            line.chomp!
   
            if line =~ %r!((https?://(?:x|twitter)\.com/(\w+)))!
                #url = $1
                #twt_user_url = $2
                twt_id = $3
                twt_user_id_list << twt_id
            end
        end

        twt_user_id_list.sort.uniq
    end

    COL_PXV_EXIST = 0
    COL_URL_LIST = 1
    COL_TWT_EXIST = 2
    COL_PXV_RATING = 3
    COL_TWT_RATING = 4

    def self.get_ulrs(txts, db_check=false)
        id_list = []
        twt_urls = {}
        misc_urls = []

        #txts.each_line do |line|
        txts.each do |line|
            line.chomp!
            next if line =~ /^$/
    
            #138163
            if line =~ %r!https?://www\.pixiv\.net/users/(\d+)! or %r!https?://www\.pixiv\.net/request/plans/(\d+)!
                user_id = $1.to_i
                id_list.push user_id
            #elsif line =~ %r!((https?://twitter\.com/(\w+)))$! or line =~ %r!((https?://twitter\.com/(\w+))/.*)!
            elsif line =~ %r!((https?://(?:x|twitter)\.com/(\w+)))$! or line =~ %r!((https?://(?:x|twitter)\.com/(\w+))/.*)!
                url = $1
                #twt_user_url = $2
                twt_id = $3

                #if url =~ %r!(https?://twitter\.com/\w+/status/\d+)\?.*!
                    #twt_urls.push($1)
                    #twt_urls.push($1 + "/photo/1")
                #end

                if twt_urls.has_key? twt_id
                    # 既存に追加
                    twt_urls[twt_id][COL_URL_LIST] << line
                else
                    # 新規
                    twt_urls[twt_id] = []

                    if db_check
                        artist = Artist.find_by_twtid_ignore_case(twt_id)
                    else
                        artist = nil
                    end
                    if artist != nil
                        id_list << artist.pxvid
                        twt_urls[twt_id][COL_PXV_EXIST] = true
                        twt_urls[twt_id][COL_PXV_RATING] = artist.rating
                    else
                        twt_urls[twt_id][COL_PXV_EXIST] = false
                        twt_urls[twt_id][COL_PXV_RATING] = 0
                    end

                    if db_check
                        twt = Twitter.find_by_twtid_ignore_case(twt_id)
                    else
                        twt = nil
                    end
                    if twt != nil
                        twt_urls[twt_id][COL_TWT_EXIST] = true
                        twt_urls[twt_id][COL_TWT_RATING] = twt.rating
                    else
                        twt_urls[twt_id][COL_TWT_EXIST] = false
                        twt_urls[twt_id][COL_TWT_RATING] = 0
                    end

                    twt_urls[twt_id][COL_URL_LIST] = []
                    twt_urls[twt_id][COL_URL_LIST] << line
                end
            elsif line =~ %r!(https?://.*)!
                url = $1
                misc_urls.push url
            else
                misc_urls.push line
             end
        end

        twt_urls = twt_urls.sort_by {|k, v|
            [
                v[COL_PXV_EXIST]?1:0, 
                v[COL_TWT_EXIST]?1:0, 
                v[COL_PXV_RATING]?v[COL_PXV_RATING]:0, 
                v[COL_TWT_RATING]?v[COL_TWT_RATING]:0, 
                -v[COL_URL_LIST].size, 
                k.downcase
            ]
        }.to_h
        #twt_urls_pxv_t = twt_urls.select {|x| x[0]}
        #twt_urls_pxv_f = twt_urls.select {|x| !x[0]}
        #twt_urls = twt_urls_pxv_t.merge(twt_urls_pxv_f)

        twt_urls = twt_urls.map {|key, val| [key, val[COL_URL_LIST]]}.to_h

        #[id_list.uniq, twt_urls, misc_urls]
        [id_list, twt_urls, misc_urls]
    end

    def self.get_unknown_twt_url_list(path)
        _, twt_infos, _ = get_url_txt_info(path, false, true, false)
        #puts %!pxv_id_list:#{pxv_id_list.size}!
        _, unknown, _ = Twitter::twt_user_classify(twt_infos, false)
        unknown.sort_by {|k,v| -v.size}.to_h
    end

    def self.get_unknown_pxv_id_list(path)
        pxv_id_list, _, _ = get_url_txt_info(path, true, false, false)
        #puts %!pxv_id_list:#{pxv_id_list.size}!
        _, unknown = Artist::pxv_user_id_classify(pxv_id_list)
        unknown
    end

    def self.get_url_txt_info(filepath, pxv=true, twt=true, etc=true, pxv_artwork=false)
        txt_sum = get_url_txt_contents(filepath)
        txts = txt_sum.split(/\R/)

        pxv_id_list = []
        twt_infos = {}
        misc_urls = []
        pxv_artwork_id_list = []

        txts.each do |line|
            line.chomp!
            next if line =~ /^$/
    
            if twt and line =~ %r!(https?://(?:x|twitter)\.com/(\w+))!
                url = $1
                twt_id = $2

                if twt_infos.has_key? twt_id
                    # 既存
                    twt_infos[twt_id].append_url(line)
                else
                    # 新規
                    twt_url = TWT_URL.new(twt_id)
                    twt_url.append_url(line)
                    twt_infos[twt_id] = twt_url
                end
            elsif pxv and line =~ %r!https?://www\.pixiv\.net/users/(\d+)!
                user_id = $1.to_i
                pxv_id_list.push user_id
            elsif pxv_artwork and line =~ %r!https?://www\.pixiv\.net/artworks/(\d+)!
                pxv_artwork_id_list << $1.to_i
            elsif etc and line =~ %r!(https?://.*)!
                url = $1
                misc_urls.push url
            else
                misc_urls.push line
             end
        end

        #[pxv_id_list, twt_infos, misc_urls]
        [pxv_id_list, twt_infos, misc_urls, pxv_artwork_id_list]
    end

    def self.append_page_title_query(url, label)
        uri = URI.parse(url)
        current_query = URI.decode_www_form(uri.query || "")
        if current_query.to_h.include?("page_title")
            new_url = url
        else
            current_query << ["page_title", label]
            uri.query = URI.encode_www_form(current_query)
            new_url = uri.to_s
        end
        new_url
    end
end

class TWT_URL
    attr_reader :twt_id, :url_list

    def initialize(twtid)
        @twt_id = twtid
        @url_list = []
    end

    def append_url(url)
        @url_list << url
    end
end