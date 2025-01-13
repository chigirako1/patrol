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

ActiveRecord::Schema[8.0].define(version: 2025_01_12_023555) do
  create_table "artists", force: :cascade do |t|
    t.string "pxvname"
    t.integer "pxvid"
    t.integer "filenum"
    t.datetime "last_dl_datetime"
    t.datetime "last_ul_datetime"
    t.datetime "last_access_datetime"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "furigana"
    t.string "circle_name"
    t.string "comment"
    t.integer "recent_filenum"
    t.string "status"
    t.string "twtid"
    t.integer "njeid"
    t.string "warnings"
    t.string "remarks"
    t.integer "rating"
    t.string "r18"
    t.string "feature"
    t.string "chara"
    t.string "work"
    t.string "altname"
    t.string "oldname"
    t.datetime "earliest_ul_date"
    t.string "pxv_path"
    t.integer "tech_point"
    t.integer "sense_point"
    t.string "good_point"
    t.string "bad_point"
    t.integer "pxv_fav_artwork_id"
    t.string "fetish"
    t.string "obtain_direction"
    t.integer "next_obtain_artwork_id"
    t.string "twt_check"
    t.string "web_url"
    t.datetime "djn_check_date"
    t.integer "zip"
    t.string "append_info"
    t.datetime "twt_checked_date"
    t.datetime "nje_checked_date"
    t.integer "show_count"
    t.string "reverse_status"
    t.integer "latest_artwork_id"
    t.integer "oldest_artwork_id"
    t.datetime "zipped_at"
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string "commenter"
    t.text "body"
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_comments_on_book_id"
  end

  create_table "pxv_artworks", force: :cascade do |t|
    t.integer "artwork_id", null: false
    t.integer "user_id"
    t.string "title"
    t.string "state"
    t.integer "rating"
    t.datetime "release_date"
    t.integer "number_of_pic"
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artwork_id"], name: "index_pxv_artworks_on_artwork_id", unique: true
  end

  create_table "tweets", force: :cascade do |t|
    t.integer "tweet_id", null: false
    t.string "screen_name", null: false
    t.string "status"
    t.integer "rating"
    t.integer "num"
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tweet_id"], name: "index_tweets_on_tweet_id", unique: true
  end

  create_table "twitters", force: :cascade do |t|
    t.string "twtid"
    t.string "twtname"
    t.integer "filenum"
    t.integer "recent_filenum"
    t.datetime "last_dl_datetime"
    t.datetime "earliest_dl_datetime"
    t.datetime "last_access_datetime"
    t.string "comment"
    t.string "remarks"
    t.string "status"
    t.integer "pxvid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "drawing_method"
    t.string "warning"
    t.string "alt_twtid"
    t.string "old_twtid"
    t.integer "rating"
    t.string "r18"
    t.integer "update_frequency"
    t.datetime "last_post_datetime"
    t.string "sensitive"
    t.string "private_account"
    t.string "reverse_status"
    t.string "new_twtid"
    t.string "sub_twtid"
    t.string "main_twtid"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "height"
    t.datetime "access_datetime"
  end

  add_foreign_key "comments", "books"
end
