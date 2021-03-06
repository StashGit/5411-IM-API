class CreateStockTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_transactions do |t|
      t.string :style
      t.string :color
      t.string :size
      t.integer :kind
      t.string :reason
      t.text :comments
      t.integer :user_id

      t.timestamps
    end
  end
end
