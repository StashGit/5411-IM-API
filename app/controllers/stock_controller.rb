class StockController < ApplicationController
  include ::Qr

  skip_before_action :verify_authenticity_token
  before_action :set_access_token
  before_action :authorize, except: [:index]
  before_action :set_sku,   only: [:buy, :sale, :adjust, :labels, :units]
  before_action :set_units, only: [:buy, :sale, :adjust, :labels]
  before_action :set_user,  only: [:buy, :sale, :adjust, :labels]
  before_action :set_brand, only: [:buy, :sale, :adjust, 
                                   :labels, :units, :import,
                                   :by_brand]

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
    result = Stock.adjust(@brand, @sku, @units, @user, 
                          params[:comments],
                          nil, # <- size_order
                          params[:reason])
    if result.ok
      render :json => units_in_stock, :status => 200
    else
      render :json => { errors: result.errors }, :status => 500
    end
  end

  def mass_print_labels
    # Estos ids los tienen que pasar como argumentos cuando hacen el request.
    # En este punto se asume que los codigos QR ya fueron generados.
    # (Probablemente cuando hicieron el import.)
    qrcodes = Qrcode.all.take(2)
    Qrcode.print_all qrcodes
    render :json => { message: "Success" }, :status => 200
  end

  # Genera una o varias etiquetas para *un* sku.
  def labels
    raise "Not implemented."
  end

  def create_label
    # Este metodo genera la metadata del QR, graba esos datos en la base de
    # datos, y arma un QR con el *id* de ese registro.
    # Para recuperar los datos del producto hay que escanear el QR para obtener
    # el id y con ese id hacer una consulta adicional al metodo qr/decode. El 
    # metodo decode nos devuelve la marca, el estilo, etc...
    qr = Qrcode.new(**lbl_params)
    if qr.save
      path, base64 = create_qr_img(qr.id)
      qr.update! path: "public/qr/#{File.basename(path)}"

      result  = Label::create(
        qr_path: qr.path, 
        style:   lbl_params[:style],
        color:   lbl_params[:color],
        size:    lbl_params[:size])

      if result.ok
        pdf_path = "#{request.base_url}/labels/#{result.pdf_path}"
        render :json => { id: qr.id, path: pdf_path }, :status => 200
      else
        render :json => { errors: qr.errors.full_messages }, status: 500
      end
    else
      render :json => { errors: qr.errors.full_messages }, status: 500
    end
  end

  def print_label
    raise "Not implemented."
  end

  def log
    render :json => StockTransaction.log
  end

  # Esto seria stock por marca.
  def by_brand
    # En lugar de mostrar todos los movimientos tenemos que mostrar
    # el stock actual del producto (que surge de computar todos los movimientos
    # para cada sku.)
    render :json => Stock.compute_transactions_by(@brand)
  end

  private

  def create_qr_img(id)
    uid    = create_qr_code_for_id(id: id)
    path   = "#{request.base_url}/qr/#{uid}"
    image  = open("./public/qr/#{uid}") { |io| io.read }
    base64 = Base64.encode64(image)
    [path, base64]
  end

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
    @sku = Sku.new(**sku_params)
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

  def lbl_params
    lbl = {}
    lbl[:brand_id] = params[:brand_id]
    lbl[:style]    = params[:style]
    lbl[:color]    = params[:color]
    lbl[:size]     = params[:size]
    lbl
  end
end
