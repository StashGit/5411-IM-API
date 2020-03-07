require 'test_helper'

class PackingListParserTest < ActiveSupport::TestCase
  test "can open a packing list" do
    path = file_fixture('pl1.xlsx').to_s
    parser = PackingListParser.new(path)

    assert parser.packing_list
  end
end
