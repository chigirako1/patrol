class Artist < ApplicationRecord
    #include UrlTxtReader
    extend UrlTxtReader

    has_one :twitters, :class_name => 'Twitter'

    def self.get_twt_url(url)
        if url =~ %r!(https?://twitter\.com/\w+/status/\d+)\?!
            return $1
        else
            return url
        end
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
=begin
        id_list.each {|pxvid|
            result = Artist.find_by(pxvid: pxvid)
            if result == nil
              unknown_id_list << pxvid
            end
        }
=end
        artists_with_pxvid = Artist.select('pxvid')
        pxvids = artists_with_pxvid.map {|x| x.pxvid}
        #puts pxvids
        id_list.each {|pxvid|
            unless pxvids.include? pxvid
              unknown_id_list << pxvid
            end
        }
        unknown_id_list
    end

    def self.get_url_list()
        txtpath = Rails.root.join("public/get illust url_0907.txt").to_s
        txts = File.open(txtpath)
        id_list, twt_urls, misc_urls = get_ulrs(txts)

        [id_list, twt_urls.sort.uniq, misc_urls.sort.uniq, ]
    end

    def self.looks(target_col, search_word, match_method)
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
        #puts %!#{filenum}, #{recent_filenum}, #{delta_d}, #{pred}!
        pred
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
        get_date_delta(last_access_datetime) < 13
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
            "今日"
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
end
