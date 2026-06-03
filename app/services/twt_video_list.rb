# coding: utf-8

# =============================================================================
# 
# =============================================================================
class TwtVideoList
    include Enumerable

    attr_accessor :video_path_list

    def initialize
        #@video_path_list = Util::glob("#{Twt::TWT_SP_VIDEO_DIR_PATH}", "*/*").map {|x| TwtVideo.new(x)}
        @video_path_list = Util::video_path_list(Twt::TWT_SP_VIDEO_DIR_PATH).map {|x| TwtVideo.new("/" + x)}
    end

    def each(&block)
        @video_path_list.each(&block)
    end

    def size
        @video_path_list.size
    end

    class TwtVideo
        attr_accessor :filepath, :screen_name, :tweet_id

        def initialize(filepath)
            @filepath = filepath
            @screen_name, @tweet_id = self.class.get_info(filepath)
            #@screen_name, @tweet_id = get_info(filepath) 内部クラスだと呼べない？よくわからん
        end

        def <=>(other)
            return nil unless other.is_a?(filepath)
            [filepath] <=> [other.filepath]
        end

        def to_s
            %!#{@screen_name} #{@tweet_id}!
        end

        def self.get_info(path)
            screen_name = Util::parent_dirname(path)
            filename = File.basename path
            if filename =~ /^(\d+)/
                tweet_id = $1
            end
            [screen_name, tweet_id]
        end

    end
end
