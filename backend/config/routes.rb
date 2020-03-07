Rails.application.routes.draw do
  root :to => "home#index"
  get 'home/index'

  post 'session/new',     :to => 'session#new'
  post 'session/destroy', :to => 'session#destroy'

  get 'stock/import'
  post 'stock/upload'

  get  'stock/index'
  post 'stock/buy'
  post 'stock/sale'
  post 'stock/adjust'
  post 'stock/labels'

end
