require 'test_helper'

class StockTransactionTest < ActiveSupport::TestCase
  setup do
    StockTransaction.destroy_all
  end

  test "add products" do
    sku = {
      style: "SS200104T",
      color: "MIDNIGHT",
      size: "AU8 US4"
    }

    StockTransaction.in(**sku, units: 10, reason: "Buying", created_by: user)

    assert(10 == Stock.units(**sku))
  end
  
  test "remove products" do
    sku = {
      style: "SS200104T",
      color: "MIDNIGHT",
      size:  "AU8 US4"
    }

    StockTransaction.in(**sku,  units: 20, reason: "Buying", created_by: user)
    StockTransaction.out(**sku, units: 10, reason: "Seling", created_by: user)

    assert(10 == Stock.units(**sku))
  end

  def user
    testing_email = "info@example.com"
    @current_user ||= User.find_by(email: testing_email)

    unless @current_user
      @current_user ||= User.create!(email: testing_email,
                                 password: "123",
                                 password_confirmation: "123")
    end
  end
end
