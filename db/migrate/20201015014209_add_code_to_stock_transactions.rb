class AddCodeToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :code, :string
  end
end
