require 'test_helper'

class StockTransactionTest < ActiveSupport::TestCase

  test "generate stock transactions from packing list" do
    parser = PackingListParser.new(brand, pl_path)
    entries = parser.parse
    Stock.create(entries, User.new(email: "john@example.com"))

    # Verifico un par de transacciones.
    sku = Sku.new(style: "SS200105S", color: "MIDNIGHT", size: "AU6 US2")
    assert_equal(4, Stock.units(brand, sku))

    sku = Sku.new(style: "SS200106D", color: "MIDNIGHT", size: "AU10 US6")
    assert_equal(15, Stock.units(brand, sku))
  end

  test "import packing list and create stock transactions" do
    # Este es el metodo que usa la API para importar los archivos.
    result = Stock.import(brand, pl_path, user) 

    # Verifico un par de transacciones.
    sku = Sku.new(style: "SS200105S", color: "MIDNIGHT", size: "AU6 US2")
    assert_equal(4, Stock.units(brand, sku))

    sku = Sku.new(style: "SS200106D", color: "MIDNIGHT", size: "AU10 US6")
    assert_equal(15, Stock.units(brand, sku))
  end

  test "import packing list creates import token" do
    # Este es el metodo que usa la API para importar los archivos.
    result = Stock.import(brand, pl_path, user) 
    assert result[:token].present?
  end

  test "can use import tokens to get import transaction IDs" do
    result = Stock.import(brand, pl_path, user) 
    data   = Token.find_by_hashcode result[:token]

    assert data

    ids = JSON.parse(data.value)
    assert_equal Array, ids.class
    assert ids.count > 0
  end

  test "can create QR codes from stock transaction IDs" do
    result  = Stock.import(brand, pl_path, user)
    data    = Token.find_by_hashcode result[:token]
    ids     = JSON.parse(data.value)
    qrcodes = Qrcode.create_from_transaction ids

    assert_equal ids.count, qrcodes.count
  end
  
  private

  def pl_path
    file_fixture('pl1.xlsx').to_s
  end

  def user
    @user ||= User.new(email: "john@example.com")
  end

  def brand
    @brand ||= brands(:nike)
  end
end
