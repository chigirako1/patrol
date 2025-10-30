module TweetsHelper
    def url_list_sort_by_pred(url_list)
        url_list.sort_by {|x|
            twt = x[1];
            [
                twt.status||"",
                twt.drawing_method,
                -(twt.rating||0),
                -(twt.prediction),
                twt.last_access_datetime||"",
            ]
        }
    end

    def url_list_sort_by_access(url_list)
        url_list.sort_by {|x|
            twt = x[1];
            [
                twt.status||"",
                twt.drawing_method,
                -(twt.rating||0),
                twt.last_access_datetime||"",
            ]
        }
    end
end
