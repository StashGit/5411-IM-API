class StockController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def index
  end

  def import
  end

  def upload
    return render_error("Invalid access token")  unless @token

    xls = upload_file(params[:file])
    return render_error("Failed to upload file") unless xls

    result = generate_stock_transactions(xls)
    if (result.ok)
      @result = { success: true }
      render :json => @result, :status => 200
    else
      @result = { errors: result.errors }
      render :json => @result, :status => 500
    end

  end

  def buy
  end

  def sale
  end

  def adjust
  end

  def labels
  end

  def log
  end

  private

  def generate_stock_transactions(xls)
    Stock.import(xls)
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
    path
  end

  def uploads_dir
    dir = Rails.root.join('public', 'uploads_dir')
    Dir.mkdir(dir) unless Dir.exist?(dir)
    dir
  end

  def set_access_token
    token = request.headers["Access-Token"]
    @token = ApiKey.find_by_access_token(token)
    puts "access-token: #{@token}"
  end
end
