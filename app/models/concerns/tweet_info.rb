# coding: utf-8

require 'base64'

module TweetInfo
    extend ActiveSupport::Concern

    def self.dbgputs(filename, tweet_id, pic_no, lineno)
        STDERR.puts %!#{lineno}:\t#{tweet_id}\t#{pic_no}\t"#{filename}"!
    end
    
    def self.get_tweet_info(filename)
        dbg = true
        tweet_id = 0
        pic_no = 0
        #guess = false

        # 2090398080554418999 0 2026-08-21.jpg
        if filename =~ /(\d+)\s(\d+)\s(\d+\-\d+\-\d+)/
            tweet_id = $1.to_i
            pic_no = $2.to_i
            #$3 dl日時
            #dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        elsif filename =~ /(\d+)\s\w+\s(\d+\-\d+\-\d+)/
            tweet_id = $1.to_i
            pic_no = -1
            #dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        elsif filename =~ /^(\d{19})\s(\d+).*/
            tweet_id = $1.to_i
            pic_no = $2.to_i
            dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        elsif filename =~ /(\d+)\s(\d+)\s(\d+)/
            dl_date_str = $1
            begin
                #dl_date = Date.parse(dl_date_str)
            rescue Date::Error => ex
              Rails.logger.warn(ex)
            end
            tweet_id = $2.to_i
            pic_no = $3.to_i
            dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        elsif filename =~ /\d+-\d+-\d+\s+\((\d+)\)/
            tweet_id = $1.to_i
            dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        elsif filename =~ /(\d\d\d+)-(\d+)/
            tweet_id = $1.to_i
            pic_no = $2.to_i
            dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        #elsif filename =~ /^\d{8}_\d{6}\./
        elsif filename =~ /(\d{8})_\d{6}/
            date = Date.parse $1
            tweet_id = Twt::time2tweet_id(date.to_datetime)
            #STDERR.puts %!"#{filename}" => #{date}, #{tweet_id}/!
            guess = true
            #dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        #elsif filename =~ /^[\w\-]{15}\./ #base64???
        elsif filename =~ /TID\-unknown\-([A-Za-z0-9\-_=]{15})/
            base64str = $1
            ts, tweet_id = base64str_info(base64str) #BUG:tweet idとして扱うのはだめ
            guess = true
            #dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        elsif filename =~ /^([A-Za-z0-9\-_=]{15})/
            base64str = $1
            ts, tweet_id = base64str_info(base64str) #BUG:tweet idとして扱うのはだめ
            guess = true
            #dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        elsif filename =~ /^(\d{18,}) \w+/ #18は適当
            tweet_id = $1.to_i
            dbgputs(filename, tweet_id, pic_no, __LINE__) if dbg
        else
            #STDERR.puts
            #STDERR.puts %!regex no hit:#{filename}!
        end
        [tweet_id, pic_no]
    end

    def self.get_tweet_info_from_filepath(filepath)
        fn = File.basename filepath
        get_tweet_info(fn)
    end

    def self.get_tweet_id_from_filepath(filepath)
        tweet_id, _ = get_tweet_info_from_filepath(filepath)
        tweet_id
    end

    # url safe
    #/[A-Za-z0-9\-_=]/
    #/^[A-Za-z0-9\-_]+={0,2}$/

    # 標準
    #[A-Za-z0-9+/=]
    #^[A-Za-z0-9+/]+={0,2}$

    def self.base64str_info(base64str)
        ts = extract_twitter_image_timestamp(base64str)
        tweet_id = Twt::time2tweet_id(ts)
        #STDERR.puts %!"#{base64str}" => #{ts}, #{tweet_id}!
        [ts, tweet_id]
    end

    def self.extract_twitter_image_media_id(filename_or_url)
        # 1. URLや拡張子を除いたファイル名本体を取得
        basename = File.basename(filename_or_url, '.*')
        
        # 2. URLセーフ文字（'-' -> '+', '_' -> '/'）を置換し、パディングを調整
        # Base64としてデコード可能な形式にクレンジングする
        cleaned = basename.tr('-_', '+/')
        padding_len = (4 - (cleaned.length % 4)) % 4
        cleaned += '=' * padding_len
        
        # 3. Base64デコードしてバイナリを取得（失敗時は例外の代わりにnilを返すなどの耐障害性も持たせられます）
        binary_data = Base64.decode64(cleaned)
        
        # 4. 8バイト（64ビット）の整数に変換
        # バイナリの先頭から8バイトをビッグエンディアンとして数値化
        id_int = binary_data.bytes[0...8].inject(0) { |acc, byte| (acc << 8) + byte }
        id_int
    end

    def self.extract_twitter_image_timestamp(filename_or_url)
        id_int = extract_twitter_image_media_id(filename_or_url)

        # 5. Snowflake IDの仕様に基づいてタイムスタンプ（ミリ秒）を計算
        twitter_epoch = 1288834974657
        timestamp_ms = (id_int >> 22) + twitter_epoch
        
        # 6. Timeオブジェクト（UTC）に変換して返却
        Time.at(timestamp_ms / 1000.0).utc
    end

    # こっちはうまく動かない時がある
=begin
    def self.extract_twitter_image_timestamp_obsolete(filename_or_url)
        # 1. URLや拡張子（.jpg, .png等）が含まれている場合はファイル名（ベース名）のみを抽出する
        basename = File.basename(filename_or_url, '.*')

        # 2. Base64のパディング（=）を調整し、URLセーフなデコードを行う
        # パスや拡張子を除いた文字列を対象にする
        padding = '=' * ((4 - (basename.length % 4)) % 4)

        STDERR.puts %!#{basename}\t#{padding}!

        binary_data = Base64.urlsafe_decode64(basename + padding)
        
        # 3. バイナリデータを64ビット整数（BigEndian）に変換する
        # 先頭の8バイト（64ビット）を使用
        id_int = binary_data.bytes[0...8].inject(0) { |acc, byte| (acc << 8) + byte }
        
        # 4. Snowflake IDの仕組みに従ってタイムスタンプ（ミリ秒）を抽出
        # 右に22ビットシフトし、TwitterのEpoch（1288834974657）を足す
        twitter_epoch = 1288834974657
        timestamp_ms = (id_int >> 22) + twitter_epoch
        
        # 5. ミリ秒を秒に変換してRubyのTimeオブジェクト（UTC）を生成する
        Time.at(timestamp_ms / 1000.0).utc
    end
=end

    def self.tweeet_id_eq?(path, tweet_id)
        #path.include? tweet_id.to_s and get_tweet_id_from_filepath(path) == tweet_id
        path.include? tweet_id.to_s
        #get_tweet_id_from_filepath(path) == tweet_id
    end

    # tweet idとmedia idに格納されている日時は少しズレが発生する。予約投稿の場合は全く別の時間になる？
    def self.datetime_match?(path, datetime_t)
        #tweet_id = get_tweet_id_from_filepath(path)
        #datetime_t = Twt::get_timestamp target_tweet_id
        datetime_m = Twt::get_timestamp_from_filepath path
        #STDERR.puts %!#{datetime_t} <=> #{datetime_m}\t[#{target_tweet_id}\t"#{path}"!
        seconds = 24 * 60 * 60
        if Util::within_last_n_seconds?(datetime_t, datetime_m, seconds)
            #STDERR.puts %!#{seconds}s #{datetime_t.to_f - datetime_m.to_f}\t"#{path}"\t#{datetime_t} <=> #{datetime_m}!
            true
        else
            false
        end
    end
end

class TweetPicInfo
    attr_accessor :tweet_id, :hash_val, :filesize
    
end


=begin
require 'net/http'
require 'uri'

# 最大リダイレクト回数を設定（無限ループ防止のため）
MAX_REDIRECTS = 5

def resolve_tweet_url(url_string)
  uri = URI.parse(url_string)
  redirect_count = 0
  
  # リダイレクトを追跡するループ
  while redirect_count < MAX_REDIRECTS
    # HTTPリクエストのセットアップ
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    
    # GETリクエストを実行（ヘッダーのみを取得するため、HEADリクエストを使用することが多いが、
    # リダイレクト処理の確実性を考慮し、今回はGETを使用）
    request = Net::HTTP::Get.new(uri.request_uri)
    
    begin
      response = http.request(request)
    rescue => e
      # 接続エラーやタイムアウトなどの処理
      return "接続エラーが発生しました: #{e.message}"
    end
    
    # ステータスコードがリダイレクトを示すかチェック（301, 302, 303, 307, 308）
    if response.code.start_with?('3') && response['location']
      # 新しいリダイレクト先を取得
      new_location = response['location']
      
      # 新しいURIをパース
      uri = URI.parse(new_location)
      
      # URLが相対パスだった場合（稀なケース）、元のURIを基に絶対URLに変換
      uri = uri.host ? uri : URI.join(url_string, new_location)
      
      redirect_count += 1
      
    else
      # リダイレクトが終了、またはエラーが発生した場合
      return uri.to_s
    end
  end
  
  # 最大リダイレクト回数を超えた場合
  return "リダイレクト回数が上限 (#{MAX_REDIRECTS}回) を超えました。"
end

# --- 使用例 ---
url = "https://x.com/i/status/19976728225"
final_url = resolve_tweet_url(url)

puts "元のURL: #{url}"
puts "最終的なURL: #{final_url}"
=end
