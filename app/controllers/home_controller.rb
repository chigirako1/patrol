class HomeController < ApplicationController
  def index
    @message = "This is a test site of Ruby on Rails."
    #@links = [ "users", "books", "help" ]
    @menus = [
      { :label => "Artist::stats", :path => artists_stats_index_path },
      { :label => "Artist(pxv)", :path => artists_path },
      { :label => "Artist/nje", :path => artists_nje_index_path },
      { :label => "Artist/twt(dir-all)", :path => artists_twt_index_path },
      { :label => "Artist/twt(dir-new)", :path => artists_twt_index_path(dir: "new") },
      { :label => "Artist/twt(dir-old)", :path => artists_twt_index_path(dir: "old") },
      { :label => "Artist/twt(dir-update)", :path => artists_twt_index_path(dir: "update") },
      { :label => "Artist/twt(file)", :path => artists_twt_index_path(filename: "get illust url_1217", hide_day: 1, hide_target:"") },
      { :label => "Artist/twt(file-all)", :path => artists_twt_index_path(filename: "", hide_target:"known") },
      { :label => "Twitter all", :path => twitters_path(page_title: "all", rating: 0, hide_within_days: 0, num_of_disp: 10, pred: 0, mode: "all", thumbnail: "") },
      { :label => "Twitter[手描き]", :path => twitters_path(page_title: "手描き", rating: 0, hide_within_days: 0, num_of_disp: 10, pred: 5, mode: "hand", thumbnail: "") },
      { :label => "Twitter[AI] 90", :path => twitters_path(page_title: "AI 90", rating: 90, hide_within_days: 0, num_of_disp: 10, pred:10, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 80", :path => twitters_path(page_title: "AI 80", rating: 80, hide_within_days: 1, num_of_disp: 10, pred:15, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 65", :path => twitters_path(page_title: "AI 65", rating: 65, hide_within_days: 2, num_of_disp: 10, pred:20, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 50", :path => twitters_path(page_title: "AI 50", rating: 50, hide_within_days: 3, num_of_disp: 10, pred:25, mode: "patrol", thumbnail: "t") },
      { :label => "Twitter[AI] 31", :path => twitters_path(page_title: "AI 31", rating: 31, hide_within_days: 4, num_of_disp: 10, pred:30, mode: "patrol", thumbnail: "t") },
      { :label => "User", :path => users_path },
      { :label => "Book", :path => books_path },
      { :label => "Help", :path => help_path },
      { :label => "Test", :path => test_path },
    ]
  end
  def help
  end
end
