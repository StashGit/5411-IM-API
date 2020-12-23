require 'test_helper'

class SizeNameValidatorTest < ActiveSupport::TestCase
  include SizeNameSorter

  test "can sort shoes sizes" do
    supported_sizes = [
      35, 35.5, 36, 36.5, 37, 37.5, 38, 38.5, 39,
      39.5, 40, 40.5, 41, 41.5, 42, 43, 44, 45, 46
    ]

    size_order = []
    supported_sizes.each do |size|
      size_order << size_order_for(size.to_s)
    end

    size_order.each do |size_order|
      assert size_order != -1
    end
  end
end

