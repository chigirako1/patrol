# =============================================================================
# 
# =============================================================================
class TweetUrl
    attr_accessor :screen_name, :tweet_id, :p_number, :record

    def initialize(screen_name, tweet_id, p_number = -1)
        @record = Tweet.find_by(tweet_id: tweet_id)
        @screen_name = screen_name
        @tweet_id = tweet_id
        @p_number = p_number
    end

    def <=>(other)
        return nil unless other.is_a?(TweetUrl)
        [tweet_id, p_number] <=> [other.tweet_id, other.p_number]
    end

    def to_s
        %!@#{@screen_name} #{@tweet_id}/#{p_number}!
    end

    def gen_name
        Twt::filename_str(self.screen_name, self.tweet_id)
    end

    def timestamp
        Twt::get_timestamp(self.tweet_id)
    end

    Cond_del_list = [
        #Tweet::StatusEnum::SAVED,
        Tweet::StatusEnum::DELETED,
        Tweet::StatusEnum::UNNECESSARY,
        Tweet::StatusEnum::UNACCESSIBLE,
        Tweet::StatusEnum::UNACCESSIBLE_FREEZED,
        Tweet::StatusEnum::UNACCESSIBLE_PRIVATE,
        Tweet::StatusEnum::DUPLICATE,
        Tweet::StatusEnum::VIDEO_SAVED,
    ]
    def cond_del
        if self.record and self.record.status
            if Cond_del_list.include?(self.record.status)
                return true
            end
        else
        end
        false
    end

    def self.mov_tweet_group
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
                if tweet_id_list.include?(tweet_id)
                    #STDERR.puts "重複:#{tweet_id}(@#{screen_name})"
                    next
                end
                tweet_id_list << tweet_id
                p_no = 0
                tweet_url = TweetUrl.new(screen_name, tweet_id, p_no)
                key = screen_name
                if key == Twt::TWT_USER_I and tweet_url.record and tweet_url.record.screen_name != screen_name
                    #STDERR.puts %|#{@record.screen_name} != #{screen_name}|
                    key = tweet_url.record.screen_name
                end
                mov_url_hash[key] << tweet_url
            else
                STDERR.puts %![warning]\t#{line}!
                next
            end
        end

        STDERR.puts mov_url_hash.to_a.size
        
=begin
        dup = Util::get_dup_elem(tweet_id_list)
        dup.each do |x|
            STDERR.puts "重複:#{x}"
        end
=end

        mov_url_hash
    end
end
