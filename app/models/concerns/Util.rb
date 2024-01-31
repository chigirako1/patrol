# coding: utf-8

module Util
    extend ActiveSupport::Concern

    def self.glob(ipath, glob_param="*/")
        path_list = []

        root_path = Rails.root.join(ipath).to_s + glob_param
        puts %!"glob:#{root_path}"!
        Dir.glob(root_path).each do |path|
            path_list << path 
        end
        path_list
    end

    def self.get_dir_path_by_twtid(twt_root, twtid)
        puts %!twt_root="#{twt_root}", twtid="#{twtid}"!
        Dir.glob(twt_root).each do |path|
            if twtid == File.basename(path)
                puts %!path="#{path}"!
                return path
            end
        end
        ""
    end
end