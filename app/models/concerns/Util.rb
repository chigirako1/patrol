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

    #！！！よくわからないがArtistNameに定義するとコールできない。。。

    def self.get_word_list(filepath)
        list = []
        txtpath = Rails.root.join(filepath).to_s
        File.open(txtpath) { |file|
            while line = file.gets
                str = line.chomp
                list << str
                #STDERR.puts %!ワード:"#{str}"!
            end
        }
        list.sort.uniq
    end

    def self.exception_name_list()
        get_word_list("public/exception.txt")
    end

    def self.words_to_remove()
        get_word_list("public/remove_words.txt")
    end
end



module ArtistName
    def normalize_font(str)
        mapping = {
            "\u{1D412}" => "A", # 𝐴
            # 小文字
            "\u{1D41A}" => "a", # 𝑎
        }

        str.chars.map { |char| mapping[char] || char }.join
    end

    #㈪東ス66b(5342006)
    separate_chars = %w(
    ＠
    @
    ：
    ｜
    ／
    ㈪
    1日目
    )

    sepa_char_list = separate_chars.map {|w| Regexp.escape(w)}
    sepa_char = "(.*?)" + "(" + sepa_char_list.join("|") + ")" + "(.*)"
    @@sepa_rgx = Regexp.new(sepa_char)

    def self.remove_spec_str(name, remove_words)
        rmv_word_list = remove_words.map {|w| Regexp.escape(w)}
        rmv_str = "(" + rmv_word_list.join("|") + ")"
        rgx = Regexp.new(rmv_str)
        name.sub(rgx, "").strip
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

    def self.remove_emoji(str)
        #rgx = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/
        # geminiが作ったやつ↑

        rgx = /\p{Emoji_Modifier_Base}\p{Emoji_Modifier}?|\p{Emoji_Presentation}|\p{Emoji}\uFE0F|\p{In_Letterlike_Symbols}|\p{In_Mathematical_Alphanumeric_Symbols}|\p{Egyptian_Hieroglyphs}|\p{Old_Italic}|\p{In_Enclosed_Alphanumerics}|\p{In_Enclosed_Alphanumeric_Supplement}/
        str.gsub(rgx, '')
    end

    # "＠"など区切り文字以降の余計な文字の削除
    def self.del_unnecessary_part(name_orig)
        name_chg = name_orig

        if name_orig =~ @@sepa_rgx
            name_chg = $1
            #STDERR.puts %!"#{name_orig}" => "#{name_chg}"!
        end
        name_chg
    end

    # 余計な文字の削除。p.g. ＠以降とか
    def self.get_name_part_only(name_orig, exception_names, remove_word_list)
        name_chg = name_orig

        # 区切り文字以降の削除
        if name_orig.size < 2
            #puts %!対象外"#{name_chg}"(文字数少ない)!
        elsif exception_names and exception_names.include? name_orig
            #puts %!対象外"#{name_orig}"()!
        else
            name_chg = del_unnecessary_part(name_orig)
        end

        tmp = remove_emoji(name_chg)
        if tmp.size > 0
            name_chg = tmp
        else
            STDERR.puts %!emoji:すべての文字が削除されたので変更しない:"#{name_chg}"!
        end

        tmp = remove_spec_str(name_chg, remove_word_list)
        if tmp.size > 0
            name_chg = tmp
        else
            STDERR.puts %!words:すべての文字が削除されたので変更しない:"#{name_chg}"!
        end

        name_chg.strip
    end

end