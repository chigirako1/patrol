require 'nkf'
require 'find'

class Artist < ApplicationRecord
    extend UrlTxtReader

    has_one :twitters, :class_name => 'Twitter'

    def self.looks(target_col, search_word, match_method)
        search_word.strip!
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

    def prediction_up_cnt()
        if status == "長期更新なし" or status == "作品ゼロ"
            return 0
        end
        filenum
        recent_filenum
        delta_d = get_date_delta(last_ul_datetime)

        pred = recent_filenum * 100 / 60 * delta_d / 100
        pred
    end

    def pic_path
        pathlist = Artist.get_pathlist("(#{pxvid})")
        pathlist[0]
        #"<b>test</b>".html_safe
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
            get_date_info(last_access_datetime)
        else
            last_access_datetime.in_time_zone('Tokyo').strftime("%Y-%m-%d")
        end
    end

    def last_access_datetime_p(day = 13)
        if day < 0
            get_date_delta(last_access_datetime) < -day
        else
            get_date_delta(last_access_datetime) < day
        end
    end

    def get_date_delta(date)
        now = Time.zone.now  
        days = (now - date).to_i / 60 / 60 / 24
    end

    def get_date_info(date)
        days = get_date_delta(date)
        if days >= 365
            years = days / 365
            "#{years}年以上前"
        elsif days >= 30
            months = days / 30
            "#{months}ヵ月以上前"
        elsif days == 0
            "24時間以内"
        else
            "#{days}日以内"
        end
    end

    def get_datetime_string(last_ul_datetime)
        now = Time.zone.now
        if last_ul_datetime.year == now.year
          ym_format = "%m月%d日"
        else
          ym_format = "%Y年%m月"
        end
        last_ul_datetime_str = last_ul_datetime.in_time_zone('Tokyo').strftime(ym_format)
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

    def self.get_ulrs(txts)
        id_list = []
        twt_urls = {}
        misc_urls = []

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

                #https://twitter.com/258shin/status/1643549775860727809?t=3vLfQP1QuY67a_OGa9RPMw&s=19
                if url =~ %r!(https?://twitter\.com/\w+/status/\d+)\?.*!
                    #twt_urls.push($1)
                    #twt_urls.push($1 + "/photo/1")
                end

                if twt_urls.has_key? twt_id
                    twt_urls[twt_id] << line
                else
                    twt_urls[twt_id] = []
                    twt_urls[twt_id] << line
                end

                artist = Artist.find_by(twtid: twt_id)
                if artist != nil
                    id_list << artist.pxvid unless id_list.include? (artist.pxvid)
                end
            elsif line =~ %r!(https?://.*)!
                url = $1
                misc_urls.push url
            end
        end
        [id_list, twt_urls, misc_urls]
    end

    def self.get_pathlist(search_str)
        path_list = []
        rpath = ""
    
        base_path = Rails.root.join("public").to_s

        # DBにパスを格納したいが面倒なので。。。　
        txtpath = Rails.root.join("public/pxv/dirlist.txt").to_s
        File.open(txtpath) { |file|
            while line  = file.gets
                if line.include?(search_str)
                    rpath = line.chomp
                    break
                end
            end
        }

        if rpath != ""
            tmp_list = []
            Find.find(rpath) do |path|
                if File.extname(path) == ".jpg"
                    #ファイル名に"#"が含まれるとだめ。マシな方法ないの？
                    tmp_list << path.gsub(base_path, "").gsub("#", "%23")
                end
            end
            path_list = tmp_list.reverse
        end
        path_list
    end

    def self.get_url_list(filepath)
        txtpath = Rails.root.join(filepath).to_s
        txts = File.open(txtpath)
        id_list, twt_urls, misc_urls = get_ulrs(txts)

        [id_list, twt_urls.sort.uniq, misc_urls.sort.uniq, ]
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
        if url =~ %r!(https?://twitter\.com/\w+/status/\d+)\?!
            return $1
        else
            return url
        end
    end
end
