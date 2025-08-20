# =============================================================================
# 
# =============================================================================
class TwtArtist
    #attr_accessor :twt_id, :twt_name, :path_list, :ctime, :num_of_files
    attr_accessor :twt_id, :twt_name, :path_list, :num_of_files

    def initialize(id, name, path)
        @twt_id = id
        @twt_name = name
        @path_list = []
        @path_list << path

        #@ctime = File.birthtime path
        @ctime = nil
        @num_of_files = nil
    end

    def ctime
        if @ctime == nil
            wpath = twt_pic_path_list[0]
            if wpath
                path = Util::get_public_path(wpath)
                @ctime = File.birthtime(path)
            else
                STDERR.puts %!#{twt_name} @#{twt_id}!
                @ctime = Time.now
            end
        end
        @ctime
    end

    def append_path(path)
        @path_list << path
    end

    def twt_pic_path_list()
        pic_list = []
        path_list.each do |path|
            #puts path
            pic_list << UrlTxtReader::get_path_list(path)
        end
        #pic_list.flatten.sort.reverse
        Twt::sort_by_tweet_id(pic_list.flatten)
    end

    def calc_freq(pic_path_list = nil)
        if pic_path_list
            pl = pic_path_list
        else
            #pl = Twt::sort_by_tweet_id(twt_pic_path_list)
            pl = twt_pic_path_list
        end
        Twt::calc_freq(pl, 30)
    end
    
    def set_filenum
        #if @num_of_files == nil
        #end
        @num_of_files = twt_pic_path_list.size
    end

=begin ???バグでは？
    def twt_view_list(piclist)
        artlist = {}
        piclist.each do |path|
            dirname = File.basename File.dirname(path)
            if dirname =~ /(\d{4}-\d\d-\d\d) \((\d+)\) (.*)/
                date = $1
                artid = $2.to_i
                title = $3
            else
                filename = File.basename path
                if filename =~ /(\d{4}-\d\d-\d\d) \((\d+)\) (.*)/
                    date = $1
                    artid = $2.to_i
                    title = $3
                else
                    puts %!unmatch "#{path}"!
                    next
                end
            end
            
            if artlist.include? artid
                artlist[artid].append(path)
            else
                artlist[artid] = TwtArtwork.new(artid, title, date, path)
            end
        end
        artlist.sort.reverse.to_h
    end

    def twt_view_list_ex
        twt_view_list(twt_pic_path_list)
    end
=end

    def last_post_datetime(pic_path_list)
        Twt::get_time_from_path(pic_path_list[0])
    end

    def get_last_post_tweet_id(pic_path_list)
        get_tweet_id(pic_path_list[0])
    end

    def get_oldest_post_tweet_id(pic_path_list)
        get_tweet_id(pic_path_list[-1])
    end

    private
        def get_tweet_id(path)
            id, _ = Twt::get_tweet_info_from_filepath(path)

            if id == nil
                STDERR.puts %!(#{@twt_id})id="#{id}"!
            end

            id
        end
end

