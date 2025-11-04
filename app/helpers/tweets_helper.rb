module TweetsHelper
    def url_list_sort_by(url_list_work, sort_type)
        case sort_type
        when TwittersController::SORT_BY::PRED
            url_list_work = url_list_sort_by_pred(url_list_work)
        when params[:sort_by] == TwittersController::SORT_BY::ACCESS
            url_list_work = url_list_sort_by_access(url_list_work)
        else
        end
        url_list_work
    end

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
