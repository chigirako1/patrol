Rails.application.routes.draw do
  resources :twitters
  resources :artists
  resources :users
  root 'home#index'
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/help', to: 'home#help'
  get '/test', to: 'home#test'
  get "search" => "searches#search"
  get '/artists/:id/api_hoge', to: 'artists#api_hoge', as: :artist_api_hoge
  get '/artists/:id/edit_no_update', to: 'artists#edit_no_update', as: :update_no_update_artist
  get '/artists/stats/index', to: 'artists#stats'
  get '/artists/pxv/index', to: 'artists#pxv_index'
  get '/artists/pxv/:pxvid', to: 'artists#pxv_show', as: 'artist_pxv'
  get '/artists/twt/index', to: 'artists#twt_index'
  get '/artists/twt/:twtid', to: 'artists#twt_show', as: 'artist_twt'
  get '/artists/nje/index', to: 'artists#nje_index'
  get '/artists/nje/:njeid', to: 'artists#nje_show'
=begin
  get '/books', to: 'books#index'
  get '/books/new', to: 'books#new', as: :new_book
  post '/books', to: 'books#create'
  get '/books/:id', to: 'books#show', as: :book
  get 'books/:id/edit', to: 'books#edit', as: :edit_book
  patch '/books/:id', to: 'books#update'
  delete '/books/:id', to: 'books#destroy'
=end
  resources :books do
    resources :comments
  end
  # Defines the root path route ("/")
  # root "articles#index"
end
