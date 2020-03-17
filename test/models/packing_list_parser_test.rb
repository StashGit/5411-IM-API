require 'test_helper'
#
# La estrategia para detectar el rango de datos es mas o menos asi:
# * Encontrar la hoja que tiene la informacion del pedido que necesitamos
#   para generar las transacciones de stock.(Generalente, PL, packing list, 
#   etc...); Si el libro tiene una sola hoja, asumimos que esa hoja es la 
#   packing list.
# * Encontrar los headers (style, color, size, etc....)
# * Recolectar el nombre de los talles.
# * Detectar el rango y capturar el set de datos que contiene los SKU y las
#   unidade que tenemos que ingresar en cada caso.
# * Generar las transacciones de stock.

class PackingListParserTest < ActiveSupport::TestCase
  include SizeNameValidator
  include SizeNameSorter

  test "can open a packing list" do
    parser = PackingListParser.new(brand, pl_path)
    assert parser.packing_list
  end

  test "check if can parse packing list (true)" do
    parser = PackingListParser.new(brand, pl_path)
    assert parser.can_parse_packing_list?
  end

  test "check if can parse packing list (false)" do
    parser = PackingListParser.new(brand, not_a_valid_pl_path)
    assert !parser.can_parse_packing_list?
  end

  test "can parse AU/US size names" do
    parser = PackingListParser.new(brand, pl_path)
    size_names = [
      "AU6 US2",
      "AU8 US4",
      "AU10 US6",
      "AU12 US8",
      "AU14 US10",
    ]
    assert_equal size_names, parser.parse_size_names
  end

  test "can parse any size name" do
    size_names = [
      "XXS", "XS", "S", "M", "L", "XL", "XXL",
      "xxs", "xs", "s", "m", "l", "xl", "xxl",
      "AU6 US2", "AU8 US4", "AU10 US6", "AU12 US8", "AU14 US10",
      "au6 us2", "au8 us4", "au10 us6", "au12 us8", "au14 us10",
      "au6", "us4", "au10", "us8", "us10",
    ]

    size_names.each do |size|
      assert valid_size_name?(size)
    end
  end

  test "can assign size order to all valid entries" do
    parser = PackingListParser.new(brand, pl_path)
    entries = parser.parse
    entries.each do |entry|
      if entry.size_order < 0
        puts entry.to_s
      end
      assert entry.size_order > -1
    end
  end

  # Consultando la propiedad *data_range* podemos obtener las filas
  # desde/hasta y eliminamos dos metodos de la interface publica del
  # parser. 
  # test "can detect data range first row" do
  #   parser = PackingListParser.new(brand, pl_path)
  #   assert_equal 16, parser.first_row
  # end
  #
  # test "can detect data range the last row" do
  #   parser = PackingListParser.new(brand, pl_path)
  #   assert_equal 57, parser.last_row
  # end
  
  test "can detect the data range" do
    parser = PackingListParser.new(brand, pl_path)
    assert_equal (16..57), parser.data_rage
  end

  test "can parse stock entries from a packing list" do
    parser = PackingListParser.new(brand, pl_path)
    entries = parser.parse
    skus  = 42
    sizes = 5
    assert_equal skus * sizes, entries.count
  end

  test "can detect non standad size names" do
    assert valid_std_size_name?("AU10") == false
  end

  test "can get size order from standard size names" do
    size_names = ["XXS", "Xs", "s", "m", "L", "xl", "xxl"]

    # En el caso de los std sizes podemos utilizar este
    # truco para testear.
    size_names.each_with_index do |size, index|
      assert_equal index + 1, size_order_for(size)
    end
  end

  test "can get size order from AU/US size names" do
    # Si tenemos dos nombres para el mismo talle (e.g., 'US6 AU2'), 
    # para todo_ lo referent al **orden**, tomamos el primer talle y ya.
    sizes_order = [["US6 US2", 6], ["us1", 1], ["AU10", 10]]

    sizes_order.each do |e|
      size, order = e
      assert_equal order, size_order_for(size)
    end
  end

  test "can parse t2 format" do 
    parser = PackingListParser.new(brand, plt2_path)
    entries = parser.parse
    assert entries.count > 0

    first = entries.first
    sku   = Sku.new(style: "SS200104T", color: "MINT", size: "AU6 US2")
    assert first.brand == Brand.first
    assert first.sku.to_s == sku.to_s
    assert first.units == 7
    assert first.size_order == 6

    # Tomo una entrada al azar y verifico que haya seteado
    # todas las propiedades. (Menos *units* que puede ser nil.)
    e = entries.sample
    assert e.brand
    assert e.sku
    assert e.size_order
  end

  # test "can parse t3 format" do 
  #   parser = PackingListParser.new(brand, plt3_path)
  #   entries = parser.parse
  #
  #   assert entries.count > 0
  #
  #   first = entries.first
  #   sku   = Sku.new(style: "SS200104T", color: "MINT", size: "AU6 US2")
  #   assert first.brand == Brand.first
  #   assert first.sku.to_s == sku.to_s
  #   assert first.units == 7
  #   assert first.size_order == 6
  #
  #   # Idem formato t2
  #   e = entries.sample
  #   assert e.brand
  #   assert e.sku
  #   assert e.size_order
  # end

  private

  def plt1_path
    file_fixture('plt1.xlsx').to_s
  end

  def plt2_path
    file_fixture('plt2.xlsx').to_s
  end

  def plt3_path
    file_fixture('plt3.xlsx').to_s
  end

  def plt4_path
    file_fixture('plt4.xlsx').to_s
  end

  def plt5_path
    file_fixture('plt5.xlsx').to_s
  end

  def plt6_path
    file_fixture('plt6.xlsx').to_s
  end

  def pl_path
    file_fixture('pl1.xlsx').to_s
  end

  def not_a_valid_pl_path
    file_fixture('not_a_valid_pl.xlsx').to_s
  end

  def brand
    @brand ||= brands(:nike)
  end
end
