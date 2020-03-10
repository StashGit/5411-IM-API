class AddBrandIdToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :brand_id, :integer
  end
end
