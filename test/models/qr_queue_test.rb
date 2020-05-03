require 'test_helper'

class QrQueueTest < ActiveSupport::TestCase
  setup do
    brand = Brand.create! name: "Nike"
    @qr = Qrcode.new brand_id: brand.id, style: "GRACE", color: "RED", size: "EU1"
  end

  test "can enque QR codes" do
  end

  test "can deque QR codes" do
  end
end
