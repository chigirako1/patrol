json.extract! twitter, :id, :twtid, :twtname, :filenum, :recent_filenum, :last_dl_datetime, :earliest_dl_datetime, :last_access_datetime, :comment, :remarks, :status, :pxvid, :created_at, :updated_at
json.url twitter_url(twitter, format: :json)
