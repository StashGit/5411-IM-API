class BrandsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token
  before_action :set_user, only: [:update, :delete, :create]
  before_action :set_brand, only: [:update, :delete]

  def all
    render json: Brand.where(deleted: nil)
  end

  def show
    render json: Brand.find(params[:id])
  end

  def update
    @brand.update!(name: params[:name], logo_url: params[:logo_url], user_id: @user.id)
    render json: @brand
  end

  def create
    render json: Brand.create!(name: params[:name], logo_url: params[:logo_url], user_id: @user.id)
  end

  def delete
    render json: @brand.soft_delete(@user)
  end

  def set_brand
    @brand = Brand.find(params[:id])
  end

  def set_user
    @user = @token.user
  end
end
