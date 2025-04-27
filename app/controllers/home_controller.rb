class HomeController < ApplicationController
  PRED_TWT = 8
  PRED_PXV = 5

  NUM_OF_DISP = 5

  def index
    @menus = [
      # ----------------------------
      { :label => "unified", :path => "" },
      { :label => "Twitter [AI] 95 (-5 * 5)",
        :path => twitters_path(
          target: "AI",
          page_title: "AI 95, -5",
          rating: 95,
          #hide_within_days: 0, 
          num_of_disp: 4,
          #pred: 5,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 5,
          num_of_times: 5,
          ex_pxv: false,
          thumbnail: ""
        ) 
      },
      { :label => "Twitter [AI] 89 (-1 * 10)",
        :path => twitters_path(
          target: "AI",
          #page_title: "AI 89",
          rating: 89,
          #hide_within_days: 0, 
          num_of_disp: 3,
          #pred: 5,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 1,
          num_of_times: 10,
          ex_pxv: false,
          thumbnail: ""
        ) 
      },
      { :label => "Twitter [AI] 89 (-1 * 6)",
        :path => twitters_path(
          target: "AI",
          page_title: "AI 89 (-1 * 6)",
          rating: 89,
          #hide_within_days: 0, 
          num_of_disp: 4,
          #pred: 5,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 1,
          num_of_times: 6,
          ex_pxv: false,
          thumbnail: ""
        ) 
      },
      { :label => "Twitter [AI] 85",
        :path => twitters_path(
          target: "AI",
          page_title: "AI 85",
          rating: 85,
          #hide_within_days: 0, 
          num_of_disp: 5,
          #pred: 5,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 1,
          num_of_times: 5,
          ex_pxv: false,
          thumbnail: ""
        ) 
      },
      { :label => "Twitter [AI] 80",
        :path => twitters_path(
          target: "AI",
          page_title: "AI 80",
          rating: 80,
          #hide_within_days: 0, 
          num_of_disp: 5,
          #pred: 5,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 5,
          num_of_times: 2,
          ex_pxv: false,
          thumbnail: ""
        ) 
      },
      { :label => "Twitter [手描き] 95 (-5 * 4)",
        :path => twitters_path(
          target: "手描き",
          #page_title: "手描き 95",
          rating: 95,
          hide_within_days: 15,
          num_of_disp: 5,
          #pred: 5,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 5,
          num_of_times: 4,
          ex_pxv: true,#false,
          thumbnail: ""
        ) 
      },
      { :label => "Twitter [手描き] 95",
        :path => twitters_path(
          target: "手描き",
          page_title: "手描き 95",
          rating: 95,
          hide_within_days: 15,
          num_of_disp: 3,
          #pred: 5,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 1,
          num_of_times: 10,
          ex_pxv: true,#false,
          thumbnail: ""
        ) 
      },
      { :label => "Twitter [手描き] 85",
        :path => twitters_path(
          target: "手描き",
          page_title: "手描き 85",
          rating: 85,
          rating_lt: 88,
          hide_within_days: 15,
          num_of_disp: 3,
          pred: 10,
          #force_disp_day: 10,
          mode: TwittersController::ModeEnum::ALL_IN_ONE,
          step: 3,
          num_of_times: 3,
          ex_pxv: true,#false,
          thumbnail: ""
        ) 
      },
      # ----------------------------
      { :label => "-", :path => "" },
      { :label => "pxv [AI] 95, -5 * 3",
          :path => artists_path(
            file: ArtistsController::MethodEnum::ALL_IN_ONE,
            page_title: "pxv [AI] all in one 95",
            exclude_ai: "",
            ai: true,
            status: "「長期更新なし」を除外",
            rating: 95,
            step: 5,
            num_of_times: 3,
            display_number: 5,
            last_access_datetime: 7,
            thumbnail: false,
          )
      },
      { :label => "pxv [AI] 100",
          :path => artists_path(
            file: ArtistsController::MethodEnum::ALL_IN_ONE,
            page_title: "pxv all in one 100 AI",
            exclude_ai: "",
            ai: true,
            status: "「長期更新なし」を除外",
            #prediction: 6,
            rating: 100,#90,
            step: 2,
            num_of_times: 5,
            display_number: 4,
            last_access_datetime: 3,
            thumbnail: false,
          )
      },
      { :label => "pxv [手描き] 95 (-5 * 4)",
          :path => artists_path(
            file: ArtistsController::MethodEnum::ALL_IN_ONE,
            page_title: "pxv all in one 95 手描き",
            exclude_ai: "true",
            ai: false,
            status: "「長期更新なし」を除外",
            rating: 95,
            display_number: 5,
            last_access_datetime: 7,
            step: 5,
            num_of_times: 4,
            thumbnail: false,
          )
      },
      { :label => "pxv [手描き] 85",
          :path => artists_path(
            file: ArtistsController::MethodEnum::ALL_IN_ONE,
            page_title: "pxv all in one 85 手描き",
            exclude_ai: "true",
            ai: false,
            status: "「長期更新なし」を除外",
            rating: 85,
            display_number: 4,
            last_access_datetime: 7,
            step: 1,
            num_of_times: 5,
            thumbnail: false,
          )
      },
      { :label => "pxv ご無沙汰",
          :path => artists_path(
            page_title: "pxv ご無沙汰",
            #exclude_ai: "true",
            #ai: false,
            sort_by: ArtistsController::SORT_TYPE::SORT_RATING,
            group_by: ArtistsController::GROUP_TYPE::GROUP_ACCESS_OLD_TO_NEW,
            status: "「長期更新なし」を除外",
            prediction: 11,
            rating: 80,
            display_number: 5,
            last_access_datetime: 60,
            thumbnail: false,
          )
      },
      # ----------------------------
      { :label => "-", :path => "" },
      { :label => "Twitter 未設定 予測数順",
        :path => twitters_path(
          page_title: "未設定 id",
          mode: "id",
          sort_by: "pred",
          no_pxv: "t",
          rating: 0,
          hide_within_days: -30,
          num_of_disp: NUM_OF_DISP,
          pred: 0,
          target: "",
          thumbnail: "t"
        )
      },
      { :label => "pxv 未設定 更新数[多]予測",
          :path => artists_path(
            page_title: "pxv 未設定 更新数[多]予測", 
            #sort_by: "id",
            sort_by: "予測▽",
            #group_by: "",
            #exclude_ai: "true",
            #status: "「長期更新なし」を除外",
            #point: 1, 
            prediction: 13, 
            #recent_filenum: 5,
            rating: 0, 
            #last_access_datetime: -100,#7,
            created_at: 120,
            display_number: 7,
            #year: 2023, 
            thumbnail: true
          )
      },
      # ----------------------------
      { :label => "pxv url list",
          :path => artists_path(
            page_title: "pxv url list", 
            file: ArtistsController::MethodEnum::URL_LIST_PXV_ONLY_LATEST,#"urllist-pxv-only(latest)",
            sort_by: "予測▽", 
            group_by: "status/rating",
            #exclude_ai: "true",
            #status: "「長期更新なし」を除外",
            #point: 1, 
            #prediction: 13, 
            #recent_filenum: 5,
            #rating: 0, 
            last_access_datetime: 15,
            display_number: 22,
            #year: 2023,
            thumbnail: false
          )
      },
      { :label => "pxv url list txt",
          :path => artists_path(
            page_title: "pxv url list tx", 
            file: ArtistsController::MethodEnum::URL_LIST,
            filename: "250421",
            sort_by: "予測▽", 
            group_by: "status/rating",
            #exclude_ai: "true",
            #status: "「長期更新なし」を除外",
            #point: 1, 
            #prediction: 13, 
            #recent_filenum: 5,
            #rating: 0, 
            last_access_datetime: 15,
            display_number: 22,
            #year: 2023,
            thumbnail: false
          )
      },
      # ----------------------------
      { :label => "twitter AI", :path => "" },
      { :label => "Twitter[AI] 90", :path => twitters_path(
          target: "AI", page_title: "AI 90", rating: 90, 
          hide_within_days: 2,
          num_of_disp: NUM_OF_DISP,
          pred: 13, 
          force_disp_day: 18,
          mode: "patrol", thumbnail: "t"
        )
      },
      { :label => "Twitter[AI] 75", :path => twitters_path(target: "AI", page_title: "AI 75", rating: 75, hide_within_days: 7, num_of_disp: NUM_OF_DISP,pred: 21, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 70", :path => twitters_path(target: "AI", page_title: "AI 70", rating: 70, hide_within_days: 14, num_of_disp: NUM_OF_DISP,pred: 24, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 65", :path => twitters_path(target: "AI", page_title: "AI 65", rating: 65, hide_within_days: 14, num_of_disp: NUM_OF_DISP,pred: 27, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 60", :path => twitters_path(target: "AI", page_title: "AI 60", rating: 60, hide_within_days: 14, num_of_disp: NUM_OF_DISP,pred: 30, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 55", :path => twitters_path(target: "AI", page_title: "AI 55", rating: 55, hide_within_days: 18, num_of_disp: NUM_OF_DISP,pred: 33, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 50", :path => twitters_path(target: "AI", page_title: "AI 50", rating: 50, hide_within_days: 20, num_of_disp: NUM_OF_DISP,pred: 34, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 45", :path => twitters_path(target: "AI", page_title: "AI 45", rating: 45, hide_within_days: 22, num_of_disp: NUM_OF_DISP,pred: 36, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 31",
          :path => twitters_path(
            page_title: "AI 31", rating: 31, hide_within_days: 26, num_of_disp: 2, pred: 36, mode: "patrol", thumbnail: "t"
          )
      },
      { :label => "-", :path => "" },
      { :label => "Twitter[AI] ご無沙汰 85",
        :path => twitters_path(
          page_title: "AI ご無沙汰 85",
          target: "AI",
          sort_by: "access",
          rating: 85,
          hide_within_days: 21,
          num_of_disp: NUM_OF_DISP,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[AI] ご無沙汰 75",
        :path => twitters_path(
          page_title: "AI ご無沙汰 75",
          target: "AI",
          sort_by: "access",
          rating: 75,
          hide_within_days: 27,
          num_of_disp: NUM_OF_DISP,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[AI] ご無沙汰 60",
        :path => twitters_path(
          page_title: "AI ご無沙汰 60",
          target: "AI",
          sort_by: "access",
          rating: 60,
          hide_within_days: 40,
          num_of_disp: 2,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[AI] ご無沙汰 50",
        :path => twitters_path(
          page_title: "AI ご無沙汰 50",
          target: "AI",
          sort_by: "access",
          rating: 50,
          hide_within_days: 45,
          num_of_disp: 2,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      # ----------------------------
      { :label => "-", :path => "" },
      { :label => "Twitter[AI] 更新なし？ 85",
        :path => twitters_path(
          page_title: "AI 更新なし？ 85",
          target: "AI",
          sort_by: "access",
          rating: 85,
          hide_within_days: 60,
          num_of_disp: 3,
          mode: "patrol2",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[AI] 更新なし？ 75",
        :path => twitters_path(
          page_title: "AI 更新なし？ 75",
          target: "AI",
          sort_by: "access",
          rating: 75,
          hide_within_days: 90,
          num_of_disp: 2,
          mode: "patrol2",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[AI] 凍結etc... 75",
        :path => twitters_path(
          page_title: "AI 凍結etc... 75",
          target: "AI",
          sort_by: "access",
          rating: 75,
          #hide_within_days: 30,
          num_of_disp: 6,
          mode: "patrol3",
          thumbnail: "t",
        )
      },
      # ----------------------------
      { :label => "twitter ", :path => "" },
      { :label => "Twitter[パクリ] ご無沙汰 1",
        :path => twitters_path(
          page_title: "ご無沙汰 1",
          target: "パクリ",
          sort_by: "access",
          rating: 80,
          hide_within_days: 5,
          num_of_disp: 3,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "Twitter[パクリ] ご無沙汰 2",
        :path => twitters_path(
          page_title: "ご無沙汰 2",
          target: "パクリ",
          sort_by: "access",
          rating: 31,
          hide_within_days: 14,
          num_of_disp: 3,
          mode: "patrol",
          thumbnail: "t",
        )
      },
      { :label => "-", :path => "" },
      { :label => "Twitter[手描き] 100",
        :path => twitters_path(
          page_title: "手描き 100", 
          rating: 100,
          hide_within_days: 45, 
          num_of_disp: NUM_OF_DISP,
          pred: 3,
          mode: "hand", 
          sort_by: "access",
          thumbnail: "t"
        )
      },
      { :label => "Twitter[手描き] 95",
        :path => twitters_path(
          page_title: "手描き 95", 
          rating: 95,
          hide_within_days: 45, 
          num_of_disp: 4,
          pred: 5,
          mode: "hand", 
          sort_by: "access",
          thumbnail: "t"
        )
      },
      { :label => "Twitter[手描き] 90",
        :path => twitters_path(
          page_title: "手描き 90", 
          rating: 90,
          hide_within_days: 60, 
          num_of_disp: 4,
          pred: 5,
          mode: "hand", 
          sort_by: "access",
          thumbnail: "t"
        )
      },
      { :label => "Twitter[手描き] 85",
        :path => twitters_path(
          page_title: "手描き 85",
          rating_lt: 90,
          rating: 85,
          hide_within_days: 75,
          num_of_disp: NUM_OF_DISP,
          pred: 5,
          ex_pxv: true,#false,
          mode: "hand",
          sort_by: "access",
          thumbnail: "t"
        )
      },
      { :label => "Twitter[手描き] 80",
        :path => twitters_path(
          page_title: "手描き 80",
          rating: 80,
          hide_within_days: 90,
          num_of_disp: NUM_OF_DISP,
          pred: 5,
          mode: "hand", 
          sort_by: "access",
          thumbnail: "t"
        )
      },
      { :label => "-", :path => "" },
      { :label => "Twitter all",
          :path => twitters_path(
            page_title: "all",
            mode: "all",
            rating: 0,
            hide_within_days: 0,
            num_of_disp: 10,
            pred: 0,
            thumbnail: ""
          )
      },
      { :label => "-", :path => "" },
      { :label => "Twitter ファイル 95",
          :path => twitters_path(
            page_title: "ファイル 95",
            mode: "file",
            rating: 95,
            hide_within_days: 30,
            num_of_disp: 8,
            pred: 2,
            no_pxv: "t",
            thumbnail: "t"
          )
      },
      { :label => "Twitter ファイル 90",
          :path => twitters_path(
            page_title: "ファイル 90",
            mode: "file",
            rating: 90,
            hide_within_days: 40,
            num_of_disp: 7,
            pred: 3,
            no_pxv: "t",
            thumbnail: "t"
          )
      },
      { :label => "Twitter ファイル 80",
          :path => twitters_path(
            page_title: "ファイル 80",
            mode: "file",
            rating: 80,
            hide_within_days: 45,
            num_of_disp: NUM_OF_DISP,
            pred: 4,
            no_pxv: "t",
            thumbnail: "t"
          )
      },
      { :label => "Twitter ファイル 60",
          :path => twitters_path(
            page_title: "ファイル 60",
            mode: "file",
            rating: 60,
            hide_within_days: 60,
            num_of_disp: NUM_OF_DISP,
            pred: 5,
            no_pxv: "t",
            thumbnail: "t"
          )
      },
      # ----------------------------
      { :label => "-", :path => "" },
      { :label => "Twitter 未設定 id",
        :path => twitters_path(
          page_title: "未設定 id",
          mode: "id",
          sort_by: "id",
          no_pxv: "t",
          rating: 0,
          hide_within_days: 60,#30,
          num_of_disp: 10,
          pred: 0,
          target: "",
          thumbnail: "t"
        )
      },
      { :label => "Twitter 未設定",
        :path => twitters_path(
          page_title: "未設定", 
          mode: "未設定", 
          rating: 0, 
          hide_within_days: 60,#30, 
          num_of_disp: NUM_OF_DISP,
          pred: 0, 
          thumbnail: "t"
        )
      },
      { :label => "Twitter 凍結/存在しない/etc...",
        :path => twitters_path(
          page_title: "凍結/存在しない/etc...", 
          #rating: 0, 
          hide_within_days: 21, 
          num_of_disp: NUM_OF_DISP,
          #pred: 0,
          mode: "更新不可", 
          thumbnail: "t"
        )
      },
      { :label => "Twitter 存在しない",
        :path => twitters_path(
          page_title: "存在しない",
          #rating: 0, 
          hide_within_days: 21, 
          num_of_disp: NUM_OF_DISP,
          #pred: 0,
          mode: "存在しない",
          thumbnail: "t"
        )
      },
      { :label => "Twitter 同一",
        :path => twitters_path(
          page_title: "同一", 
          num_of_disp: 10,
          mode: "同一", 
          thumbnail: "t"
        )
      },
      { :label => "Twitter xx",
        :path => twitters_path(
          page_title: "xx", 
          num_of_disp: NUM_OF_DISP,
          mode: TwittersController::ModeEnum::UNASSOCIATED_TWT_ACNT,
          thumbnail: "t"
        )
      },
      { :label => "Twitter[検索]", :path => twitters_path(page_title: "検索", mode: "search", search_word: "", thumbnail: "") },
      { :label => "-", :path => "" },
      { :label => "Twitter pxv更新なし",
        :path => twitters_path(
          page_title: "Twitter pxv更新なし", 
          rating: 90,
          hide_within_days: 30, 
          num_of_disp: 3,
          pred: 5,
          mode: "no_pxv", 
          sort_by: "access",
          thumbnail: "t"
        )
      },
      # ----------------------------
      { :label => "pxv AI", :path => "" },
      { :label => "pxv AI 100",
        :path => artists_path(
          page_title: "AI 100",
          sort_by: "予測▽",
          group_by: "評価+年齢制限",
          exclude_ai: "",
          ai: true,
          status: "「長期更新なし」を除外",
          prediction: 6,
          rating: 100,
          last_access_datetime: 5,
          display_number: 8,
          thumbnail: true
        )
      },
      { :label => "pxv AI 95",
        :path => artists_path(
          page_title: "AI 95",
          sort_by: "予測▽",
          group_by: "評価+年齢制限",
          exclude_ai: "",
          ai: true,
          status: "「長期更新なし」を除外",
          prediction: 7,
          rating: 95,
          last_access_datetime: 6,
          display_number: 7,
          thumbnail: true
        )
      },
      { :label => "pxv AI 90",
        :path => artists_path(
          page_title: "AI 90",
          sort_by: "予測▽",
          group_by: "評価+年齢制限",
          exclude_ai: "",
          ai: true,
          status: "「長期更新なし」を除外",
          prediction: 8,
          rating: 90,
          last_access_datetime: 7,
          display_number: 7,
          thumbnail: true
        )
      },
      { :label => "pxv AI 85",
        :path => artists_path(
          page_title: "AI 85",
          sort_by: "予測▽",
          group_by: "評価+年齢制限",
          exclude_ai: "",
          ai: true,
          status: "「長期更新なし」を除外",
          prediction: 9,
          rating: 85,
          last_access_datetime: 8,
          display_number: 6,
          thumbnail: true
        )
      },
      { :label => "pxv AI 80",
        :path => artists_path(
          page_title: "AI 80",
          sort_by: "予測▽",
          group_by: "評価+年齢制限",
          exclude_ai: "",
          ai: true,
          status: "「長期更新なし」を除外",
          prediction: 10,
          rating: 80,
          last_access_datetime: 9,
          display_number: 6,
          thumbnail: true
        )
      },
      { :label => "pxv AI 75",
        :path => artists_path(
            page_title: "AI 75",
            sort_by: "予測▽",
            group_by: "評価+年齢制限",
            exclude_ai: "",
            ai: true,
            status: "「長期更新なし」を除外",
            prediction: 12,
            rating: 75,
            last_access_datetime: 14,
            display_number: 5,
            thumbnail: true
          )
      },
      { :label => "pxv AI 70",
        :path => artists_path(
            page_title: "AI 70",
            sort_by: "予測▽",
            group_by: "評価+年齢制限",
            exclude_ai: "",
            ai: true,
            status: "「長期更新なし」を除外",
            prediction: 14,
            rating: 70,
            last_access_datetime: 15,
            display_number: 5,
            thumbnail: true
          )
      },
      { :label => "pxv AI 60",
        :path => artists_path(
            page_title: "AI 60",
            sort_by: "予測▽",
            group_by: "評価+年齢制限",
            exclude_ai: "",
            ai: true,
            status: "「長期更新なし」を除外",
            prediction: 18,
            rating: 60,
            last_access_datetime: 21,
            display_number: 4,
            thumbnail: true
          )
      },
      { :label => "pxv AI ご無沙汰 100",
        :path => artists_path(
          page_title: "ご無沙汰 ai 100", 
          sort_by: "access_date_X_last_ul_datetime", 
          group_by: "評価+年齢制限",
          ai: true,
          status: "「長期更新なし」を除外",
          point: 0, 
          prediction: 0, 
          rating: 100,
          last_access_datetime: 20,
          display_number: 3, 
          year: 0, 
          thumbnail: true
        )
      },
      { :label => "pxv AI ご無沙汰 95",
        :path => artists_path(
          page_title: "ご無沙汰 ai 95", 
          sort_by: "access_date_X_last_ul_datetime", 
          group_by: "評価+年齢制限",
          ai: true,
          status: "「長期更新なし」を除外",
          point: 0, 
          prediction: 0, 
          rating: 95,
          last_access_datetime: 40, 
          display_number: 3, 
          year: 0, 
          thumbnail: true
        )
      },
      { :label => "pxv AI ご無沙汰 90",
        :path => artists_path(
          page_title: "ご無沙汰 ai 90", 
          sort_by: "access_date_X_last_ul_datetime", 
          group_by: "評価+年齢制限",
          ai: true,
          status: "「長期更新なし」を除外",
          point: 0, 
          prediction: 0, 
          rating: 90,
          last_access_datetime: 60, 
          display_number: 3, 
          year: 0, 
          thumbnail: true
        )
      },
      { :label => "pxv AI ご無沙汰 80 R18",
        :path => artists_path(
          page_title: "ご無沙汰 ai 80/R18", 
          sort_by: "access_date_X_last_ul_datetime", 
          group_by: "評価+年齢制限",
          ai: true,
          status: "「長期更新なし」を除外",
          point: 0, 
          prediction: 0, 
          rating: 80,
          r18: "R18",
          last_access_datetime: 60, 
          display_number: 3, 
          year: 0, 
          thumbnail: true
        )
      },
      { :label => "-", :path => "" },
      { :label => "pxv 未設定 AIチェック",
          :path => artists_path(
            page_title: "未設定 AIチェック", 
            sort_by: "id", 
            #group_by: "", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            #point: 1, 
            prediction: 5,
            recent_filenum: 9,
            rating: 0,
            last_access_datetime: 7,
            display_number: 7,
            #year: 2023, 
            thumbnail: true
          )
      },
      { :label => "pxv 評価未設定 AI設定済み",
          :path => artists_path(
            page_title: "評価未設定 AI設定済み", 
            sort_by: "id", 
            #group_by: "", 
            ai: true,
            #status: "「長期更新なし」を除外",
            #point: 1, 
            #prediction: 0, 
            #recent_filenum: 10,
            rating: 0, 
            #last_access_datetime: 0, 
            display_number: 10, 
            #year: 2023, 
            thumbnail: true
          )
      },
      { :label => "-", :path => "" },
      { :label => "pxv AI 長期更新なし さかのぼり用",
        :path => artists_path(
          page_title: "長期更新なし ai さかのぼり用", 
          sort_by: "last_ul_date", 
          group_by: "rating",
          ai: true,
          status: "長期更新なし",
          reverse_status: "「さかのぼり済」を除く",
          #point: 0, 
          #prediction: 0, 
          rating: 85,
          last_access_datetime: 45,
          display_number: 2, 
          #year: 0, 
          thumbnail: false
        )
      },
      { :label => "pxv AI  さかのぼり用 投稿日古いやつ",
        :path => artists_path(
          page_title: " ai さかのぼり用 投稿日古いやつ", 
          sort_by: "last_ul_date", 
          group_by: "rating",
          ai: true,
          #status: "長期更新なし",
          reverse_status: "「さかのぼり済」を除く",
          #point: 0, 
          #prediction: 0, 
          rating: 85,
          last_access_datetime: 45,
          last_ul_datetime: 90,
          display_number: 2, 
          #year: 0, 
          thumbnail: false
        )
      },
      { :label => "pxv AI 停止（再開チェック用）",
        :path => artists_path(
          page_title: "pxv AI 停止（再開チェック用）", 
          sort_by: "last_ul_date", 
          group_by: "rating",
          ai: true,
          status: "停止",
          #reverse_status: "「さかのぼり済」を除く",
          #point: 0, 
          #prediction: 0, 
          rating: 80,
          last_access_datetime: 60,
          display_number: 3, 
          #year: 0, 
          thumbnail: false
        )
      },
      # ----------------------------
      { :label => "pxv", :path => "" },
      #
      { :label => "pxv", :path => artists_path },
      { :label => "-", :path => "" },
      { :label => "pxv 高評価95",
          :path => artists_path(page_title: "高評価95",
            sort_by: "予測▽", 
            group_by: "評価+年齢制限", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            rating: 95,
            #point: 1,
            prediction: 4,
            force_disp_day: 45,
            last_access_datetime: 15,
            display_number: 7,
            thumbnail: true
          )
      },
      { :label => "pxv 高評価90",
          :path => artists_path(page_title: "高評価90", 
            sort_by: "予測▽", 
            group_by: "評価+年齢制限", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            rating: 90,
            #point: 1,
            prediction: 5,
            force_disp_day: 60,
            last_access_datetime: 30,
            display_number: 6,
            thumbnail: true
          )
      },
      { :label => "pxv 高評価85 R18",
          :path => artists_path(
            page_title: "高評価85 R18", 
            sort_by: "予測▽", #"last_ul_date",#
            group_by: "last_ul_datetime_ym旧→新",#"last_ul_datetime_ym",#"評価+年齢制限", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            #point: 1,
            prediction: 8,
            force_disp_day: 90,
            rating: 85,
            r18: "R18",
            last_access_datetime: 30,
            display_number: 5, 
            thumbnail: true
          ) 
      },
      { :label => "pxv 高評価85",
          :path => artists_path(
            page_title: "高評価85", 
            sort_by: "予測▽", 
            group_by: "評価+年齢制限", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            #point: 1,
            prediction: 8,
            force_disp_day: 90,
            rating: 85, 
            last_access_datetime: 30, 
            display_number: 5, 
            thumbnail: true
          ) 
      },
      { :label => "pxv 高評価80 R18",
          :path => artists_path(
            page_title: "高評価80 R18", 
            sort_by: "予測▽", 
            group_by: "filenum", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            #point: 1,
            prediction: 8,
            force_disp_day: 90,
            rating: 80,
            r18: "R18",
            last_access_datetime: 30, 
            display_number: 4, 
            thumbnail: true
          ) 
      },
      { :label => "pxv 高評価80",
          :path => artists_path(
            page_title: "高評価80", 
            sort_by: "予測▽", 
            group_by: "評価+年齢制限", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            #point: 1,
            prediction: 6,
            force_disp_day: 90,
            rating: 80, 
            last_access_datetime: 30, 
            display_number: 4, 
            thumbnail: true
          ) 
      },
      { :label => "pxv 高評価70", 
        :path => artists_path(
          page_title: "高評価70",
          sort_by: "予測▽", 
          group_by: "評価+年齢制限", 
          exclude_ai: "true",
          status: "「長期更新なし」を除外",
          #point: 1,
          prediction: 15,
          force_disp_day: 150,
          rating: 70,
          last_access_datetime: 60,
          display_number: 4,
          #year: 2023, 
          thumbnail: true
        )
      },
      { :label => "-", :path => "" },
      #
=begin
      { :label => "pxv 10 日数経過+予測数",
            :path => artists_path(
                page_title: "10 日数経過+予測数",
                sort_by: "予測▽",
                group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                rating: 100,
                point: 0,
                prediction: 1,
                last_access_datetime: 20,
                display_number: 10,
                year: 0,
                thumbnail: true
            )
      },
=end
      { :label => "pxv 90 日数経過+予測数",
            :path => artists_path(
                page_title: "90 日数経過+予測数",
                sort_by: "予測▽",
                group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                rating: 90,
                point: 0,
                prediction: 3,
                last_access_datetime: 30,
                display_number: 3,
                year: 0,
                thumbnail: true
            )
      },
      { :label => "pxv 80 日数経過+予測数",
            :path => artists_path(
                page_title: "80 日数経過+予測数", 
                sort_by: "予測▽", 
                group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                rating: 80,
                point: 0,
                prediction: 5,
                last_access_datetime: 45,
                display_number: 2, 
                year: 0, 
                thumbnail: true
            )
      },
      #
      { :label => "-", :path => "" },
      { :label => "pxv ご無沙汰 75日 70",
            :path => artists_path(
                page_title: "ご無沙汰 75日 70", 
                sort_by: "last_ul_date", 
                group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                rating: 70,
                point: 0,
                #prediction: 0,
                last_access_datetime: 75, 
                display_number: 3, 
                year: 0, 
                thumbnail: true
            )
      },
      { :label => "pxv ご無沙汰 90日 60",
            :path => artists_path(
                page_title: "ご無沙汰 90日 60", 
                sort_by: "予測▽", 
                group_by: "評価+年齢制限",
                exclude_ai: true,
                status: "「長期更新なし」を除外",
                rating: 60,
                point: 0,
                #prediction: 0, #
                last_access_datetime: 90,
                display_number: 3,
                year: 0,
                thumbnail: true
            )
      },
      #
      { :label => "-", :path => "" },
      { :label => "pxv 未設定 予測",
          :path => artists_path(
            page_title: "未設定 予測", 
            sort_by: "予測▽", 
            group_by: "last_ul_datetime_y", 
            exclude_ai: "true",
            status: "「長期更新なし」を除外",
            #point: 1, 
            prediction: -10, 
            rating: 0, 
            last_access_datetime: 7, 
            display_number: 1, 
            #year: 2023, 
            thumbnail: true
          )
      },
      { :label => "pxv 更新なし（twtチェック）",
          :path => artists_path(
            page_title: "pxv 更新なし(twtチェック)",
            sort_by: "last_ul_date",
            group_by: "評価+年齢制限", 
            status: "長期更新なし",
            twt: "true",
            rating: 85,
            display_number: 3,
            last_access_datetime: 90, 
            thumbnail: true,
          )
      },
      { :label => "pxv 更新なし（twt有無チェック）",
          :path => artists_path(
            file: ArtistsController::MethodEnum::TWT_DB_UNREGISTERED_TWT_ID, #"twt未登録twt id",
            page_title: "pxv 更新なし(twt有無チェック)",
            #sort_by: "last_ul_date",
            group_by: "評価+年齢制限", 
            status: "長期更新なし",
            #twt: "false",
            rating: 80,
            display_number: 3,
            last_access_datetime: 0, 
            thumbnail: true,
          )
      },
      { :label => "pxv 更新なし さかのぼり",
          :path => artists_path(
            page_title: "pxv 更新なし さかのぼり",
            sort_by: "last_ul_date",
            group_by: "評価+年齢制限", 
            status: "長期更新なし",
            reverse_status: "さかのぼり中",
            rating: 90,
            display_number: 5,
            last_access_datetime: 30, 
            thumbnail: true,
          )
      },
      # ----------------------------
      { :label => "url file", :path => "" },
      { :label => "twt(dir-all)",
        :path => artists_twt_index_path(
          target:"twt"
        )
      },
      { :label => "twt(dir-new)", :path => artists_twt_index_path(dir: "new", target:"twt") },
      { :label => "twt(dir-old)", :path => artists_twt_index_path(dir: "old", target:"twt") },
      { :label => "twt(dir-DB更新 BY FS)", :path => artists_twt_index_path(dir: "update") },#, target:"twt") },
      { :label => "twt(重複ファイル登録)", :path => artists_twt_index_path(dir: "register_dup_files") },
      { :label => "twt(dir-new-list)",
        :path => artists_twt_index_path(dir: "new-list")
      },
      #
      { :label => "-", :path => "" },
      { :label => "ファイルlist",
          :path => artists_twt_index_path(
            filename: "",
          )
      },
      { :label => "pxv artwork id リスト",
          :path => artists_twt_index_path(
            filename: "all",
            target: ArtistsController::FileTarget::PXV_ARTWORK_LIST
          )
      },
      { :label => "-", :path => "" },
      { :label => "最新ファイル all",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 30,
            pred: 5,
            target:"twt,twt既知,twt未知,known_pxv,unknown_pxv",
          )
      },
      { :label => "最新ファイル 実験pxv",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 30,
            target: ArtistsController::FileTarget::PXV_EXPERIMENT
          )
      },
      { :label => "最新ファイル 実験twt",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 30,
            target: ArtistsController::FileTarget::TWT_EXPERIMENT
          )
      },
      { :label => "最新ファイル twt",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 30,
            force_disp_day: 90,
            pred: PRED_TWT,
            target:"twt,twt既知,twt未知",
          )
      },
      { :label => "最新ファイル 既知twt",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 30,
            force_disp_day: 90,
            pred: PRED_TWT,
            target:"twt,twt既知",
          )
      },
      { :label => "最新ファイル twt未知",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 30,
            #force_disp_day: 90,
            #pred: 5,
            target:"twt,twt未知",
          )
      },
      { :label => "最新ファイル 既知 pxv",
          :path => artists_twt_index_path(
            filename: "latest",
            hide_day: 30,
            force_disp_day: 90,
            pred: PRED_PXV,
            target:"known_pxv",
          )
      },
      { :label => "最新ファイル 未登録 pxv",
          :path => artists_twt_index_path(
            filename: "latest",
            #hide_day: 30,
            target: ArtistsController::FileTarget::PXV_UNKNOWN_ONLY,
          )
      },
      { :label => "-", :path => "" },
      { :label => "最新3ファイル all",
          :path => artists_twt_index_path(
            filename: "latest 3",
            hide_day: 30,
            pred: 8,
            target:"twt,twt既知,twt未知,known_pxv,unknown_pxv",
          )
      },
      { :label => "最新3ファイル twt",
          :path => artists_twt_index_path(
            filename: "latest 3",
            hide_day: 30,
            force_disp_day: 90,
            pred: PRED_TWT,
            target:"twt,twt既知,twt未知"
          )
      },
      { :label => "最新3ファイル 既知twt",
          :path => artists_twt_index_path(
            filename: "latest 3",
            hide_day: 30,
            force_disp_day: 90,
            pred: PRED_TWT,
            target:"twt,twt既知",
          )
      },
      { :label => "最新3ファイル twt未知",
          :path => artists_twt_index_path(
            filename: "latest 3",
            #hide_day: 15,
            force_disp_day: 90,
            #pred: 5,
            target:"twt,twt未知",
          )
      },
      { :label => "最新3ファイル 既知pxv",
          :path => artists_twt_index_path(
            filename: "latest 3",
            hide_day: 30,
            force_disp_day: 90,
            pred: PRED_PXV,
            target:"known_pxv"
          )
      },
      { :label => "最新3ファイル 未登録pxv",
          :path => artists_twt_index_path(
            filename: "latest 3",
            #hide_day: 30,
            target: ArtistsController::FileTarget::PXV_UNKNOWN_ONLY,
          )
      },
      # -----------
      { :label => "-", :path => "" },
      { :label => "全ファイル twt",
          :path => artists_twt_index_path(
            filename: "all",
            hide_day: 15,
            force_disp_day: 90,
            pred: PRED_TWT,
            target:"twt,twt既知,twt未知"
          )
      },
      { :label => "全ファイル twt既知",
          :path => artists_twt_index_path(
            filename: "all",
            hide_day: 15,
            force_disp_day: 90,
            pred: PRED_TWT,
            target:"twt既知"
          )
      },
      { :label => "全ファイル twt未知",
          :path => artists_twt_index_path(
            filename: "all",
            #hide_day: 30,
            url_cnt: 2,
            target: ArtistsController::FileTarget::TWT_UNKNOWN_ONLY
          )
      },
      { :label => "全ファイル 既知pxv",
          :path => artists_twt_index_path(
            filename: "all",
            hide_day: 30,
            force_disp_day: 90,
            pred: PRED_PXV,
            target:"known_pxv"
          )
      },
      { :label => "全ファイル 未登録pxv",
          :path => artists_twt_index_path(
            filename: "all",
            #hide_day: 30,
            target: ArtistsController::FileTarget::PXV_UNKNOWN_ONLY
          )
      },
      # ----------------------------
      { :label => "nje", :path => "" },
      { :label => "nje", :path => artists_nje_index_path },
      # ----------------------------
      { :label => "djn", :path => "" },
      { :label => "djn", :path => artists_djn_index_path },
      # ----------------------------
      { :label => "stats", :path => "" },
      { :label => "Artist::stats", :path => artists_stats_index_path },
      # ----------------------------
      { :label => "Tweet", :path => "" },
      { :label => "Tweet", :path => tweets_path },
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

