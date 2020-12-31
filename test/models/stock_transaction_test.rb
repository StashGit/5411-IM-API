require 'test_helper'

class StockTransactionTest < ActiveSupport::TestCase
  setup do
    StockTransaction.destroy_all
  end

  test "compute transactions supports negative units" do
    sku1 = Sku.new \
      style: "will-be-deleted",
      color: "Midnight",
      size: "L",
      box_id: "BOX 1",
      reference_id: "PO123"

    sku2 = Sku.new \
      style: "will-be-deleted",
      color: "Midnight",
      size: "L",
      box_id: "BOX 4",
      reference_id: "PO123"

    brand = brands(:nike)
    user  = users(:joe)

    Stock.adjust(brand, sku2, -10, user, "Testing Delete")
    Stock.adjust(brand, sku1,  10, user, "Testing Delete")
    Stock.adjust(brand, sku1, -15, user, "Testing Delete")

    result = Stock.compute_transactions(brand.id)
    assert -15 == result.last.sizes.last.total_units
  end

  test "delete packing list" do
    sku   = Sku.new(style: "will-be-deleted", color: "Midnight", size: "L")
    brand = brands(:nike)
    user  = users(:joe)

    # De esta forma simulamos el import de 2 packing lists.

    pl1 = PackingList.create! path: "foo.txt"
    Stock.adjust(brand, sku, 10, user, "Testing Delete", pl: pl1)

    pl2 = PackingList.create! path: "bar.txt"
    Stock.adjust(brand, sku, 10, user, "We don't delete this one.", pl: pl2)

    assert StockTransaction.count == 2

    StockTransaction.delete_packing_list pl1

    # Solo tenemos que tener las transacciones de pl2.
    assert StockTransaction.active.count == 1
    assert pl1.status == PackingList::DELETED
  end

  test "restore stock transactions" do
    sku = Sku.new(style: "will-be-hidden", color: "Midnight", size: "L")
    brand = brands(:nike)
    user  = users(:joe)

    Stock.buy(brand, sku, 10, user)
    StockTransaction.hide \
      brand_id: brand.id,
      styles: ["will-be-hidden"],
      colors: ["Midnight"]

    StockTransaction.restore \
      brand_id: brand.id,
      styles: ["will-be-hidden"],
      colors: ["Midnight"]

    assert StockTransaction.active.count == 1
  end

  test "hide stock transactions" do
    sku   = Sku.new(style: "ST0003", color: "Midnight", size: "L")
    brand = brands(:nike)
    user  = users(:joe)
    Stock.buy(brand, sku, 10, user)

    # ======================================================================
    # Estas son las transacciones que vamos a ocultar.
    # ======================================================================
    sku = Sku.new(style: "will-be-hidden", color: "Midnight", size: "L")
    Stock.buy(brand, sku, 10, user)

    sku = Sku.new(style: "will-be-hidden", color: "Midnight", size: "M")
    Stock.buy(brand, sku, 10, user)

    sku = Sku.new(style: "will-be-hidden", color: "Midnight", size: "S")
    Stock.buy(brand, sku, 10, user)
    # ======================================================================

    StockTransaction.hide \
      brand_id: brand.id,
      styles: ["will-be-hidden"],
      colors: ["Midnight"]

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
    result = Stock.adjust(brand, sku, 5, user, "no comments", reason: 8000)
    tnx    = StockTransaction.find(result.id)

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

  test "can save reference_id and box_id" do
    sku  = Sku.new \
      style: "ST0005",
      color: "Midnight",
      size: "L",
      reference_id: "ref-123",
      box_id: "box-123"

    brand = brands(:nike)
    user = users(:joe)

    result = Stock.buy(brand, sku, 10, user)


    st = StockTransaction.find(result.id)

    assert st.reference_id.present?
    assert st.box_id.present?
  end

  test "generate move stock transaction" do
    sku_from  = Sku.new \
      style: "ST0005",
      color: "Midnight",
      size: "L",
      reference_id: "ref-1",
      box_id: "box-1"

    sku_to  = Sku.new \
      style: "ST0005",
      color: "Midnight",
      size: "L",
      reference_id: "ref-2",
      box_id: "box-2"

    brand = brands(:nike)
    user = users(:joe)

    # hacemos una transaccion de compra
    Stock.buy(brand, sku_from, 10, user)

    # hacemos el movimiento de stock de un lugar a otro
    result = Stock.move(brand, sku_from, sku_to, 3, user)

    assert result.ok
    units_from = Stock.units(brand, sku_from)
    units_to = Stock.units(brand, sku_to)
    assert 7 == units_from
    assert 3 == units_to
  end
end
