class AddReferenceIdToStockTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_transactions, :reference_id, :string
  end
end
