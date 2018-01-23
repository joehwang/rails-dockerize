Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  match "start/" => "welcome#index", :via => [:get, :post]
  match "set_session/" => "welcome#set_session", :via => [:get, :post]
  match "get_session/" => "welcome#get_session", :via => [:get, :post]
  match "drop_session/" => "welcome#drop_session", :via => [:get, :post]
  root 'welcome#index'
end
