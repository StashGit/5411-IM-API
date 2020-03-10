require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  test "an apikey must have an access token" do
    user = users(:joe)
    apikey = ApiKey.create! user_id: user.id

    assert apikey.access_token.present?
  end

  test "an access token expires in 30 days" do
    user = users(:joe)
    apikey = ApiKey.create! user_id: user.id

    assert((apikey.expires_at - 30.days.from_now) < 1)
  end
end
