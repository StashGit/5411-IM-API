require 'test_helper'

class SizeNameValidatorTest < ActiveSupport::TestCase
  include SizeNameValidator

  test "supports shoes sizes" do
    supported_sizes = [
      35, 35.5, 36, 36.5, 37, 37.5, 38, 38.5, 39,
      39.5, 40, 40.5, 41, 41.5, 42, 43, 44, 45, 46
    ]

    supported_sizes.each do |size|
      assert valid_size_name?(size)
    end
  end
end