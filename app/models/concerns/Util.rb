# coding: utf-8

module Util
    extend ActiveSupport::Concern

    def self.glob(ipath, glob_param="*/")
        path_list = []

        root_path = Rails.root.join(ipath).to_s + glob_param
        puts %!"#{root_path}"!
        Dir.glob(root_path).each do |path|
            path_list << path 
        end
        path_list
    end
end