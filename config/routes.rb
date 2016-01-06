Rails.application.routes.draw do
  resource :account, format: false, only: [:edit, :show, :update, :destroy]
  get 'list' => 'list#index', format: false
  get 'logout' => 'logout#index', format: false
  get 'policies/privacy', format: false
  get 'unsubscribe/index', format: false
  get 'unsubscribe' => 'unsubscribe#index', format: false

  # sidekiq/web
  require 'sidekiq/web'
  mount Sidekiq::Web => '/kiqside'

  root 'welcome#index'
end
