class ApplicationController < ActionController::Base
  def set_access_token
    token = request.headers["Access-Token"]
    @token = ApiKey.find_by_access_token(token)
    puts "access-token: #{@token}"
  end
end
