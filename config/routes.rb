Rails.application.routes.draw do
  # Home.
  root :to => "home#index"
  get 'home/index'

  # QR
  post 'qr/create'

  # Session.
  post 'session/new',     :to => 'session#new'
  post 'session/destroy', :to => 'session#destroy'

  # Stock.
  get  'stock/prepare_import'
  post 'stock/import'
  get  'stock/index'
  get  'stock/log'
  post 'stock/buy'
  post 'stock/sale'
  post 'stock/adjust'
  post 'stock/labels'
	# Andrew me pidio si estos podian ser POST para que sea posible hacer
	# el request utilizando la API fetch de ES6.
  post 'stock/by_brand'
  post 'stock/units'

  # Brands.
  get 'brands/all'
  post 'brands/update'
  post 'brands/create'
end
