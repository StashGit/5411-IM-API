require 'test_helper'

class QrQueueTest < ActiveSupport::TestCase
  setup do
    brand = Brand.create! name: "Nike"
    @qr = Qrcode.new brand_id: brand.id, style: "GRACE", color: "RED", size: "EU1"
  end

  test "can enque QR codes" do
    res = QrQueue.enqueue @qr.id
    assert 1 == QrQueue.pending.count
  end

  test "can deque QR codes" do
    QrQueue.enqueue @qr.id
    QrQueue.dequeue @qr.id
    assert 0 == QrQueue.pending.count
  end
end
