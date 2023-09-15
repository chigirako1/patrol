class SearchesController < ApplicationController
    def search
        @artists = Artist.looks(params[:target_col], params[:search_word], params[:match_method])
    end
end
