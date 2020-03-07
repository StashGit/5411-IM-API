Rails.application.routes.draw do
  root :to => "home#index"
  get 'home/index'
  post 'session/new', :to => 'session#new'
  post 'session/destroy', :to => 'session#destroy'
end