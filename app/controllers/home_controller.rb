class HomeController < ApplicationController
  def index
    @message = "This is a test site of Ruby on Rails."
    #@links = [ "users", "books", "help" ]
    @menus = [
      { :label => "Artist(pxv)", :path => artists_path },
      { :label => "Artist/twt", :path => artists_twt_index_path },
      { :label => "Artist/nje", :path => artists_nje_index_path },
      { :label => "Twitter", :path => twitters_path },
      { :label => "User", :path => users_path },
      { :label => "Book", :path => books_path },
      { :label => "Help", :path => help_path },
      { :label => "Test", :path => test_path },
      
    ]
  end
  def help
  end
end
