require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "an user can be admin" do
    user = User.new email: "admin@example.com", 
      password: "123", 
      password_confirmation: "123"

    user.is_admin = true
    user.save!

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
    user = User.create! email: "jane@example.com",
      password: "123", 
      password_confirmation: "123"

    assert !user.is_admin?
  end

  test "an user can create an access token" do
    user = User.create! email: "john@example.com", 
      password: "123", 
      password_confirmation: "123"

      key  = user.create_api_key
      assert key.present?
      assert key.access_token.present?
  end
end
