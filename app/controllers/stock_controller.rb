class StockController < ApplicationController
  include ::Qr

  skip_before_action :verify_authenticity_token
  before_action :set_access_token
  before_action :authorize,        except: [:index]
  before_action :set_sku,          only:   [:buy, :sale, :adjust, :units]
  before_action :set_units,        only:   [:buy, :sale, :adjust]
  before_action :set_user,         only:   [:buy, :sale, :adjust]
  before_action :set_packing_list, only:   [:delete_packing_list]
  before_action :set_brand,        only:   [
    :buy, :sale, :adjust, :units, :import, :by_brand, :packing_lists,
    :damaged_by_brand
  ]

  def packing_lists
    render json: PackingList.describe_active_lists(@brand)
  end

  def delete_packing_list
    if @packing_list
      ok, error = StockTransaction.delete_packing_list(@packing_list)
      if ok
        render json: { message: "OK" }, status: :ok
      else
        render json: { message: error }, status: :internal_server_error
      end
    else
      render json: { message: "Failed to find the packing list" }, status: :not_found
    end
  end

  def index
  end

  # Vista de prueba para seleccionar el archivo excel a manopla. Desde
  # el punto de vista de la API, no tiene ningun efecto.
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
    result = Stock.adjust \
      @brand,
      @sku,
      @units,
      @user,
      params[:comments],
      reason: params[:reason]

    if result.ok
      render :json => units_in_stock, :status => 200
    else
      render :json => { errors: result.errors }, :status => 500
    end
  end

  def print_labels
    token = Token.find_by_hashcode(params[:token])
    if token
      ids     = JSON.parse(token.value)
      qrcodes = Qrcode.create_from_transaction ids

      jobs = create_printing_jobs(qrcodes);
      ok, errors = QrQueue.enqueue jobs

      if ok
        render :json => { message: "Success!" }, :status => 200
      else
        render :json => { errors: errors }, :status => 400
      end
    else
      render :json => { errors: ["The given token doesn't exists."] }, :status => 404
    end
  end

  def print_label
    qrcode = Qrcode.find_by_id(params[:id])

    unless qrcode
      render :json => { message: "Not found" }, :status => 404
    else
      job = create_printing_job(qrcode, params[:copies])
      ok, errors = QrQueue.enqueue [job]
      if ok
        render :json => { message: "Success!" }, :status => 200
      else
        render :json => { errors: errors }, :status => 400
      end
    end
  end

  def create_label
    # Este metodo genera la metadata del QR, graba esos datos en la base de
    # datos, y arma un QR con el *id* de ese registro.
    # Para recuperar los datos del producto hay que escanear el QR para obtener
    # el id y con ese id hacer una consulta adicional al metodo qr/decode. El
    # metodo decode nos devuelve la marca, el estilo, etc...
    qr = Qrcode.new(**lbl_params)

    # No podemos usar save sin el bang porque entra en conflicto con el metodo
    # save que importamos del modulo Qr.
    qr.save!
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
  rescue Exception => ex
    render :json => { errors: [ ex. message ] }, status: 500
  end

  def log
    render :json => StockTransaction.log
  end

  def by_brand
    transactions = Stock.compute_transactions(@brand.id)
    render :json => transactions
  end

  def damaged_by_brand
    transactions = Stock.compute_transactions(@brand.id, damaged_only: true)
    render :json => transactions
  end

  def hide
    styles = params[:style].is_a?(Array) ? params[:style] : [params[:style]]
    colors = params[:color].is_a?(Array) ? params[:color] : [params[:color]]

    affected_transactions_count = StockTransaction.hide \
      brand_id: params[:brand_id],
      styles: styles,
      colors: colors

    render :json => {affected_transactions_count: affected_transactions_count }, status: 200
  rescue Exception => ex
    render :json => { errors: [ ex.message ] }, status: 500
  end

  def restore
    styles = params[:style].is_a?(Array) ? params[:style] : [params[:style]]
    colors = params[:color].is_a?(Array) ? params[:color] : [params[:color]]

    affected_transactions_count = StockTransaction.restore \
      brand_id: params[:brand_id],
      styles: styles,
      colors: colors

    render :json => {affected_transactions_count: affected_transactions_count }, status: 200
  rescue Exception => ex
    render :json => { errors: [ ex.message ] }, status: 500
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
    result[:units]        = Stock.units(@brand, @sku)
    result[:style]        = @sku.style
    result[:color]        = @sku.color
    result[:size]         = @sku.size
    result[:code]         = @sku.code
    result[:reference_id] = @sku.reference_id
    result[:box_id]       = @sku.box_id
    result[:brand_id]     = @brand.id
    result
  end

  def generate_stock_transactions(xls)
    Stock.import(@brand, xls, @token.user)
  end

  def render_error message
    @result = { error: message }
    render :json => @result, :status => :bad_request
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

  def set_packing_list
    @packing_list = PackingList.find_by(id: params[:packing_list_id])
  end

  def set_brand
    @brand = Brand.find(params[:brand_id])
  end

  def sku_params
    sku = {}
    sku[:style]         = params[:style]
    sku[:color]         = params[:color]
    sku[:size]          = params[:size]
    sku[:code]          = params[:code]
    sku[:box_id]        = params[:box_id]
    sku[:reference_id]  = params[:reference_id]
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

  def create_printing_jobs qrcodes
    # jobs: [{ qr_id: 1, copies: 2 }, { qr_id: 2, copies: 2 }]
    jobs = []
    qrcodes.each do |code|
      job = {}
      job["qr_id"]  = code[:qr].id
      job["copies"] = code[:copies]
      jobs << job
    end
    jobs
  end

  def create_printing_job qrcode, copies
    job = {}
    job["qr_id"]  = qrcode.id
    job["copies"] = copies&.to_i || 1
    job
  end

  def heroku
    request.original_url =~ /heroku/
  end
end
