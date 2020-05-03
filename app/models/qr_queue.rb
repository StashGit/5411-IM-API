class QrQueue < ApplicationRecord
  def self.enqueue qr_id
    QrQueue.create! qr_id: qr_id
  end

  def self.dequeue qr_id
    item = QrQueue.find_by(qr_id: qr_id)
    item.update! printed: true
  end

  def self.pending
    QrQueue.where(printed: false)
  end
end
