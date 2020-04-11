class CreateQrcodes < ActiveRecord::Migration[6.0]
  def change
    create_table :qrcodes do |t|
      t.integer :brand_id
      t.string :style
      t.string :color
      t.string :size

      t.timestamps
    end
  end
end
