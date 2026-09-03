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

    def <=>(other)
        return nil unless other.is_a?(TwtImage)
        [tweet_id, pic_no, file_path] <=> [other.tweet_id, other.pic_no, other.file_path]
    end

    def datetime
        Twt::get_timestamp(self.tweet_id)
    end

    def file_path_str
        Twt::twt_path_str self.file_path
    end

    def first_pic?
        self.pic_no == 0
    end

    def self.tweet_image_to_hash(tweet_images)
        hash = Hash.new {|h, k| h[k] = []}

        tweet_images.each do |x|
            hash[x.tweet_id] << x
        end

        hash
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

    def initialize(img_path_list, new2old=false)
        @list = []

        img_path_list.each do |fpath|
            #tweet_id, pic_no = Twt::get_tweet_info_from_filepath(fpath)
            tweet_id, pic_no = TweetInfo::get_tweet_info_from_filepath(fpath)
            @list << TwtImage.new(tweet_id, pic_no, fpath)
        end
        @list.sort_by! {|x| [x.tweet_id, -x.pic_no, x.file_path]}
        @list.reverse! if new2old
    end

    def search_tweet(tweet_id)
        list.each do |timg|
            if timg.tweet_id == tweet_id
                #最初に見つかったもの
                return timg
            end
        end
        nil
    end

    def calc_freq
        # 新しい順になっている必要がある
        freq = (Twt::calc_freq(@list.map {|x| x.file_path})).to_f
    end

    def latest_tweet_id()
        list.first.tweet_id
    end

    def sub_list_by_date(target_date)
        hash = TwtImageList.group_by(@list)
        TwtImageList.filter_hash_by_date_range(hash, target_date)
    end

    def self.filter_hash_by_date_range(hash, target_date)
        result = {}

        # 3. 指定された日付より後のキーから最小のもの（直近の未来）を特定して追加
        next_key = hash.keys.select { |date| date > target_date }.min
        result[next_key] = hash[next_key] if next_key

        # 1. 指定された日付と完全に一致するキーが存在するかチェック
        if hash.key?(target_date)
            result[target_date] = hash[target_date]
        end

        # 2. 指定された日付より前のキーから最大のもの（直近の過去）を特定して追加
        prev_key = hash.keys.select { |date| date < target_date }.max
        result[prev_key] = hash[prev_key] if prev_key

        result
    end

    #beginning_of_month/to_date
    def self.group_by(list, key_method = :to_date)
        hash = Hash.new { |h, k| h[k] = [] }

        list.each do |twt_img|
            if twt_img.tweet_id == 0
                # TODO:???
                next
            end
            ts = Twt::get_timestamp(twt_img.tweet_id)
            hash[ts.public_send(key_method)] << twt_img
        end

        hash
    end

    def self.stat(date_group)
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

