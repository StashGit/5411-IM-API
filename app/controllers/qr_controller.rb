require 'qr.rb'
include ::Qr

class QrController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def create
    @qr_path = create_qr_code(**qr_params)
    render "qr/show", { layout: false }
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

  def qr_params
    qr = {}
    qr[:brand_id] = params[:brand_id]
    qr[:style]    = params[:style]
    qr[:color]    = params[:color]
    qr[:size]     = params[:size]
    qr
  end
end
