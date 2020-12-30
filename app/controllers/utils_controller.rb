class UtilsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def upload_image
    s3_key, public_url = upload_logo(params[:image])
    img = Image.create! url: public_url, s3_key: s3_key
    render json: img.describe, status: :ok
  rescue Exception => e
    render json: { errors: [e.message] }, status: 500
  end
end
