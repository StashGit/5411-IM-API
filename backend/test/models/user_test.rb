require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "an user can be admin" do
    user = User.new email: "admin@example.com"
    user.is_admin = true
    user.save

    assert user.is_admin?
  end

  test "the user email must be unique" do
    assert_raise ActiveRecord::RecordInvalid do
      User.create! email: "joe@example.com"
      User.create! email: "joe@example.com"
    end
  end

  test "the user email is required" do
    assert_raise ActiveRecord::RecordInvalid do
      User.create! email: nil
    end
  end

  test "by default an user is not an admin" do
    assert_raise ActiveRecord::RecordInvalid do
      user = User.create! email: "joe@example.com"
      assert !user.is_admin?
    end
  end
end
