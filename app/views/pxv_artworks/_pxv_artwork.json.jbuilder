json.extract! pxv_artwork, :id, :artwork_id, :user_id, :title, :state, :rating, :release_date, :number_of_pic, :remarks, :created_at, :updated_at
json.url pxv_artwork_url(pxv_artwork, format: :json)
