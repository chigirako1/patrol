class HomeController < ApplicationController
  def index
    @menus = [
      # ----------------------------
      { :label => "twitter", :path => "" },
      { :label => "Twitter[AI] 100", :path => twitters_path(page_title: "AI 100", rating: 100, hide_within_days: 0, num_of_disp: 10, pred: 5, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 95", :path => twitters_path(page_title: "AI 95", rating: 95, hide_within_days: 1, num_of_disp: 10, pred: 7, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 90", :path => twitters_path(page_title: "AI 90", rating: 90, hide_within_days: 1, num_of_disp: 10, pred: 12, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 85", :path => twitters_path(page_title: "AI 85", rating: 85, hide_within_days: 2, num_of_disp: 10, pred: 15, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 80", :path => twitters_path(page_title: "AI 80", rating: 80, hide_within_days: 2, num_of_disp: 10, pred: 18, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 75", :path => twitters_path(page_title: "AI 75", rating: 75, hide_within_days: 3, num_of_disp: 10, pred: 21, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 70", :path => twitters_path(page_title: "AI 70", rating: 70, hide_within_days: 3, num_of_disp: 10, pred: 24, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 60", :path => twitters_path(page_title: "AI 60", rating: 60, hide_within_days: 4, num_of_disp: 10, pred: 28, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 45", :path => twitters_path(page_title: "AI 45", rating: 45, hide_within_days: 4, num_of_disp: 10, pred: 32, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 31", :path => twitters_path(page_title: "AI 31", rating: 31, hide_within_days: 5, num_of_disp: 10, pred: 36, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] ご無沙汰", :path => twitters_path(page_title: "AI ご無沙汰", sort_by: "access", rating: 31, hide_within_days: 14, num_of_disp: 3, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[手描き]", :path => twitters_path(page_title: "手描き", rating: 0, hide_within_days: 14, num_of_disp: 10, pred: 5, mode: "hand", thumbnail: "") },
      { :label => "Twitter all", :path => twitters_path(page_title: "all", rating: 0, hide_within_days: 0, num_of_disp: 10, pred: 0, mode: "all", thumbnail: "") },
      { :label => "Twitter id", :path => twitters_path(page_title: "id", rating: 0, hide_within_days: 0, num_of_disp: 10, pred: 0, mode: "id", thumbnail: "") },
      { :label => "Twitter 未設定", :path => twitters_path(page_title: "未設定", rating: 0, hide_within_days: 14, num_of_disp: 10, pred: 0, mode: "未設定", thumbnail: "") },
      { :label => "Twitter[検索]", :path => twitters_path(page_title: "検索", mode: "search", search_word: "", thumbnail: "") },
      # ----------------------------
      { :label => "url file", :path => "" },
      { :label => "Artist/twt(dir-all)", :path => artists_twt_index_path },
      { :label => "Artist/twt(dir-new)", :path => artists_twt_index_path(dir: "new") },
      { :label => "Artist/twt(dir-old)", :path => artists_twt_index_path(dir: "old") },
      { :label => "Artist/twt(dir-DB更新 BY FS)", :path => artists_twt_index_path(dir: "update") },
      #{ :label => "Artist/twt(file)", :path => artists_twt_index_path(filename: "get illust url_1223", hide_day: 1, hide_target:"") },
      { :label => "Artist/twt(file-latest)", :path => artists_twt_index_path(filename: "latest", hide_day: 30, hide_target:"") },
      { :label => "Artist/twt(file-all)", :path => artists_twt_index_path(filename: "all", hide_day: 30, hide_target:"known") },
      # ----------------------------
      { :label => "pxv", :path => "" },
      { :label => "Artist/pxv", :path => artists_path },
      { :label => "Artist/pxv AI", :path => artists_path(page_title: "AI", sort_by: "予測▽", group_by: "rating", exclude_ai: "",
            ai: true,
            status: "「長期更新なし」を除外",
            prediction: 5, rating: 6, last_access_datetime: 5, display_number: 3, thumbnail: true) },
      { :label => "pxv 更新なし（twtチェック）",
        :path => artists_path(page_title: "pxv 更新なし（twtチェック）", sort_by: "last_ul_date",
        status: "長期更新なし", display_number: 5, thumbnail: true) },
      #
      { :label => "Artist/pxv 高評価10", :path => artists_path(page_title: "高評価10", 
          sort_by: "point", 
          group_by: "評価+年齢制限", 
          exclude_ai: "true",
          point: 1, prediction: 3, rating: 10, last_access_datetime: 5, display_number: 3, thumbnail: true) },
      { :label => "Artist/pxv 高評価9", :path => artists_path(page_title: "高評価9", sort_by: "point", group_by: "評価+年齢制限", exclude_ai: "true",
          point: 1, prediction: 4, rating: 9, last_access_datetime: 10, display_number: 3, thumbnail: true) },
      { :label => "Artist/pxv 高評価8", :path => artists_path(page_title: "高評価8", sort_by: "point", group_by: "評価+年齢制限", exclude_ai: "true",
          point: 1, prediction: 5, rating: 8, last_access_datetime: 15, display_number: 3, thumbnail: true) },
      { :label => "Artist/pxv 高評価7", :path => artists_path(page_title: "高評価7", sort_by: "point", group_by: "評価+年齢制限", exclude_ai: "true",
          point: 1, prediction: 6, rating: 7, last_access_datetime: 20, display_number: 3, year: 2023, thumbnail: true) },
      #
      { :label => "Artist/pxv 未設定",
          :path => artists_path(page_title: "未設定", sort_by: "point", group_by: "filenum", exclude_ai: "true",
            point: 1, prediction: 10, rating: 0, last_access_datetime: 0, display_number: 3, year: 2023, thumbnail: true) },
      #
      { :label => "Artist/pxv ご無沙汰",
            :path => artists_path(
                page_title: "ご無沙汰", sort_by: "last_ul_date", group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                point: 0, prediction: 3, rating: 8, last_access_datetime: 30, display_number: 3, year: 0, thumbnail: true)
      },
      { :label => "Artist/pxv ご無沙汰(ai)", :path => artists_path(page_title: "ご無沙汰 ai", sort_by: "last_ul_date", group_by: "rating",
            ai: true,
            point: 0, prediction: 0, rating: 8, last_access_datetime: 21, display_number: 5, year: 0, thumbnail: true) },
      # ----------------------------
      { :label => "nje", :path => "" },
      { :label => "Artist/nje", :path => artists_nje_index_path },
      # ----------------------------
      { :label => "stats", :path => "" },
      { :label => "Artist::stats", :path => artists_stats_index_path },
      # ----------------------------
      { :label => "", :path => "" },
      { :label => "User", :path => users_path },
      { :label => "Book", :path => books_path },
      { :label => "Help", :path => help_path },
      { :label => "Test", :path => test_path },
    ]
    @message = "This is a test site of Ruby on Rails."
  end

  def help
  end

end

