# coding: utf-8

module TweetInfo
    extend ActiveSupport::Concern

    def self.get_tweet_info(filename)
        tweet_id = 0
        pic_no = 0
        if filename =~ /(\d+)\s(\d+)\s(\d+\-\d+\-\d+)/
            #puts fn
            tweet_id = $1.to_i
            pic_no = $2.to_i
        elsif filename =~ /(\d+)\s(\d+)\s(\d+)/
            dl_date_str = $1
            begin
                #dl_date = Date.parse(dl_date_str)
            rescue Date::Error => ex
              Rails.logger.warn(ex)
            end
            tweet_id = $2.to_i
            pic_no = $3.to_i
        elsif filename =~ /\d+-\d+-\d+\s+\((\d+)\)/
            tweet_id = $1.to_i
        elsif filename =~ /(\d\d\d+)-(\d+)/
            tweet_id = $1.to_i
            pic_no = $2.to_i
        elsif filename =~ /TID\-unknown\-/
        elsif filename =~ /^[\w\-]{15}\./
            STDERR.puts %![dbg] #{filename}!
            #Rails.logger.warn(filename)
        elsif filename =~ /^(\d{18,}) \w+/ #18は適当
          tweet_id = $1.to_i
        # "20251208_193650"
        elsif filename =~ /(\d{8})_\d{6}/
          date = Date.parse $1
          Twt::time2tweet_id(date.to_datetime)
        else
            STDERR.puts %!regex no hit:#{filename}!
        end
        [tweet_id, pic_no]
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
