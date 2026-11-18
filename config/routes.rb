Rails.application.routes.draw do
  resources :pxv_artworks
  resources :tweets
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
  get '/tweets/update_recods/index', to: 'tweets#update_recods'
  get '/artists/pxv/index', to: 'artists#pxv_index'
  get '/artists/pxv/:pxvid', to: 'artists#pxv_show', as: 'artist_pxv'
  get '/artists/twt/index', to: 'artists#twt_index'
  get '/artists/twt/:twtid', to: 'artists#twt_show', as: 'artist_twt'
  get '/artists/nje/index', to: 'artists#nje_index'
  get '/artists/nje/:njeid', to: 'artists#nje_show'
  get '/artists/djn/index', to: 'artists#djn_index'
  get '/artists/djn/:djnid', to: 'artists#djn_show'

=begin
  resources :artists, only: [:show] do
    #get ':artworkid', to: 'artists#artwork', as: :artist_artwork
    get ':artworkid', to: 'artists#artwork_show', as: :artist_artwork
  end
  ???だめ？
=end
  get '/artists/:id/:artworkid', to: 'artists#artwork_show', as: :artist_artwork

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


=begin
参考
Rails.application.routes.draw do
  resources :pxv_artworks
  resources :tweets
  # namespaceで名前空間を付与する。
  namespace :api do
    # APIに大きな変更が発生する場合に備えてスイッチングしやすいようにURL自体にバージョンを持たせる。
    # ただし、バージョンは「必要な場合にのみ」つけることが推奨されている。
    namespace :v1 do
      # resouresはindex、show、new、edit、create、update、destroyアクションに対応するルーティングを作成できる。
      resources :restaurants do
        # only: %i[index]等と記述することで特定のアクションのみルーティングを設定することができる。
        resources :foods, only: %i[index]
      end
      resources :line_foods, only: %i[index create]
      # resourcesでは設定することのできないルーティングは以下のように記述することで設定可能
      put 'line_foods/replace', to: 'line_foods#replace'
      resources :orders, only: %i[create]
    end
  end
=end
