require 'test_helper'

class PrintQueueTest < ActiveSupport::TestCase
  setup do
    sku  = Sku.new(style: "ST0001", color: "Midnight", size: "L")
    brand = brands(:nike)
    user = users(:joe)
    result = Stock.buy(brand, sku, 10, user)
    @tr_id = result.id
  end

  test "can enqueue stock transactions" do
    assert PrintQueue.enqueue transactions_ids: [@tr_id]
    assert 1 == PrintQueue.queued_transactions.count
  end

  test "can dequeue stock transactions" do
    assert PrintQueue.dequeue transactions_ids: [@tr_id]
    assert 0 == PrintQueue.queued_transactions.count
  end


end
