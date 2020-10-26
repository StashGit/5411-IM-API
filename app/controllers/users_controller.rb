class UsersController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :set_user, only: [:update, :destroy]
  before_action :set_user_by_email, only: [:show]

  def index
    render json: User.active
  end

  def show
    if @user
      render json: @user
    else
      render json: { error: "No user with email #{params[:email]}" }
    end
  end

  def create
    render json: User.create!(user_params)
  end

  def update
    @user.assign_attributes user_update_params
    if @user.save
      render json: @user
    else
      render json: @user.errors.full_messages
    end
  end

  def destroy
    if @user.update deleted: true
      render json: { message: "Success" }
    else
      render json: @user.errors.full_messages
    end
  end

  private

  def set_user
    @user = User.active.find(params[:id])
  end

  def set_user_by_email
    @user = User.active.find_by(email: params[:email])
  end

  def user_update_params
    params.require(:user).permit \
      :first_name,
      :last_name,
      :pic_url,
      :password,
      :password_confirmation
  end

  def user_params
    params.require(:user).permit \
      :email,
      :first_name,
      :last_name,
      :pic_url,
      :password,
      :password_confirmation
  end
end
