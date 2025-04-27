# coding: utf-8

require 'digest'

module Util
    extend ActiveSupport::Concern

    # よくわからないが、
    # ・"24-09-22".to_date => 0024-09-22
    # ・Date.parse("24-09-22") => 2024-09-22
    # になる
    def self.get_date_delta(date)
        if date == nil
            #puts "date==nil"
            return 0
        end
        now = Time.zone.now
        days = (now.to_date - date.to_date).to_i
        #puts %!#{now.to_date}|#{date.to_date}!
        days
    end

    def self.get_days_date_delta(date_from, date_to)
        (date_to.to_date - date_from.to_date).to_i
    end

    def self.get_date_info(date)
        if date == nil
            return "(未設定)"
        end

        days = Util::get_date_delta(date)
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
        elsif days >= 14
            weeks = days / 7
            "#{weeks}週間以上前"
        elsif days == 0
            "24時間以内"
        else
            "#{days}日以内"
        end
    end

    def self.get_public_path(path)
        Rails.root.join("public" + path).to_s
    end

    def self.escape_path(path)
        path.gsub("#", "%23")
    end

    def self.convert_path(base_path, path)
        Util::escape_path(path.gsub(base_path, ""))
    end

    def self.glob(ipath, glob_param="*/")
        path_list = []

        root_path = Rails.root.join(ipath).to_s + glob_param
        puts %!Util::glob:"#{root_path}", param="#{glob_param}"!
        Dir.glob(root_path).each do |path|
            path_list << path 
        end
        path_list
    end

    def self.get_dir_path_by_twtid(twt_root, twtid)
        puts %!twt_root="#{twt_root}", twtid="#{twtid}"!
        wk_twt_screen_name = twtid.downcase
        Dir.glob(twt_root).each do |path|
            #puts %!get_dir_path_by_twtid(): ath="#{path}"!
            #if twtid == File.basename(path)
            #if twtid.downcase == File.basename(path).downcase
            #if File.basename(path).downcase.start_with?(twtid.downcase)
            if File.basename(path).downcase =~ /^(\w+)\s?/
                id = $1
                if wk_twt_screen_name == id
                    puts %!get_dir_path_by_twtid("#{twtid}"):path="#{path}"!
                    return path
                end
            end
        end
        ""
    end

    def self.month_enumrator(head, tail)
        e = Enumerator.new do |yielder|
      
            while head <= tail
                yielder << head
                head = head.next_month
            end
        end
    end

    def self.year_enumrator(head, tail)
        e = Enumerator.new do |yielder|
      
            while head <= tail
                yielder << head
                head = head.next_year
            end
        end
    end

    def self.file_hash(path)
        Digest::SHA256.file(path).hexdigest
    end

    def self.get_host_name_from_uri(url)
        uri = URI.parse(url)
        uri.host
    end

    def self.formatFileSize(bytes)
        unit = 1024
        if bytes < unit
            return %!#{bytes} Bi!
        end
    
        bytes_log = Math.log(bytes)
        unit_log = Math.log(unit)
        exp = bytes_log / unit_log
        #puts %!#{exp} = #{bytes_log} / #{unit_log}a!
        p = unit.pow(exp)
        b = bytes / p
        u = "KMGTPE"[exp - 1]
        #puts %!#{b} = #{bytes} / #{p}!
    
        %!#{b.to_i} #{u}!
    end
   
    def self.google_search_url(phrase)
        %!https://www.google.com/search?q=#{phrase}!
    end
    
    def self.exception_name_list
        list = []
        txtpath = Rails.root.join("public/exception.txt").to_s
        File.open(txtpath) { |file|
            while line  = file.gets
                list << line.chomp
                STDERR.puts line
            end
        }
        list
    end
end

module ArtistName
REMOVE_WORDS = %w(
原稿中
)
    
# 区切り文字を削除しない対象
EXCEPT_WORDS = %w(
)

SEPA_STRS = %w(
＠
@
：
｜
／
)
        
    def self.remove_spec_str(name)
        rmv_word_list = REMOVE_WORDS.map {|w| Regexp.escape(w)}
        rmv_str = "(" + rmv_word_list.join("|") + ")"
        rgx = Regexp.new(rmv_str)
        name.sub!(rgx, "")
        name.strip!
    
        name
    end

    def self.substitute_name(name)
        subs_name = {
            #"" => "",
        }
        if subs_name.has_key? name
            subs_name[name]
        else
            name
        end
    end
           
       
    # "＠"など区切り文字以降の余計な文字の削除
    def self.del_unnecessary_part(name_orig)
        name_chg = name_orig

        sepa_char_list = SEPA_STRS.map {|w| Regexp.escape(w)}
        sepa_char = "(.*)" + "(" + sepa_char_list.join("|") + ")" + "(.*)"
        sepa_rgx = Regexp.new(sepa_char)

        # /(.*)(土曜|日曜|歌姫庭園|コミケ|コミティア|金曜|C\d\d\d|２日目|2日目|1日目|夏コミ)(.*)/i

        if name_orig =~ sepa_rgx
            name_chg = $1
            #STDERR.puts %!"#{name_orig}" => "#{name_chg}"!
        end
        name_chg
    end

    # 余計な文字の削除。p.g. ＠以降とか
    def self.get_name_part_only(name_orig, exception_names)
        name_chg = name_orig

        # 区切り文字以降の削除
        if name_orig.size < 2
            #puts %!対象外"#{name_chg}"(文字数少ない)!
        elsif exception_names and exception_names.include? name_orig
            #puts %!対象外"#{name_orig}"()!
        else
            name_chg = del_unnecessary_part(name_orig)
        end

        if name_orig != name_chg
            #puts %!#{name_orig}/#{name_chg}!
            removed_str = name_orig.gsub(name_chg, "")
            STDERR.puts %!"#{removed_str}"\t\t"#{name_orig}"\t\t"#{name_chg}"!
            #raise "[DBG] owari"
        end

        name_chg.strip
    end
end