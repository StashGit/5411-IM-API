Rails.application.routes.draw do
  # Home.
  root :to => "home#index"
  get 'home/index'

  # Session.
  post 'session/new',     :to => 'session#new'
  post 'session/destroy', :to => 'session#destroy'

  # Stock.
  get  'stock/prepare_import'
  post 'stock/import'
  get  'stock/units'
  get  'stock/index'
  get  'stock/log'
  post 'stock/buy'
  post 'stock/sale'
  post 'stock/adjust'
  post 'stock/labels'

  # Brands.
  get 'brands/all'
  post 'brands/update'
  post 'brands/create'
end
