Rails.application.routes.draw do
  resource :account, format: false, only: [:edit, :show, :update]
  post 'account/add_artist' => 'accounts#add_artist', format: false
  post 'account/delete_artist' => 'accounts#delete_artist', format: false
  get 'account/artists' => 'accounts#edit_artists', format: false
  post 'account/artists' => 'accounts#update_artists', format: false
  get 'signup/artists' => 'accounts#edit_artists', format: false
  post 'signup/artists' => 'accounts#update_artists', format: false
  get 'list' => 'list#index', format: false
  get 'logout' => 'logout#index', format: false
  get 'policies/privacy', format: false
  get 'unsubscribe/index', format: false
  get 'unsubscribe' => 'unsubscribe#index', format: false
  get 'deliveries/:id' => 'deliveries#show', format: false
  post 'welcome/signup', format: false
  get 'welcome/signup' => 'welcome#index', format: false
  post 'welcome/login', format: false
  get 'welcome/login' => 'welcome#index', format: false

  # sidekiq/web
  require 'sidekiq/web'
  mount Sidekiq::Web => ENV['SIDEKIQ_PATH']

  root 'welcome#index'
end
