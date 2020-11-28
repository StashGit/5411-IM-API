class AddBoxIdToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :box_id, :string
  end
end
