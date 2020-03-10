require 'test_helper'

class BrandsControllerTest < ActionDispatch::IntegrationTest
  test "should get all" do
    get brands_all_url
    assert_response :success
  end

  test "should get update" do
    get brands_update_url
    assert_response :success
  end

  test "should get create" do
    get brands_create_url
    assert_response :success
  end

end
