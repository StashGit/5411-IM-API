require 'qr.rb'

include ::QR

class QrController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def create
    @qr = create_qr_code(**qr_params)
    render "qr/show", { layout: false }
  end

  def set_access_token
    token = request.headers["Access-Token"]
    @token = ApiKey.find_by_access_token(token)
    puts "access-token: #{@token}"
  end

  private

  def qr_params
    qr = {}
    qr[:brand] = params[:brand]
    qr[:style] = params[:style]
    qr[:color] = params[:color]
    qr[:size]  = params[:size]
    qr
  end

end
