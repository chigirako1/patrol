# =============================================================================
# 
# =============================================================================
class TweetUrl
    attr_accessor :screen_name, :tweet_id, :p_number

    def initialize(screen_name, tweet_id, p_number = -1)
        @screen_name = screen_name
        @tweet_id = tweet_id
        @p_number = p_number
    end

    def self.mov_url_list
        tweet_id_list = []

        STDERR.puts "xxzzxx"
        txts = Util::load_mov_urls()
        STDERR.puts txts.size

        mov_url_hash = Hash.new { |h, k| h[k] = [] }
        txts.each do |line|
            #STDERR.puts %!"#{line}"!
            case line.strip
            when /^$/
                next
            when Twt::TWT_POST_PHOTO_URL_RGX
                # 無視する
                next
            when Twt::TWT_POST_URL_RGX
                screen_name = $1
                tweet_id = $2.to_i
                tweet_id_list << tweet_id
                p_no = 0
                mov_url_hash[screen_name] << TweetUrl.new(screen_name, tweet_id, p_no)
            else
                STDERR.puts %![warning]\t#{line}!
                next
            end
        end

        STDERR.puts mov_url_hash.to_a.size
        
        dup = Util::get_dup_elem(tweet_id_list)
        dup.each do |x|
            STDERR.puts "重複:#{x}"
        end
=begin
=end

        mov_url_hash
    end
end
