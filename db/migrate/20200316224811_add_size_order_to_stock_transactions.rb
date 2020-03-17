class AddSizeOrderToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :size_order, :integer
  end
end
