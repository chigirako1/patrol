require 'nkf'
require 'find'
require 'date'

class Artist < ApplicationRecord
    include UrlTxtReader
    #extend UrlTxtReader

    has_one :twitters, :class_name => 'Twitter'

    #--------------------------------------------------------------------------
    # クラスメソッド
    #--------------------------------------------------------------------------
    def self.looks(target_col, search_word, match_method)

        search_word.strip!
        puts %!#{target_col}, #{search_word}, #{match_method}!

        if target_col == "(自動判断)"
            if search_word =~ /^\d+$/
                target_col = "pxvid"
            elsif search_word =~ %r!www\.pixiv\.net/users/(\d+)!
                target_col = "pxvid"
                search_word = $1
            else
                target_col = "pxvname"
            end
        end

        if match_method == "auto"
            case target_col
            when "pxvid"
                match_method = "perfect_match"
            else
                match_method = "partial_match"
            end
        end

        puts %!#{target_col}, #{search_word}, #{match_method}!

        search_word_p = ""
        case match_method
        when "perfect_match"
            search_word_p = search_word
        when "begin_match"
            search_word_p = "#{search_word}%"
        when "end_match"
            search_word_p = "%#{search_word}"
        when "partial_match"
            search_word_p = "%#{search_word}%"
        else
            search_word_p = search_word
        end
        @artist = Artist.where("#{target_col} LIKE?", search_word_p)
    end

    def self.get_ulrs(txts)
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

                    artist = Artist.find_by(twtid: twt_id)
                    if artist != nil
                        id_list << artist.pxvid
                        twt_urls[twt_id][0] = true
                    else
                        twt_urls[twt_id][0] = false
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

        twt_urls = twt_urls.sort_by {|k, v| [v[0]?1:0, k]}.to_h
        #twt_urls_pxv_t = twt_urls.select {|x| x[0]}
        #twt_urls_pxv_f = twt_urls.select {|x| !x[0]}
        #twt_urls = twt_urls_pxv_t.merge(twt_urls_pxv_f)

        twt_urls = twt_urls.map {|key, val| [key, val[1]]}.to_h

        [id_list.uniq, twt_urls, misc_urls]
    end

    def self.get_pathlist(pxvid)
        path_list = []

        rpath_list = UrlTxtReader::get_path_from_dirlist(pxvid)
        rpath_list.each do |rpath|
            puts %!path="#{rpath}"!
            path_list << get_path_list(rpath)
        end
        path_list.flatten.sort.reverse
    end

    def self.get_twt_pathlist(twtid)
        path_list = []

        tpath = UrlTxtReader::get_twt_path_from_dirlist(twtid)

        path_list << get_path_list(tpath)

        Dir.glob("D:/data/src/ror/myapp/public/d_dl/Twitter/*/").each do |path|
            if twtid == File.basename(path)
                path_list << get_path_list(path)
                break
            end
        end

        path_list.flatten.sort.reverse
    end

    def self.get_path_list(tpath)
        tmp_list = []

        if tpath == ""
            return tmp_list
        end

        base_path = UrlTxtReader::public_path
        Find.find(tpath) do |path|
            if [".jpg", ".png", ".jpeg"].include?(File.extname(path))
                #ファイル名に"#"が含まれるとだめ。マシな方法ないの？
                tmp_list << path.gsub(base_path, "").gsub("#", "%23")
            end
        end
        tmp_list
    end

    def self.get_url_list(filepath)
        if filepath == ""
            path_list = UrlTxtReader::path_list
        else
            path_list = []
            path_list << Rails.root.join(filepath).to_s
            puts %!path="#{filepath}"!
        end

        txt_sum = ""
        path_list.each do |txtpath|
            File.open(txtpath) {|txts|
                txt_sum << txts.read
            }
        end

        id_list, twt_urls, misc_urls = get_ulrs(txt_sum.split(/\R/).sort_by{|s| [s.downcase, s]}.uniq)
        #[id_list, twt_urls.sort.uniq, misc_urls.sort.uniq]
        [id_list, twt_urls, misc_urls]
    end

    def self.get_id_list()
        id_list = []
        txtpath = Rails.root.join("public/pxvids.txt").to_s
        File.open(txtpath) { |file|
          while line  = file.gets
            if line =~ /(\d+)/
              id_list << $1.to_i
            end
          end
        }
        id_list
    end

    def self.get_id_list_tsv()
        tsvpath = Rails.root.join("public/pxv/mkPDF_call [pxiv, utf8, l3, spec-id] - orig.tsv").to_s
        id_list = UrlTxtReader::id_from_tsv(tsvpath, 3)
        id_list
    end

    def self.get_url_list_from_all_txt
        misc_urls = []

=begin
        path_list = []
        base_path = Rails.root.join("public").to_s
        puts %!basepath="#{base_path}"!
        Dir.glob(base_path + "/*") do |path|
            puts %!path="#{path}"!
            if path =~ /get illust url_\d+\.txt/
                path_list << path
            end
        end
=end
        path_list = UrlTxtReader::path_list

        path_list.each do |filepath|
            File.open(filepath) {|txts|
                txts.each do |line|
                    misc_urls << line.chomp!
                end
            }
        end

        misc_urls.sort.uniq
    end

    def self.get_unknown_id_list(id_list)
        unknown_id_list = []
        artists_with_pxvid = Artist.select('pxvid')
        pxvids = artists_with_pxvid.map {|x| x.pxvid}
        #puts pxvids
        id_list.each {|pxvid|
            unless pxvids.include? pxvid
              unknown_id_list << pxvid
            end
        }
        unknown_id_list.sort.uniq
    end

    def self.get_twt_url(url)
        if url =~ %r!(https?://twitter\.com/\w+/status/(\d+))\?!
            return $1, $2.to_i
        else
            return url, ""
        end
    end

    TW_EPOCH = 1288834974657  # 単位：ミリ秒
    def self.get_timestamp(tweet_id)
        timestamp = Time.at(((tweet_id >> 22) + TW_EPOCH) / 1000.0)
    end

    def self.timestamp_str(tweet_id)
        ts = get_timestamp(tweet_id)
        #ts.strftime("%Y-%m-%d %H:%M:%S.%L %Z")
        ts.strftime("%Y-%m-%d")
    end

    #--------------------------------------------------------------------------
    # インスタンスメソッド
    #--------------------------------------------------------------------------
    def point

        pred_cnt = prediction_up_cnt(true)
        pt = pred_cnt

        # 評価
        if rating == nil or rating < 6
            comp = 100
        elsif rating < 8
            comp = 125
        else
            comp = 150
        end
        pt = (pt * comp) / 100

        # R18
        case r18
        when "R18"
            comp = 160
        when "R15"
            comp = 130
        when "R12"
            comp = 110
        when "cute"
            comp = 100
        when "健全"
            comp = 100
        else
            comp = 110
        end
        pt = (pt * comp) / 100

        # 優先度補正
        if priority == nil
            pri = 100
        elsif priority < 0
            pri = priority * 10
        else
            pri = priority
        end
        pt += (pt * pri) / 100

        # 総ファイル数による補正
        filenum_pt = filenum / 100
        pt += (pt * filenum_pt) / 100

        # 状態による補正
        if status == "長期更新なし" or status == "作品ゼロ" or status == "退会"
            -pt
        else
            years = get_year_delta(last_ul_datetime)
            if years > 3
                -pt
            else
                pt
            end
        end
    end

    def prediction_up_cnt(use_ac_date = false)
        if use_ac_date and last_ul_datetime < last_access_datetime and get_date_delta(last_access_datetime) <= 26
            datetime = last_access_datetime
        else
            datetime = last_ul_datetime
        end

        delta_d = get_date_delta(datetime)

        pred = (recent_filenum * 100 / 60) * delta_d / 100
        pred
    end

    def pic_path
        pathlist = Artist.get_pathlist(pxvid)
        pathlist[0]
        #"<b>test</b>".html_safe
    end

    def nje_p
        njeid != nil and njeid != ""
    end

    def last_dl_datetime_disp
        get_date_info(last_dl_datetime)
    end

    def last_access_datetime_disp
        if last_access_datetime == nil
            return ""
        end

        if last_access_datetime.year == Time.zone.now.year
            #last_access_datetime.in_time_zone('Tokyo').strftime("%m月%d日")
            get_date_info_days(last_access_datetime)
        else
            #last_access_datetime.in_time_zone('Tokyo').strftime("%Y-%m-%d")
            get_date_info(last_access_datetime)
        end
    end

    def twt_user_url
        # controllerとmodelで共通の処理を書きたいのだが、やり方がわからない
        %!https://twitter.com/#{twtid}!
    end

    def pxv_user_url
        %!https://www.pixiv.net/users/#{pxvid}!
    end

    def pxv_artwork_url(artwork_id)
        %!https://www.pixiv.net/artworks/#{artwork_id}!
    end

    def nje_member_url
        %!https://nijie.info/members.php?id=#{njeid}!
    end

    def stats(path_list)
        stats = {}

        path_list.each do |path|
            if path =~ /(\d\d-\d\d-\d\d)/
                begin
                    date = Date.parse($1)
                rescue Date::Error => ex
                    puts %!#{ex}:#{path}!
                    next
                end
                year = date.year
                month = date.month - 1
                day = date.day

                if stats.has_key?(year)
                    stats[year][month] += 1
                else
                    stats[year] = Array.new(12, 0)
                    stats[year][month] = 1
                end
            end
        end

        stats
    end

    def artwork_list(path_list)
        artworks = {}

        #puts path_list.size
        path_list.reverse.each do |path|
            artwork_id = 0
            if path =~ /(\d\d-\d\d-\d\d)\s*(.*)\((\d+)\)/
                date_str = $1
                artwork_title = $2
                artwork_id = $3.to_i
            elsif path =~ /(\d\d-\d\d-\d\d)\s*\((\d+)\)\s*(.*)/
                date_str = $1
                artwork_id = $2.to_i
                artwork_title = $3
            elsif path =~ /(\d\d-\d\d-\d\d)\s*(.*)/
                date_str = $1
                artwork_title = $2
            else
                puts %!regex no hit:"#{path}"!
                date_str = ""
            end

            begin
                date = Date.parse(date_str)
            rescue Date::Error => ex
                puts %!#{ex}:#{path}!
                next
            end

            if artwork_id != 0
                if artworks.has_key?(artwork_id)
                    artworks[artwork_id][3] += 1
                else
                    #puts artwork_id
                    #puts artwork_title
                    artworks[artwork_id] = [path, %!#{artwork_title}!, date, 1]
                end
            else
                #puts %!regex no hit:"#{path}"!
            end
        end

        artworks.to_a.reverse.to_h
    end

end
