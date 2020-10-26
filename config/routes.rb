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
  post 'stock/create_label'
  # Dejamos este metodo que permite imprimir utilizando un token de impresion
  # para mantener la compatibilidad con el proceso import/print.
  # Internamente, terminamos generando lo mismo que print/enqueue.
  post 'stock/print_labels'
  post 'stock/print_label'
  # post 'stock/labels'
  # post 'stock/mass_print_labels' #<- Si tenemos una lista de QRs' IDs.
	# Andrew me pidio si estos podian ser POST para que sea posible hacer
	# el request utilizando la API fetch de ES6.
  post 'stock/by_brand'
  post 'stock/units'
  post 'stock/hide'
  post 'stock/restore'
  # ===

  # CRUD users
  get 'users/by_email' => "users#show"
  resources :users, only: [:create, :update, :destroy] do
  end

  # Brands.
  get 'brands/all'
  get 'brands/show/:id', :to => 'brands#show'
  post 'brands/update'
  post 'brands/create'
  post 'brands/delete'
end
