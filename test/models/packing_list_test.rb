require 'test_helper'

class PackingListTest < ActiveSupport::TestCase
  test "can describe packing lists" do
    PackingList.create! path: "foo.xlsx"
    PackingList.create! path: "bar.xlsx"

    assert 2 == PackingList.describe_active_lists.count
  end
end
