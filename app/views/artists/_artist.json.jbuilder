json.extract! artist, :id, :pxvname, :pxvid, :filenum, :last_dl_datetime, :last_ul_datetime, :last_access_datetime, :priority, :created_at, :updated_at
json.url artist_url(artist, format: :json)
