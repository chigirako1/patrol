# coding: utf-8

# =============================================================================
# 
# =============================================================================
class TwtArtwork
    attr_accessor :art_id, :date, :title, :path_list

    def initialize(id, title, date, path)
        @art_id = id
        @title = title
        @date = date
        @path_list = []
        @path_list << path
    end

    def append(path)
        #@path_list.unshift path
        @path_list << path
    end
end
