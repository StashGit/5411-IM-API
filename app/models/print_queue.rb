class PrintQueue < ApplicationRecord
  belongs_to :stock_transaction

  def self.enqueue transactions_ids:
    return unless transactions_ids

    PrintQueue.transaction do
      transactions_ids.each do |id|
        PrintQueue.create! stock_transaction_id: id, printed: false
      end
    end
  end

  def self.dequeue transactions_ids:
    return unless transactions_ids

    items = PrintQueue.where(id: [transactions_ids])
    PrintQueue.transaction do
      items.each do |item|
        item.update! printed: true
      end
    end
  end

  def self.queued_transactions
    ids = PrintQueue.where(printed: false).collect(&:stock_transaction_id)
    StockTransaction.where(id: ids)
  end

end
