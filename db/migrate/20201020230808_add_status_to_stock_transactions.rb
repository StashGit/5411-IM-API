class AddStatusToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :status, :string
  end
end
