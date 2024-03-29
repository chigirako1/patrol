# coding: utf-8

require "csv"
require 'find'

module UrlTxtReader
    extend ActiveSupport::Concern

    def get_date_delta(date)
        if date == nil
            puts "date==nil"
            return 0
        end
        now = Time.zone.now
        #days = (now - date).to_i / 60 / 60 / 24
        days = (now.to_date - date.to_date).to_i
        #puts "days=#{days}/#{date}/#{now}"
        days
    end

    def get_year_delta(date)
        get_date_delta(date) / 365
    end

    def last_access_datetime_p(day = 13)
        if day < 0
            get_date_delta(last_access_datetime) < -day
        else
            get_date_delta(last_access_datetime) < day
        end
    end

    def get_date_info(date)
        days = get_date_delta(date)
        if days >= 365
            years, remain = days.divmod(365)
            months = remain / 30
            if months == 0
                "#{years}年以上前"
            else
                "#{years}年#{months}ヶ月以上前"
            end
        elsif days >= 30
            months = days / 30
            "#{months}ヶ月以上前"
        elsif days == 0
            "24時間以内"
        else
            "#{days}日以内"
        end
    end

    def get_date_info_days(date)
        days = get_date_delta(date)
        "#{days}日以内"
    end

    def get_datetime_string(datetime, day_disp = false)
        #if datetime.class.name == "String"
        #    return "string"
        #end
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

    def self.txt_file_list
        path_list = []
        base_path = public_path
        puts %!basepath="#{base_path}"!
        Dir.glob(base_path + "/*") do |path|
            if path =~ /get illust url_\d+\.txt/
                path_list << path
                puts %!path="#{path}"!
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
                tmp_list << path.gsub(base_path, "").gsub("#", "%23")
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
        if filepath.size == 0
            path_list = UrlTxtReader::txt_file_list
        else
            path_list = []
            filepath.each do |path|
                path_list << Rails.root.join(path).to_s
            end
        end

        txt_sum = ""
        path_list.each do |txtpath|
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

    def self.get_ulrs(txts, db_check=false)
        id_list = []
        twt_urls = {}
        misc_urls = []

        #txts.each_line do |line|
        txts.each do |line|
            line.chomp!
            next if line =~ /^$/
    
            if line =~ %r!https?://www\.pixiv\.net/users/(\d+)!
                user_id = $1.to_i
                id_list.push user_id
            elsif line =~ %r!((https?://twitter\.com/(\w+)))$! or line =~ %r!((https?://twitter\.com/(\w+))/.*)!
                url = $1
                #twt_user_url = $2
                twt_id = $3

                if url =~ %r!(https?://twitter\.com/\w+/status/\d+)\?.*!
                    #twt_urls.push($1)
                    #twt_urls.push($1 + "/photo/1")
                end

                if twt_urls.has_key? twt_id
                    # 既存に追加
                    twt_urls[twt_id][1] << line
                else
                    # 新規
                    twt_urls[twt_id] = []

                    if db_check
                        artist = Artist.find_by(twtid: twt_id)
                    else
                        artist = nil
                    end
                    if artist != nil
                        id_list << artist.pxvid
                        twt_urls[twt_id][0] = true
                        twt_urls[twt_id][3] = artist.rating
                    else
                        twt_urls[twt_id][0] = false
                        twt_urls[twt_id][3] = 0
                    end

                    if db_check
                        twt = Twitter.find_by(twtid: twt_id)
                    else
                        twt = nil
                    end
                    if twt != nil
                        twt_urls[twt_id][2] = true
                        twt_urls[twt_id][4] = twt.rating
                    else
                        twt_urls[twt_id][2] = false
                        twt_urls[twt_id][4] = 0
                    end

                    twt_urls[twt_id][1] = []
                    twt_urls[twt_id][1] << line
                end
            elsif line =~ %r!(https?://.*)!
                url = $1
                misc_urls.push url
            else
                misc_urls.push line
             end
        end

        twt_urls = twt_urls.sort_by {|k, v| [v[0]?1:0, v[2]?1:0, v[3]?v[3]:0, v[4]?v[4]:0, -v[1].size, k.downcase]}.to_h
        #twt_urls_pxv_t = twt_urls.select {|x| x[0]}
        #twt_urls_pxv_f = twt_urls.select {|x| !x[0]}
        #twt_urls = twt_urls_pxv_t.merge(twt_urls_pxv_f)

        twt_urls = twt_urls.map {|key, val| [key, val[1]]}.to_h

        #[id_list.uniq, twt_urls, misc_urls]
        [id_list, twt_urls, misc_urls]
    end
end