class SessionController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_user, only: [:new]

  # POST email/pwd
  def new
    unless @user
      @result = user_not_found
      return render :json => @result, :status => :bad_request
    end

    if @user.authenticate(params[:password])
      @result = get_access_token
      render :json => @result, :status => 200
    else
      @result = invalid_credentials
      render :json => @result, :status => :bad_request
    end
  end

  # POST token
  def destroy
    key = ApiKey.find_by_access_token(params[:token])
    if key && key.destroy
      @result = { message: "The session was destroyed." }
      render :json => @result, :status => 200
    else
      @result = { message: "Invalid session or api token." }
      render :json => @result, :status => :bad_request
    end
  end

  private

  def get_access_token
    access_token = find_access_token || create_access_token
    { token: access_token, status: 200 }
  end

  def find_access_token
    ApiKey.find_by_user_id(@user.id)&.access_token
  end

  def create_access_token
    apikey = ApiKey.create!(user_id: @user.id)
    apikey.access_token
  end

  def set_user
    @user = User.find_by_email(params[:email])
  end

  def user_not_found
    res = {
      error: "Sorry. We counldn't find the user.",
      status: 400
    }
  end

  def invalid_credentials
    res = {
      error: "The email or password is not correct.",
      status: 400
    }
  end
end
