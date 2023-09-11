class SearchesController < ApplicationController
    def search
        @artists = Artist.looks(params[:target_col], params[:search_word])
    end
end
