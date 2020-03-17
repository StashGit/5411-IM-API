require 'test_helper'

class BrandTest < ActiveSupport::TestCase
  test "can soft delete brand" do
    user  = User.first
    brand = Brand.create! name: "Apple"
    brand.soft_delete(user)

    assert brand.deleted?
    assert brand.user_id == user.id
  end
end
