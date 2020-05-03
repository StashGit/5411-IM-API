class CreatePrintQueues < ActiveRecord::Migration[6.0]
  def change
    create_table :print_queues do |t|
      t.integer :stock_transaction_id
      t.boolean :printed, default: false

      t.timestamps
    end
  end
end
