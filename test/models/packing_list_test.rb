require 'test_helper'

class PackingListTest < ActiveSupport::TestCase
  test "can describe packing lists" do
    PackingList.create! path: "foo.xlsx", brand: brands(:puma)
    PackingList.create! path: "bar.xlsx", brand: brands(:puma)
    PackingList.create! path: "baz.xlsx", brand: brands(:nike)

    assert 2 == PackingList.describe_active_lists(brands(:puma)).count
  end
end
