class BrandsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def all
    render json: Brand.all
  end

  def update
    render json: Brand.update(name: params[:name])
  end

  def create
    render json: Brand.create(name: params[:name])
  end
end
