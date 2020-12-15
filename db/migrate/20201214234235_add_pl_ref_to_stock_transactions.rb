class AddPlRefToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :packing_list_id, :integer
  end
end
