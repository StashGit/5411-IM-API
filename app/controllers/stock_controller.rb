class StockController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token
  before_action :authorize, except: [:index]
  before_action :set_sku,   only: [:buy, :sale, :adjust, :labels, :units]
  before_action :set_units, only: [:buy, :sale, :adjust, :labels]
  before_action :set_user,  only: [:buy, :sale, :adjust, :labels]
  before_action :set_brand, only: [:buy, :sale, :adjust, 
                                   :labels, :units, :import,
                                   :by_brand]

  # Limite de entradas que retornamos cuando nos piden el registro
  # de transacciones.
  LOG_SIZE = 50

  def index
  end

  # Vista de prueba para seleccionar el archivo excel a manopla. Desde
  # el punto de vista de la API no tiene ningun efecto.
  def prepare_import
  end

  def import
    xls = upload_file(params[:file])
    return render_error("Failed to upload file") unless xls

    result = generate_stock_transactions(xls)
    if (result[:ok])
      render :json => result, :status => 200
    else
      render :json => result, :status => 500
    end
  end

  def units
    render :json => units_in_stock, :status => 200
  end

  def buy
    result = Stock.buy(@brand, @sku, @units, @user)
    if result.ok
      render :json => units_in_stock, :status => 200
    else
      render :json => { errors: result.errors }, :status => 500
    end
  end

  def sale
    result = Stock.sale(@brand, @sku, @units, @user)
    if result.ok
      render :json => units_in_stock, :status => 200
    else
      render :json => { errors: result.errors }, :status => 500
    end
  end

  def adjust
    result = Stock.adjust(@brand, @sku, @units, @user, params[:comments])
    if result.ok
      render :json => units_in_stock, :status => 200
    else
      render :json => { errors: result.errors }, :status => 500
    end
  end

  def labels
    raise "Not implemented."
  end

  def log
    # 3. Agregar paginador (este no es urgente, pero lo vamos a tener que hacer.)
    render :json => StockTransaction.all.
      order(created_at: :desc).
      take(LOG_SIZE)
  end

  # Esto seria stock por marca.
  def by_brand
    # En lugar de mostrar todos los movimientos tenemos que mostrar
    # el stock actual del producto (que surge de computar todos los movimientos
    # para cada sku.)
    render :json => Stock.compute_transactions_by(@brand)
  end

  private

  def units_in_stock
    result = {}
    result[:units]    = Stock.units(@brand, @sku)
    result[:style]    = @sku.style
    result[:color]    = @sku.color
    result[:size]     = @sku.size
    result[:brand_id] = @brand.id
    result
  end

  def generate_stock_transactions(xls)
    Stock.import(@brand, xls, @token.user)
  end

  def render_error message
    @result = { error: message }
    render :json => @result, :status => :bad_request
  end

  def upload_file file
    return unless file&.original_filename

    path = uploads_dir.join(file.original_filename)
    File.open(path, 'wb') do |f|
      f.write(file.read)
    end
    path.to_s
  end

  def uploads_dir
    dir = Rails.root.join('public', 'uploads_dir')
    Dir.mkdir(dir) unless Dir.exist?(dir)
    dir
  end

  def authorize
    raise "Unathorized Request" unless @token
  end

  def set_sku
    @sku  = Sku.new(**sku_params)
  end

  def set_units
    @units = params[:units].to_i
  end

  def set_user
    @user = @token.user
  end

  def set_brand
    @brand = Brand.find(params[:brand_id])
  end

  def sku_params
    sku = {}
    sku[:style] = params[:style]
    sku[:color] = params[:color]
    sku[:size]  = params[:size]
    sku
  end
end
