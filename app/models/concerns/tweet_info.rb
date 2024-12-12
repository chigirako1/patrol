# coding: utf-8

module TweetInfo
    extend ActiveSupport::Concern

    def self.get_tweet_info(filename)
        tweet_id = 0
        pic_no = 0
        if filename =~ /(\d+)\s(\d+)\s(\d+\-\d+\-\d+)/
            #puts fn
            tweet_id = $1.to_i
            pic_no = $2.to_i
        elsif filename =~ /(\d+)\s(\d+)\s(\d+)/
            dl_date_str = $1
            begin
                #dl_date = Date.parse(dl_date_str)
            rescue Date::Error => ex

            end
            tweet_id = $2.to_i
            pic_no = $3.to_i
        elsif filename =~ /\d+-\d+-\d+\s+\((\d+)\)/
            tweet_id = $1.to_i
        elsif filename =~ /(\d\d\d+)-(\d+)/
            tweet_id = $1.to_i
            pic_no = $2.to_i
        elsif filename =~ /TID\-unknown\-/
        elsif filename =~ /^[\w\-]{15}\./
            #STDERR.puts %![dbg] #{filename}!
        else
            STDERR.puts %!regex no hit:#{filename}!
        end
        [tweet_id, pic_no]
    end
end

class TweetPicInfo
    attr_accessor :tweet_id, :hash_val, :filesize
    
end