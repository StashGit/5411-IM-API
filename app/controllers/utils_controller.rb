class UtilsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def upload_image
    server_path = upload_logo(params[:image])
    url = "#{request.base_url}/logos/#{File.basename(server_path)}"
    img = Image.create! url: url
    render json: { img_id: img.id, img: url }, status: 200
  rescue Exception => e
    render json: { errors: [e.message] }, status: 500
  end
end
