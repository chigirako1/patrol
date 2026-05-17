# coding: utf-8

# =============================================================================
# 
# =============================================================================
class PxvArtworkFileList
    attr_accessor :artwork_id, :publication_date, :title, :path_list

    def initialize(artwork_id, title, date, filepath)
        @artwork_id = artwork_id
        @title = title
        @publication_date = date
        @path_list = []
        @path_list << filepath
    end

    def append_path(filepath)
        @path_list << filepath
    end

    def first_pic_path
        @path_list.first
    end

    def pxv_artwork_url
        Pxv::pxv_artwork_url(@artwork_id)
    end

    def <=>(other)
        return nil unless other.is_a?(PxvArtworkFileList)
        [artwork_id] <=> [other.artwork_id]
    end
end


# Artist#artwork_list
# =============================================================================
# 
# =============================================================================
class PxvArtworkList
    attr_accessor :artwork_list

    def initialize(img_path_list)
        artwork_hash = {}

        img_path_list.reverse.each do |path|
            artwork_id, date_str, artwork_title = Pxv::get_pxv_artwork_info_from_path(path)
            begin
                date = Date.parse(date_str)
            rescue Date::Error => ex
                msg = %![artwork_list] #{ex}:#{path}!
                Rails.logger.warn(msg)
                next
            end

            if artwork_id == 0
                STDERR.puts %!regex no hit:"#{path}"!
                next
            end

            if artwork_hash.has_key?(artwork_id)
                artwork_hash[artwork_id].append_path(path)
            else
                if artwork_id < 10
                    msg = %!「#{artwork_title}」(#{artwork_id}), #{date}("#{path}")!
                    Rails.logger.warn(msg)
                end
                artwork_hash[artwork_id] = PxvArtworkFileList.new(artwork_id, artwork_title, date, path)
            end
        end

        @artwork_list = artwork_hash.values
    end

end
