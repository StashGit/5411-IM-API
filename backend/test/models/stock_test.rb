require 'test_helper'

class StockTransactionTest < ActiveSupport::TestCase
  test "generate stock transactions from packing list" do
    parser = PackingListParser.new(pl_path)
    entries = parser.parse
    Stock.create(entries, User.new(email: "john@example.com"))

    # Verifico un par de transacciones.
    sku = Sku.new(style: "SS200105S", color: "MIDNIGHT", size: "AU6 US2")
    assert_equal(4, Stock.units(sku))

    sku = Sku.new(style: "SS200106D", color: "MIDNIGHT", size: "AU10 US6")
    assert_equal(15, Stock.units(sku))
  end

  test "import packing list and create stock transactions" do
    # Este es el metodo que usa la API para importar los archivos.
    Stock.import(pl_path, user) 

    # Verifico un par de transacciones.
    sku = Sku.new(style: "SS200105S", color: "MIDNIGHT", size: "AU6 US2")
    assert_equal(4, Stock.units(sku))

    sku = Sku.new(style: "SS200106D", color: "MIDNIGHT", size: "AU10 US6")
    assert_equal(15, Stock.units(sku))
  end
  
  private

  def pl_path
    file_fixture('pl1.xlsx').to_s
  end

  def user
    @user ||= User.new(email: "john@example.com")
  end
end
