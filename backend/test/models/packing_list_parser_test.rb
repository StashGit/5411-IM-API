require 'test_helper'

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
