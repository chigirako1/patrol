class HomeController < ApplicationController
  def index
    @menus = [
      # ----------------------------
      { :label => "twitter", :path => "" },
      { :label => "Twitter[AI] 100", :path => twitters_path(
          target: "AI",
          page_title: "AI 100", rating: 100, hide_within_days: 0, num_of_disp: 10, pred: 5, mode: "patrol", thumbnail: "t"
        ) 
      },
      { :label => "Twitter[AI] 95", :path => twitters_path(target: "AI", page_title: "AI 95", rating: 95, hide_within_days: 1, num_of_disp: 10, pred: 7, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 90", :path => twitters_path(target: "AI", page_title: "AI 90", rating: 90, hide_within_days: 1, num_of_disp: 10, pred: 12, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 85", :path => twitters_path(target: "AI", page_title: "AI 85", rating: 85, hide_within_days: 2, num_of_disp: 10, pred: 15, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 80", :path => twitters_path(target: "AI", page_title: "AI 80", rating: 80, hide_within_days: 2, num_of_disp: 10, pred: 18, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 75", :path => twitters_path(target: "AI", page_title: "AI 75", rating: 75, hide_within_days: 3, num_of_disp: 10, pred: 21, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 70", :path => twitters_path(target: "AI", page_title: "AI 70", rating: 70, hide_within_days: 3, num_of_disp: 10, pred: 24, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 65", :path => twitters_path(target: "AI", page_title: "AI 65", rating: 65, hide_within_days: 4, num_of_disp: 10, pred: 27, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 60", :path => twitters_path(target: "AI", page_title: "AI 60", rating: 60, hide_within_days: 4, num_of_disp: 10, pred: 30, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 45", :path => twitters_path(target: "AI", page_title: "AI 45", rating: 45, hide_within_days: 5, num_of_disp:  3, pred: 33, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 31",
          :path => twitters_path(
            page_title: "AI 31", rating: 31, hide_within_days: 5, num_of_disp: 10, pred: 36, mode: "patrol", thumbnail: "t"
          )
      },
      { :label => "Twitter[AI] ご無沙汰 60",
        :path => twitters_path(
          page_title: "AI ご無沙汰",
          target: "AI",
          sort_by: "access",
          rating: 60,
          hide_within_days: 14,
          num_of_disp: 3,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[AI] ご無沙汰 30",
        :path => twitters_path(
          page_title: "AI ご無沙汰",
          target: "AI",
          sort_by: "access",
          rating: 31,
          hide_within_days: 30,
          num_of_disp: 3,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[パクリ] ご無沙汰",
        :path => twitters_path(
          page_title: "2 ご無沙汰",
          target: "パクリ",
          sort_by: "access",
          rating: 31,
          hide_within_days: 14,
          num_of_disp: 3,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[手描き]", :path => twitters_path(page_title: "手描き", rating: 0, hide_within_days: 14, num_of_disp: 10, pred: 5, mode: "hand", thumbnail: "") },
      { :label => "Twitter all",
          :path => twitters_path(
            page_title: "all", rating: 0, hide_within_days: 0, num_of_disp: 10, pred: 0, mode: "all", thumbnail: ""
          )
      },
      { :label => "Twitter id", :path => twitters_path(page_title: "id", rating: 0, hide_within_days: 0, num_of_disp: 10, pred: 0, mode: "id", thumbnail: "") },
      { :label => "Twitter 未設定", :path => twitters_path(page_title: "未設定", rating: 0, hide_within_days: 14, num_of_disp: 10, pred: 0, mode: "未設定", thumbnail: "") },
      { :label => "Twitter[検索]", :path => twitters_path(page_title: "検索", mode: "search", search_word: "", thumbnail: "") },
      # ----------------------------
      { :label => "pxv", :path => "" },
      { :label => "pxv", :path => artists_path },
      { :label => "pxv AI", :path => artists_path(page_title: "AI", sort_by: "予測▽", group_by: "rating", exclude_ai: "",
            ai: true,
            status: "「長期更新なし」を除外",
            prediction: 5, rating: 6, last_access_datetime: 5, display_number: 3, thumbnail: true) },
      { :label => "pxv AI ご無沙汰",
        :path => artists_path(
          page_title: "ご無沙汰 ai", sort_by: "last_ul_date", group_by: "rating",
          ai: true,
          status: "「長期更新なし」を除外",
          point: 0, prediction: 0, rating: 8, last_access_datetime: 21, display_number: 5, year: 0, thumbnail: true
        )
      },
      #
      { :label => "pxv 高評価9-",
          :path => artists_path(page_title: "高評価9-", 
            sort_by: "point", 
            group_by: "評価+年齢制限", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            rating: 9,
            point: 1,
            prediction: 3,
            last_access_datetime: 7,
            display_number: 5,
            thumbnail: true
          )
      },
      { :label => "pxv 高評価8",
          :path => artists_path(
            page_title: "高評価8", sort_by: "point", group_by: "評価+年齢制限", exclude_ai: "true",
            status: "「長期更新なし」を除外",
            point: 1,
            prediction: 4,
            rating: 8, last_access_datetime: 15, display_number: 3, thumbnail: true
          ) 
      },
      { :label => "pxv 高評価7", :path => artists_path(page_title: "高評価7", sort_by: "point", group_by: "評価+年齢制限", exclude_ai: "true",
          status: "「長期更新なし」を除外",
          point: 1, prediction: 6, rating: 7, last_access_datetime: 20, display_number: 3, year: 2023, thumbnail: true)
      },
      #
      { :label => "pxv ご無沙汰",
            :path => artists_path(
                page_title: "ご無沙汰", sort_by: "last_ul_date", group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                rating: 9,
                point: 0,
                prediction: 2,
                last_access_datetime: 20, display_number: 3, year: 0, thumbnail: true
            )
      },
      { :label => "pxv ご無沙汰2",
            :path => artists_path(
                page_title: "ご無沙汰", sort_by: "last_ul_date", group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                rating: 8,
                point: 0,
                prediction: 3,
                last_access_datetime: 30, display_number: 3, year: 0, thumbnail: true
            )
      },
      #
      { :label => "pxv 未設定",
          :path => artists_path(page_title: "未設定", sort_by: "point", group_by: "filenum", exclude_ai: "true",
            status: "「長期更新なし」を除外",
            point: 1, prediction: 10, rating: 0, last_access_datetime: 0, display_number: 3, year: 2023, thumbnail: true
          )
      },
      { :label => "pxv 更新なし（twtチェック）",
          :path => artists_path(
            page_title: "pxv 更新なし(twtチェック)",
            sort_by: "last_ul_date",
            group_by: "評価+年齢制限", 
            status: "長期更新なし",
            twt: "true",
            rating: 8,
            display_number: 1,
            thumbnail: true,
          )
      },
      # ----------------------------
      { :label => "url file", :path => "" },
      { :label => "twt(dir-all)", :path => artists_twt_index_path },
      { :label => "twt(dir-new)", :path => artists_twt_index_path(dir: "new") },
      { :label => "twt(dir-old)", :path => artists_twt_index_path(dir: "old") },
      { :label => "twt(dir-DB更新 BY FS)", :path => artists_twt_index_path(dir: "update") },
      { :label => "ファイルlist",
          :path => artists_twt_index_path(
            filename: "",
          )
      },
      { :label => "全ファイル",
          :path => artists_twt_index_path(
            filename: "all",
            hide_day: 30,
            target:""
          )
      },
      { :label => "全ファイル unknown pxv only",
          :path => artists_twt_index_path(
            filename: "all",
            hide_day: 90,
            target:"unknown_pxv"
          )
      },
      { :label => "最新ファイル",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 90,
            target:"twt,pxv,known_pxv,unknown_pxv",
          )
      },
      { :label => "最新ファイル unknown pxv only",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 90,
            target:"unknown_pxv",
          )
      },
      # ----------------------------
      { :label => "nje", :path => "" },
      { :label => "nje", :path => artists_nje_index_path },
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

