json.extract! tweet, :id, :tweet_id, :screen_name, :status, :rating, :num, :created_at, :updated_at
json.url tweet_url(tweet, format: :json)
