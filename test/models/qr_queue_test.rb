require 'test_helper'

class QrQueueTest < ActiveSupport::TestCase
  setup do
    printing_queue.destroy_all
    brand = Brand.create! name: "Nike"
    @qr1 = Qrcode.create! brand_id: brand.id, style: "GRACE", color: "RED",  size: "S"
    @qr2 = Qrcode.create! brand_id: brand.id, style: "SPACE", color: "BLUE", size: "M"

    @job1 = {}
    @job1["qr_id"] = @qr1.id
    @job1["copies"] = 1

    @job2 = {}
    @job2["qr_id"] = @qr2.id
    @job2["copies"] = 2
  end

  test "can enque QR codes" do
    ok, errors = printing_queue.enqueue [@job1, @job2]

    jobs = printing_queue.pending

    assert ok
    assert 2 == jobs.count

    assert @qr1.id == jobs[0].qr.id
    assert 1       == jobs[0].copies

    assert @qr2.id == jobs[1].qr.id
    assert 2       == jobs[1].copies
  end

  test "can deque QR codes" do
    printing_queue.enqueue [@job1, @job2]

    jobs_ids = printing_queue.pending_jobs_ids

    ok, error = printing_queue.dequeue jobs_ids

    jobs = printing_queue.pending

    assert ok
    assert 0 == jobs.count
  end

  test "can deque all QR codes in one go" do
    printing_queue.enqueue [@job1, @job2]

    ok, error = printing_queue.dequeue_all

    jobs = printing_queue.pending

    assert ok
    assert 0 == jobs.count
  end

  test "can get pending jobs ids" do
    printing_queue.enqueue [@job1, @job2]

    pending_ids = printing_queue.pending_jobs_ids
    assert 2 == pending_ids.count
  end

  def printing_queue
    QrQueue
  end
end
