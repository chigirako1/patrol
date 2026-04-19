# coding: utf-8

require 'digest'

module Util
    extend ActiveSupport::Concern

    EXCEPTION_TXT_PATH = "public/exception.txt"
    REMOVE_WORDS_FILE_PATH = "public/remove_words.txt"

    def self.get_param_num(params, symbol, def_val=0)
=begin
        if params[symbol] == ""
            value = def_val
        else
            value = params[symbol].to_i
        end
=end
        if params[symbol].presence
            value = params[symbol].to_i
        else
            value = def_val
        end
        STDERR.puts %!#{symbol}="#{value}"!
        value
    end

    def self.get_param_str(params, symbol, def_val="")
        if params[symbol]
            value = params[symbol]
        else
            value = def_val
        end
        STDERR.puts %!#{symbol}="#{value}"!
        value
    end

    def self.get_param_bool(params, symbol)
        if params[symbol].presence
            value = true
        else
            value = false
        end
        STDERR.puts %!#{symbol}="#{value}"!
        value
    end

    def self.hours_from_now(target_datetime)
        # 引数が文字列の場合はTimeオブジェクトに変換
        target_time = target_datetime.is_a?(String) ? Time.parse(target_datetime) : target_datetime
        
        # 現在時刻との差分（秒）を計算
        diff_seconds = Time.now - target_time

        return (diff_seconds / 3600).to_i
        
        # 秒を時間に変換（1時間 = 3,600秒）
        # .to_f で浮動小数点数にして精度を保つ
        diff_hours = diff_seconds / 3600.0
        
        # 読みやすさのために小数点第2位で丸める（任意）
        diff_hours.round(2)
    end

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

    def self.elapsed?(specified_datetime, days)
        Time.current >= specified_datetime + days_to_check.days
    end

    # 与えられた文字列をDateTimeオブジェクトに変換するメソッド
    #
    # @param datetime_string [String] "YYYYMMDD_HHMMSS"形式の文字列 (例: "20251106_202848")
    # @return [DateTime] 変換されたDateTimeオブジェクト
    def self.string_to_datetime(datetime_string, format = '%Y%m%d_%H%M%S')
        # strptimeはタイムゾーン情報を指定しない場合、協定世界時 (UTC) としてDateTimeオブジェクトを作成します。
        # ローカルタイムとして解釈したい場合は、適宜タイムゾーンの指定を追加してください。
        #DateTime.strptime(datetime_string, format)
        Time.zone.strptime(datetime_string, format)
    end

    def self.datetime_disp(datetime, day_disp = false)
        %!#{Util::get_datetime_string(datetime, day_disp)}(#{Util::get_date_info(datetime)})!
    end

    def self.get_datetime_string(datetime, day_disp = false)
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

    def self.get_date_info(date)
        if date == nil
            return "(未設定)"
        end

        #return view_context.distance_of_time_in_words(date, Time.zone.now)
        #time_ago_in_words

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
            #"#{weeks}週間(#{days}日)以上前"
            "#{weeks}週間以上前"
        elsif days == 0
            now = Time.zone.now
            if date.instance_of?(String) or date.instance_of?(Date)
                hour = 24
            else
                hour = now.hour - date.hour
                if hour > 0
                    "#{hour}時間以内"
                else
                    "#{((now - date) / 1.minute).to_i}分以内"
                end
            end
        else
            "#{days}日以内"
        end
    end

    #============================================================
    # 文字列関連
    #============================================================
    def self.format_num(number, unit, digit=3)
        w = (number||0) / unit * unit
        sprintf("%#{digit}d", w)
    end

    #============================================================
    # パス関連
    #============================================================
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
        Dir.glob(root_path).each do |path|
            path_list << path 
        end
        STDERR.puts %!Util::glob():"#{root_path}", param="#{glob_param}", path_list.size=#{path_list.size}!
        path_list
    end

    def self.get_filesize(path)
        phys_path = get_public_path(path)
        FileTest.size(phys_path)
    end

    def self.find_duplicate_sizes(file_paths)
        # 1. パスが存在するか確認し、サイズをキーにしたハッシュを作成
        size_map = file_paths.each_with_object(Hash.new { |h, k| h[k] = [] }) do |path, hash|
            if File.exist?(path) && File.file?(path)
                size = File.size(path)
                hash[size] << path
            end
        end

        # 2. 要素が2つ以上（重複している）ものだけを抽出
        size_map.select { |_size, paths| paths.size > 1 }
    end

    #============================================================
    # 時間関連
    #============================================================
    def self.find_missing_dates(dates)
        return [] if dates.empty?

        # 昇順にソート（念のため）
        sorted_dates = dates.sort
        
        # 開始日から終了日までの全日付範囲を生成
        full_range = (sorted_dates.first..sorted_dates.last).to_a
        
        # 差分を抽出して返却
        full_range - sorted_dates
    end

    def self.filter_consecutive_dates(dates)
        return dates if dates.size <= 2

        # 念のため日付順にソート
        sorted_dates = dates.sort

        sorted_dates.select.with_index do |date, i|
            # 最初と最後は必ず残す
            next true if i == 0 || i == sorted_dates.size - 1

            # 前後の日付を取得
            prev_date = sorted_dates[i - 1]
            next_date = sorted_dates[i + 1]

            # 「前日との差が1日」かつ「翌日との差が1日」であれば、それは中間日なので削除する
            # つまり、それ以外の場合のみ残す
            !((date - prev_date == 1) && (next_date - date == 1))
        end
    end

    def self.group_consecutive_dates(dates)
        return [] if dates.empty?

        # 1. 昇順にソート（念のため）
        sorted_dates = dates.sort

        # 2. 隣り合う日付が「1日差」でない場所で分割する
        # chunk_while は、隣り合う要素 (prev, curr) を比較して
        # trueを返す間は同じグループ、falseを返すと新しいグループにします
        sorted_dates.chunk_while { |prev, curr| (curr - prev).to_i == 1 }
                    .map { |group| [group.first, group.last] }
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
        exp = (bytes_log / unit_log).to_i
        p = unit.pow(exp)
        b = (bytes.to_f / p)
        u = "KMGTPE"[exp - 1]

        #%!#{b} #{u}B!
        sprintf("%.2f %sB", b, u)
    end

    def self.formatFileSizeKB(bytes)
        unit = 1024
        if bytes < unit
            return %!#{bytes} Bi!
        end
        %!#{bytes / 1024} KB!
    end

    def self.google_search_url(phrase)
        %!https://www.google.com/search?q=#{phrase}!
    end

    #！！！よくわからないがArtistNameに定義するとコールできない。。。

    def self.get_word_list(filepath)
        STDERR.puts %![get_word_list]"#{filepath}"!
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
        get_word_list(EXCEPTION_TXT_PATH)
    end

    def self.words_to_remove()
        get_word_list(REMOVE_WORDS_FILE_PATH)
    end

    def self.parent_dirname(path)
        # "a/b/c.txt" => "b"
        File.basename(File.dirname path)

        # path = "a/b/c.txt"
        # pathname = Pathname.new(path)
        # parent_directory = pathname.parent.basename.to_s
    end
end


module ArtistName
    def self.normalize_font(str)
        mapping = {
            "\u{1D412}" => "A", # 𝐴
            # 小文字
            "\u{1D41A}" => "a", # 𝑎
        }

        str.chars.map { |char| mapping[char] || char }.join
    end

    #@@emoji_rgx = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/
    # geminiが作ったやつ↑
    @@emoji_rgx = /\p{Emoji_Modifier_Base}\p{Emoji_Modifier}?|\p{Emoji_Presentation}|\p{Emoji}\uFE0F|\p{In_Letterlike_Symbols}|\p{In_Mathematical_Alphanumeric_Symbols}|\p{Egyptian_Hieroglyphs}|\p{Old_Italic}|\p{In_Enclosed_Alphanumerics}|\p{In_Enclosed_Alphanumeric_Supplement}/

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
    #sepa_char = "(.*?)" + "(" + sepa_char_list.join("|") + ")" + "(.*)"
    sepa_char = "(.+?)" + "(" + sepa_char_list.join("|") + ")" + "(.*)"
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

        str.gsub(@@emoji_rgx, '')
    end

    # "＠"など区切り文字以降の余計な文字の削除
    def self.del_unnecessary_part(name_orig)
        name_chg = name_orig

        if name_orig =~ @@sepa_rgx
            name_chg = $1
            #STDERR.puts %!"#{name_orig}" => "#{name_chg}"!
        #elsif name_orig =~ /(.*)\p{Emoji}/ #←これだと数字までマッチしてしまう。。。
        elsif name_orig =~ /(.*)#{@@emoji_rgx}/
            name_chg = $1
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
            STDERR.puts %!emoji:すべての文字が削除されたので変更しない:"#{name_orig}"!
        end

        tmp = remove_spec_str(name_chg, remove_word_list)
        if tmp.size > 0
            name_chg = tmp
        else
            STDERR.puts %!words:すべての文字が削除されたので変更しない:"#{name_orig}"/"#{name_chg}"!
        end

        name_chg.strip
    end

    def aspect_ratio(width, height)
        target_ratio = [16, 9] # 基準となる比率
        actual_ratio = [width.to_f / height, height.to_f / width]

        # 近い比率をチェック
        if (actual_ratio[0] - target_ratio[0].to_f / target_ratio[1]).abs < 0.01
            return "#{target_ratio[0]},#{target_ratio[1]}"
        end

        gcd = width.gcd(height) # 最大公約数で約分
        "#{width / gcd},#{height / gcd}"
    end
end