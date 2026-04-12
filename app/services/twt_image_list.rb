# coding: utf-8

# =============================================================================
# 
# =============================================================================
class TwtImage
    attr_accessor :tweet_id, :pic_no, :file_path

    def initialize(tweet_id, pic_no, file_path)
        @tweet_id = tweet_id
        @pic_no = pic_no
        @file_path = file_path
    end
end

# =============================================================================
# 
# =============================================================================
class TwtImageList
    attr_accessor :list

    def initialize(img_path_list)
        @list = []

        img_path_list.each do |fpath|
            tweet_id, pic_no = Twt::get_tweet_info_from_filepath(fpath)
            @list << TwtImage.new(tweet_id, pic_no, fpath)
        end
        @list.sort_by! {|x| [x.tweet_id, x.file_path]}
    end

    def group_by_date()
        hash = Hash.new { |h, k| h[k] = [] }

        @list.each do |x|
            ts = Twt::get_timestamp(x.tweet_id)
            hash[ts.to_date] << x
        end

         hash
    end
end

# =============================================================================
# 
# =============================================================================
class TwtImageGroup
end
