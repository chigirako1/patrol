# coding: utf-8

# =============================================================================
# 
# =============================================================================
class TwtVideoList
    include Enumerable

    attr_accessor :video_path_list

    def initialize
        #@video_path_list = Util::video_path_list(Twt::TWT_SP_VIDEO_DIR_PATH).map {|x| TwtVideo.new("/" + x)}
        video_path_list = Util::video_path_list(Twt::TWT_SP_VIDEO_DIR_PATH).map {|x| TwtVideo.new("/" + x)}
        @video_path_list = video_path_list.group_by {|x| x.screen_name}.sort_by {|k,v| k.downcase}.to_h
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
            %!#{@screen_name||"※未設定※"} #{@tweet_id||"※未設定※"}!
        end

        def self.get_info(path)
            parent_dirname = Util::parent_dirname(path)
            if parent_dirname =~ /(\w+)/
                screen_name = $1
            else
                screen_name = parent_dirname
            end

            filename = File.basename path
            tweet_id, _ = Twt::mov_filename_ex(filename)
            [screen_name, tweet_id]
        end

    end
end
