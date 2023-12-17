class HomeController < ApplicationController
  def index
    @message = "This is a test site of Ruby on Rails."
    #@links = [ "users", "books", "help" ]
    @menus = [
      { :label => "Artist(pxv)", :path => artists_path },
      { :label => "Artist::stats", :path => artists_stats_index_path },
      { :label => "Artist/twt(dir-all)", :path => artists_twt_index_path },
      { :label => "Artist/twt(dir-new)", :path => artists_twt_index_path(dir: "new") },
      { :label => "Artist/twt(dir-old)", :path => artists_twt_index_path(dir: "old") },
      { :label => "Artist/twt(dir-update)", :path => artists_twt_index_path(dir: "update") },
      { :label => "Artist/twt(file)", :path => artists_twt_index_path(filename: "get illust url_1217", hide_day: 1, hide_target:"") },
      { :label => "Artist/twt(file-all)", :path => artists_twt_index_path(filename: "", hide_target:"known") },
      { :label => "Artist/nje", :path => artists_nje_index_path },
      { :label => "Twitter", :path => twitters_path(rating: 0, hide_within_days: 0, num_of_disp: 50, pred: 0, mode: "", thumbnail: "") },
      { :label => "Twitter[AI]", :path => twitters_path(rating: 31, hide_within_days: 1, num_of_disp: 10, pred: 14, mode: "patrol", thumbnail: "t") },
      { :label => "User", :path => users_path },
      { :label => "Book", :path => books_path },
      { :label => "Help", :path => help_path },
      { :label => "Test", :path => test_path },
    ]
  end
  def help
  end
end
