# coding: utf-8

module Util
    extend ActiveSupport::Concern

    def self.get_date_delta(date)
        if date == nil
            puts "date==nil"
            return 0
        end
        now = Time.zone.now
        days = (now.to_date - date.to_date).to_i
        days
    end

    def self.get_date_info(date)
        if date == nil
            return "(未設定)"
        end

        days = Util::get_date_delta(date)
        if days >= 365
            years, remain = days.divmod(365)
            months = remain / 30
            if months == 0
                "#{years}年以上前"
            else
                "#{years}年#{months}ヶ月以上前"
            end
        elsif days >= 30
            months = days / 30
            "#{months}ヶ月以上前"
        elsif days >= 14
            weeks = days / 7
            "#{weeks}週間以上前"
        elsif days == 0
            "24時間以内"
        else
            "#{days}日以内"
        end
    end

    def self.get_public_path(path)
        Rails.root.join("public" + path).to_s
    end

    def self.glob(ipath, glob_param="*/")
        path_list = []

        root_path = Rails.root.join(ipath).to_s + glob_param
        puts %!glob:"#{root_path}"!
        Dir.glob(root_path).each do |path|
            path_list << path 
        end
        path_list
    end

    def self.get_dir_path_by_twtid(twt_root, twtid)
        puts %!twt_root="#{twt_root}", twtid="#{twtid}"!
        wk_twt_screen_name = twtid.downcase
        Dir.glob(twt_root).each do |path|
            #puts %!get_dir_path_by_twtid(): ath="#{path}"!
            #if twtid == File.basename(path)
            #if twtid.downcase == File.basename(path).downcase
            #if File.basename(path).downcase.start_with?(twtid.downcase)
            if File.basename(path).downcase =~ /^(\w+)\s?/
                id = $1
                if wk_twt_screen_name == id
                    puts %!get_dir_path_by_twtid("#{twtid}"):path="#{path}"!
                    return path
                end
            end
        end
        ""
    end
end