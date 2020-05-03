Rails.application.routes.draw do
  # Home.
  root :to => "home#index"
  get 'home/index'

  ## Print labels.
  post 'print/enqueue' 
  post 'print/dequeue' 
  post 'print/dequeue_all' 
  get  'print/pending'
  get  'print/pending_jobs_ids'
  ##


  # QR
  post 'qr/create'
  post 'qr/encode'
  post 'qr/decode' # <- Idem a stock/by_brand
  delete 'qr/destroy_all'

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
  post 'stock/create_label'
  post 'stock/print_label'
  post 'stock/print_labels'      #<- Si tenemos un token de impresion.
  post 'stock/mass_print_labels' #<- Si tenemos una lista de QRs' IDs.
	# Andrew me pidio si estos podian ser POST para que sea posible hacer
	# el request utilizando la API fetch de ES6.
  post 'stock/by_brand'
  post 'stock/units'
  # ===

  # Brands.
  get 'brands/all'
  get 'brands/show/:id', :to => 'brands#show'
  post 'brands/update'
  post 'brands/create'
  post 'brands/delete'
end
