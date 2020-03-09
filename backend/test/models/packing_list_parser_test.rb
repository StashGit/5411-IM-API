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
  test "can open a packing list" do
    parser = PackingListParser.new(pl_path)
    assert parser.packing_list
  end

  test "can parse size names" do
    parser = PackingListParser.new(pl_path)
    size_names = [
      "AU6 US2",
      "AU8 US4",
      "AU10 US6",
      "AU12 US8",
      "AU14 US10"
    ]
    assert_equal size_names, parser.parse_size_names
  end

  # test "can detect the data range" do
  #   parser = PackingListParser.new(pl_path)
  #   puts parser.data_rage
  #   assert false
  # end
  #
  # test "can parse a valid packing list" do
  #   parser = PackingListParser.new(pl_path)
  #   puts parser.size_names
  #   assert false
  # end

  private
  
  def pl_path
    file_fixture('pl1.xlsx').to_s
  end
end
