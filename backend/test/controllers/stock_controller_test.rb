require 'test_helper'

class StockControllerTest < ActionDispatch::IntegrationTest
  test "should get import" do
    get stock_import_url
    assert_response :success
  end

  test "should get buy" do
    get stock_buy_url
    assert_response :success
  end

  test "should get sale" do
    get stock_sale_url
    assert_response :success
  end

  test "should get adjust" do
    get stock_adjust_url
    assert_response :success
  end

  test "should get labels" do
    get stock_labels_url
    assert_response :success
  end

end
