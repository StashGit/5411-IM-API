require 'test_helper'

class QrControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get qr_create_url
    assert_response :success
  end

end
