require 'test_helper'

class BrandTest < ActiveSupport::TestCase
  test "can soft delete brand" do
    user  = User.first
    brand = Brand.create! name: "Apple"
    brand.soft_delete(user)

    assert brand.deleted?
    assert brand.user_id == user.id
  end

  test "can get all stock transactions for the brand" do
    user  = User.first
    brand = Brand.create! name: "Test Brand"
    transactions_count = 10

    create_stock_transctions(transactions_count, brand)
    assert brand.stock_transactions.count == transactions_count
  end

  test "can soft delete all of its stock transactions" do
    user  = User.first
    brand = Brand.create! name: "Test"

    transactions_count = 10

    create_stock_transctions(transactions_count, brand)

    brand.delete_stock_transactions
    assert brand.active_stock_transactions.count == 0
  end

  private

  # Creates stock transactions for the given brand.
  def create_stock_transctions count, brand
    sku  = Sku.new(style: "ST0001", color: "Midnight", size: "L")
    user = users(:joe)

    1.upto count do
      Stock.buy(brand, sku, 1, user)
    end
  end
end
