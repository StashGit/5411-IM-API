require 'qr.rb'
include ::Qr

class QrController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def encode
    qr = Qrcode.new(**qr_params)
    if qr.save
      path, base64 = create_qr_img(qr.id)
      render :json => { id: qr.id, path: path, base_64: base64 }, status: 200
    else
      render :json => { errors: qr.errors.full_messages }, status: 500
    end
  end

  def decode
    id = params[:id].to_i
    qr = Qrcode.find_by_id(id)
    if qr
      render :json => qr.to_json, status: 200
    else
      render :json => { errors: ["Not found."] }, status: 404
    end
  end

  def create
    uid      = create_qr_code(**qr_params)
    @qr_path = "#{request.base_url}/qr/#{uid}"
    image    = open("./public/qr/#{uid}") { |io| io.read }
    base64   = Base64.encode64(image)
    render json: { path: @qr_path, base_64: base64 }
  end

  def destroy_all
    result = delete_all
    if result == :ok
      render :json => "OK", status: 200
    else
      render :json => "ERR", status: 500
    end
  end

  private

  def create_qr_img(id)
    uid    = create_qr_code_for_id(id: id)
    path   = "#{request.base_url}/qr/#{uid}"
    image  = open("./public/qr/#{uid}") { |io| io.read }
    base64 = Base64.encode64(image)
    [path, base64]
  end


  def qr_params
    qr = {}
    qr[:brand_id] = params[:brand_id]
    qr[:style]    = params[:style]
    qr[:color]    = params[:color]
    qr[:size]     = params[:size]
    qr
  end
end
