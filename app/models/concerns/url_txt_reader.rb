# coding: utf-8

require "csv"

module UrlTxtReader
    extend ActiveSupport::Concern

    def get_date_delta(date)
        now = Time.zone.now  
        days = (now - date).to_i / 60 / 60 / 24
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

    def self.path_list
        path_list = []
        base_path = Rails.root.join("public").to_s
        puts %!basepath="#{base_path}"!
        Dir.glob(base_path + "/*") do |path|
            puts %!path="#{path}"!
            if path =~ /get illust url_\d+\.txt/
                path_list << path
            end
        end
        path_list
    end

    def self.authors_list
        list = []

        base_path = Rails.root.join("public").to_s
        tsv_file_path = base_path + "/r18book_author_20230813.tsv"
        tsv = CSV.read(tsv_file_path, headers: true, col_sep: "\t")
        tsv.each do |row|
            name = row["著者名"]
            cnt = row["数"]
            artists = Artist.looks("pxvname", name, "partial_match")
            list << [name, cnt.to_i, artists]
        end
        
        list.sort_by {|x| -x[1]}
    end
end