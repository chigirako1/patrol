require 'nkf'
require 'find'
require 'date'


class PxvInfo
    attr_reader :pxvid, :cnt, :p

    #def initialize(pxvid, cnt, last_access_datetime=nil, rating=0)
    def initialize(pxvid, cnt, p=nil)
        @pxvid = pxvid
        @cnt = cnt
        @p = p
        #@last_access_datetime = last_access_datetime
        #@rating = rating
    end
end

class Artist < ApplicationRecord
    include UrlTxtReader
    #extend UrlTxtReader 違いがよくわかってない

    has_one :twitters, :class_name => 'Twitter'

    C_ARTIST_TARGET_AUTO = "(自動判断)"
    C_ARTIST_TARGET_PXVID = "pxvid"
    C_ARTIST_TARGET_PXVNAME = "pxvname"

    C_ARTIST_MATCH_AUTO = "auto"
    C_ARTIST_MATCH_PERFECT = "perfect_match"
    C_ARTIST_MATCH_PARTIAL = "partial_match"
    C_ARTIST_MATCH_BEGIN = "begin_match"
    C_ARTIST_MATCH_END = "end_match"

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

    def self.find_by_twtid_ignore_case(twtid, ignore=true)
        if twtid == nil
            return nil
        end

        if ignore
            records = Artist.where('UPPER(twtid) = ?', twtid.upcase)
            if records.size > 1
                puts %!"#{twtid}":#{records.size}件のレコードが見つかりました !
            end
            records.first
        else
            Artist.find_by(twtid: twtid)
        end
    end

    def self.get_path_list(tpath)
        UrlTxtReader::get_path_list tpath
    end

    def self.get_url_list(filepath)
        UrlTxtReader::get_url_list(filepath)
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

        path_list = UrlTxtReader::txt_file_list

        path_list.each do |filepath|
            File.open(filepath) {|txts|
                txts.each do |line|
                    misc_urls << line.chomp!
                end
            }
        end

        misc_urls.sort.uniq
    end

    def self.get_unregisterd_pxv_user_id_list_from_local
        unregisterd_pxv_user_id_list = pxvid_list = []
        Pxv::current_dir_pxvid_list.each do |pxvid|
            p = Artist.find_by(pxvid: pxvid)
            if p
            else
                unregisterd_pxv_user_id_list << pxvid
            end
        end
        unregisterd_pxv_user_id_list
    end
    
    def self.get_unknown_id_list(id_list)
        unknown_id_list = []
        known_ids = known_id_list

        #id_list.sort.uniq.each {|pxvid|
        id_list.each {|pxvid|
            raise "pxvidが数値ではありません" unless pxvid.is_a?(Integer)
            unless known_ids.include? pxvid
              unknown_id_list << pxvid
              puts %!unknown:#{pxvid}!
            end
        }

        cnt_hash = id_list.group_by(&:itself).map{ |key, value| [key, value.count] }.to_h

=begin
        #puts cnt_hash
        cnt_hash.each do |k,v|
            puts %!#{k}=#{v}! if v > 1
        end

        unknown_id_list.each do |x|
            puts %!#{x}=#{cnt_hash[x]}! if cnt_hash[x] > 1
        end
=end

        #unknown_id_list.sort.uniq
        #unknown_id_list.sort_by {|x| cnt_hash[x] }
        unknown_id_list
    end

    def self.known_id_list
        artists_with_pxvid = Artist.select('pxvid')
        db_pxv_ids = artists_with_pxvid.map {|x| x.pxvid}

        curr_dir_id_list = Pxv::current_dir_pxvid_list

        known_ids = [db_pxv_ids, curr_dir_id_list].flatten
        known_ids
    end

    def self.get_twt_url(url)
        #if url =~ %r!(https?://twitter\.com/\w+/status/(\d+))\??!
        if url =~ %r!(https?://(?:x|twitter)\.com/\w+/status/(\d+))\??!
            return $1, $2.to_i
        else
            return url, ""
        end
    end

    def self.pxv_user_id_classify(pxv_user_id_list)
        known_pxv_user_id_list = []
        unknown_pxv_user_id_list = []

        id_hash = pxv_user_id_list.tally

        id_hash.each do |pxvid, cnt|
            #puts %!dbg:#{pxvid}!
            p = Artist.find_by(pxvid: pxvid)
            if p
                known_pxv_user_id_list << PxvInfo.new(pxvid, cnt, p)
            else
                #puts %!dbg:#{pxvid}, #{cnt}!
                unknown_pxv_user_id_list << PxvInfo.new(pxvid, cnt)
            end
        end

        #known_pxv_user_id_list.sort_by! {|x| [x.p.status, x.p.rating, x.p.r18, -(x.cnt), x.p.last_access_datetime]}
        #known_pxv_user_id_list.sort_by! {|x| [x.p.status, x.p.rating==0 ? -11 : -x.p.rating, x.p.r18, -(x.cnt), x.p.last_access_datetime]}
        known_pxv_user_id_list.sort_by! {|x|
            [
                x.p.feature,
                -(x.cnt), 
                x.p.status, 
                x.p.rating==0 ? -11 : -x.p.rating, 
                x.p.r18, 
                x.p.last_access_datetime
            ]
        } if known_pxv_user_id_list


        #puts %!dbg:#{unknown_pxv_user_id_list.size}!
        #puts %!dbg:#{unknown_pxv_user_id_list[0]}!
        unknown_pxv_user_id_list.sort_by! {|x| [-(x.cnt), x.pxvid]}

        [known_pxv_user_id_list, unknown_pxv_user_id_list]
    end

    #--------------------------------------------------------------------------
    # インスタンスメソッド
    #--------------------------------------------------------------------------
    def point

        pred_cnt = prediction_up_cnt(true)
        pt = pred_cnt

        # 評価
        if rating == nil or rating < 60
            comp = 100
        elsif rating < 80
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
        if use_ac_date
            datetime = last_access_datetime
        else
            datetime = last_ul_datetime
        end

        delta_d = get_date_delta(datetime)

        pred = (recent_filenum * 100 / 60) * delta_d / 100
        pred
    end

    def pic_path
        pathlist = Pxv::get_pathlist(pxvid)
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

        #if last_access_datetime.year == Time.zone.now.year
            #get_date_info_days(last_access_datetime)
        #else
            get_date_info(last_access_datetime)
        #end
    end

    def last_ul_datetime_disp
        get_date_info(last_ul_datetime)
    end

    def twt_user_url
        Twt::twt_user_url(twtid)
    end

    def pxv_user_url
        Pxv::pxv_user_url(pxvid)
    end

    def pxv_artwork_url(artwork_id)
        Pxv::pxv_artwork_url(artwork_id)
    end

    def nje_member_url
        Nje::nje_member_url(njeid)
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

    def self.artwork_list(path_list)
        artworks = {}

        #puts path_list.size
        path_list.reverse.each do |path|

            artwork_id, date_str, artwork_title = Pxv::get_pxv_artwork_info_from_path(path)

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
                    if artwork_id < 10
                        STDERR.puts %!warning:artwork id=#{artwork_id}, #{artwork_title}, #{date}!
                    end
                    artworks[artwork_id] = [path, %!#{artwork_title}!, date, 1]
                end
            else
                #puts %!regex no hit:"#{path}"!
            end
        end

        artworks.to_a.reverse.to_h
    end

    def self.artwork_list_file_num(alist)
        sum = 0
        alist.each do |key,val|
            sum += val[3]
        end
        sum
    end

    def status_disp(txt="※")
        if status.presence
            txt + status
        else
            ""
        end
    end
end
