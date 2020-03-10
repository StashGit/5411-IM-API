class HomeController < ApplicationController
  def index
    render :json => { message: "Stock API - 200 OK" }, :status => 200
  end
end
