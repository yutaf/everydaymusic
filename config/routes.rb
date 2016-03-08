Rails.application.routes.draw do
  resource :account, format: false, only: [:edit, :show, :update]
  post 'account/add_artist' => 'accounts#add_artist', format: false
  post 'account/delete_artist' => 'accounts#delete_artist', format: false
  get 'list' => 'list#index', format: false
  get 'logout' => 'logout#index', format: false
  get 'policies/privacy', format: false
  get 'unsubscribe/index', format: false
  get 'unsubscribe' => 'unsubscribe#index', format: false
  get 'deliveries/:id' => 'deliveries#show', format: false
  post 'welcome' => 'welcome#signup', format: false

  # sidekiq/web
  require 'sidekiq/web'
  mount Sidekiq::Web => '/kiqside'

  root 'welcome#index'
end
