require 'test_helper'
#
# The strategy for detecting data ranges goes something like this:
# * Find the sheet (usually PL, packing list, etc...) if the book has only one
#   sheet, that's the packing list.
# * Find headers (style, color, size, etc....)
# * Collect size names.
# * Plot the data range.
# * Collect data into stock entries.

class PackingListParserTest < ActiveSupport::TestCase
  test "can open a packing list" do
    parser = PackingListParser.new(list_path)
    assert parser.packing_list
  end

  test "can detect the data range" do
    parser = PackingListParser.new(list_path)
    puts parser.data_rage
    assert false
  end

  test "can parse size names" do
    parser = PackingListParser.new(list_path)
    puts parser.size_columns
    assert false
  end

  test "can parse a valid packing list" do
    parser = PackingListParser.new(list_path)
    puts parser.size_names
    assert false
  end

  private
  
  def list_path
    file_fixture('pl1.xlsx').to_s
  end
end
