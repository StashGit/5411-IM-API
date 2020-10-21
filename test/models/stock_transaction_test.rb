require 'test_helper'

class StockTransactionTest < ActiveSupport::TestCase
  setup do
    StockTransaction.destroy_all
  end

  test "hide stock transactions" do
    sku    = Sku.new(style: "ST0003", color: "Midnight", size: "L")
    brand  = brands(:nike)
    user   = users(:joe)
    Stock.buy(brand, sku, 10, user)

    # Esta es la transacccion que vamos a ocultar.
    sku    = Sku.new(style: "will-be-hidden", color: "Midnight", size: "L")
    Stock.buy(brand, sku, 10, user)

    StockTransaction.hide \
      brand_id: brand.id,
      style: "will-be-hidden",
      color: "Midnight",
      size: "L",
      code: nil

    assert StockTransaction.active.count == 1
  end

  test "a buying transaction adds products to the stock" do
    sku  = Sku.new(style: "ST0001", color: "Midnight", size: "L")
    brand = brands(:nike)
    user = users(:joe)

    result = Stock.buy(brand, sku, 10, user)
    assert result.ok

    assert 10 == Stock.units(brand, sku)
  end

  test "a saling transaction removes products from the stock" do
    sku  = Sku.new(style: "ST0002", color: "Midnight", size: "L")
    brand = brands(:nike)
    user = users(:joe)

    result = Stock.buy(brand, sku, 10, user)
    assert result.ok

    result = Stock.sale(brand, sku, 5, user)
    assert result.ok
    assert 5 == Stock.units(brand, sku)
  end

  test "can't set invalid transactions reasons" do
    sku    = Sku.new(style: "ST0003", color: "Midnight", size: "L")
    brand  = brands(:nike)
    user   = users(:joe)
    result = Stock.buy(brand, sku, 10, user)
    result = Stock.adjust(brand, sku, 5, user, "no comments", nil, 8)
    tnx    = StockTransaction.find(result.id)
    
    # Como 8 no es una razon valida para realizar la transaccion, el setter de
    # esa propiedad utiliza el numero 7 (Other.)
    assert ::Reason::OTHER == tnx.reason.to_i
  end

  test "add units thru stock adjustment" do
    sku  = Sku.new(style: "ST0003", color: "Midnight", size: "L")
    brand = brands(:nike)
    user = users(:joe)

    result = Stock.buy(brand, sku, 10, user)
    assert result.ok

    result = Stock.adjust(brand, sku, 5, user)
    assert result.ok
    assert 15 == Stock.units(brand, sku)
  end

  test "remove units thru stock adjustment" do
    sku  = Sku.new(style: "ST0004", color: "Midnight", size: "L")
    brand = brands(:nike)
    user = users(:joe)

    result = Stock.buy(brand, sku, 10, user)
    assert result.ok

    result = Stock.adjust(brand, sku, -5, user)

    assert result.ok
    units = Stock.units(brand, sku)
    assert 5 == units
  end

  test "make adjustments with comments" do
    sku  = Sku.new(style: "ST0005", color: "Midnight", size: "L")
    brand = brands(:nike)
    user = users(:joe)

    result = Stock.buy(brand, sku, 10, user)
    assert result.ok

    comments = "Defective lot"
    result = Stock.adjust(brand, sku, -5, user, comments)

    assert result.ok
    units = Stock.units(brand, sku)
    assert 5 == units

    t = StockTransaction.find(result.id)
    assert comments == t.comments
  end
end
