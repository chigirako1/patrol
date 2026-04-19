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

    def datetime
        Twt::get_timestamp(self.tweet_id)
    end
end

# =============================================================================
# 
# =============================================================================
class TwtPost
    attr_accessor :tweet_id, :datetime, :twt_image_list

    def initialize(tweet_id)
        @tweet_id = tweet_id
        @twt_image_list = []
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

    def self.group_by_date(list)
        hash = Hash.new { |h, k| h[k] = [] }

        list.each do |twt_img|
            if twt_img.tweet_id == 0
                next
            end
            ts = Twt::get_timestamp(twt_img.tweet_id)
            hash[ts.to_date] << twt_img
        end

        hash
    end

    def self.a_to_h(data)
        result = data.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(key, value), hash|
            hash[key] << value
        end

        result
=begin
        #data = [[1, "a"], [1, "b"], [2, "c"]]

        # group_by で 1段目の要素（キー）ごとにまとめる
        grouped = data.group_by(&:first)

        # 値（ペアの配列）から、2番目の要素だけを抽出する
        result = grouped.transform_values { |pairs| pairs.map(&:last) }
=end
    end
end

# =============================================================================
# 
# =============================================================================
class TwtImageGroup
end
