class AddUnitsToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :units, :integer
  end
end
