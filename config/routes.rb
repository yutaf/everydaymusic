Rails.application.routes.draw do
  resource :account, format: false, only: [:edit, :show, :update, :destroy]
  get 'list' => 'list#index', format: false
  get 'logout' => 'logout#index', format: false
  root 'welcome#index'
end
