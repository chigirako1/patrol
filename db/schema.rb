# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_14_220516) do
  create_table "artists", force: :cascade do |t|
    t.string "altname"
    t.string "append_info"
    t.string "bad_point"
    t.string "change_history"
    t.string "chara"
    t.string "circle_name"
    t.string "comment"
    t.datetime "created_at", null: false
    t.integer "del_cnt"
    t.string "del_info"
    t.datetime "djn_check_date"
    t.datetime "earliest_ul_date"
    t.string "feature"
    t.string "fetish"
    t.integer "filenum"
    t.string "furigana"
    t.string "good_point"
    t.datetime "last_access_datetime"
    t.datetime "last_dl_datetime"
    t.datetime "last_ul_datetime"
    t.integer "latest_artwork_id"
    t.integer "next_obtain_artwork_id"
    t.datetime "nje_checked_date"
    t.integer "njeid"
    t.string "obtain_direction"
    t.integer "oldest_artwork_id"
    t.string "oldname"
    t.integer "priority"
    t.integer "pxv_fav_artwork_id"
    t.string "pxv_path"
    t.integer "pxvid"
    t.string "pxvname"
    t.string "r18"
    t.integer "rating"
    t.integer "recent_filenum"
    t.string "remarks"
    t.string "reverse_status"
    t.integer "sense_point"
    t.integer "show_count"
    t.string "status"
    t.integer "tech_point"
    t.string "twt_check"
    t.datetime "twt_checked_date"
    t.string "twtid"
    t.datetime "updated_at", null: false
    t.string "warnings"
    t.string "web_url"
    t.string "work"
    t.integer "zip"
    t.datetime "zipped_at"
    t.index ["pxvid"], name: "index_artists_on_pxvid", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "book_id", null: false
    t.string "commenter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_comments_on_book_id"
  end

  create_table "pxv_artworks", force: :cascade do |t|
    t.integer "artwork_id", null: false
    t.datetime "created_at", null: false
    t.integer "number_of_pic"
    t.integer "rating"
    t.datetime "release_date"
    t.string "remarks"
    t.string "state"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["artwork_id"], name: "index_pxv_artworks_on_artwork_id", unique: true
  end

  create_table "tweets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "num"
    t.integer "rating"
    t.string "remarks"
    t.string "screen_name", null: false
    t.string "status"
    t.integer "tweet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tweet_id"], name: "index_tweets_on_tweet_id", unique: true
  end

  create_table "twitters", id: :integer, default: nil, force: :cascade do |t|
    t.string "alt_twtid"
    t.string "change_history"
    t.string "comment"
    t.datetime "created_at", null: false
    t.string "disp_tab_target"
    t.string "drawing_method"
    t.datetime "earliest_dl_datetime"
    t.integer "fetch_pred_n"
    t.integer "filenum"
    t.integer "filesize"
    t.datetime "last_access_datetime"
    t.datetime "last_dl_datetime"
    t.datetime "last_post_datetime"
    t.integer "latest_tweet_id"
    t.string "main_twtid"
    t.integer "max_interval"
    t.integer "min_interval"
    t.string "new_twtid"
    t.string "old_twtid"
    t.integer "oldest_tweet_id"
    t.string "private_account"
    t.integer "pxvid"
    t.string "r18"
    t.integer "rating"
    t.integer "recent_filenum"
    t.string "remarks"
    t.string "reverse_status"
    t.string "sensitive"
    t.string "status"
    t.string "sub_twtid"
    t.string "twtid"
    t.string "twtname"
    t.integer "update_frequency"
    t.datetime "updated_at", null: false
    t.integer "video_cnt"
    t.string "warning"
    t.datetime "zipped_at"
    t.index ["twtid"], name: "index_twitters_on_twtid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "access_datetime"
    t.integer "age"
    t.datetime "created_at", null: false
    t.integer "height"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "comments", "books"
end
