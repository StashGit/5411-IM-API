class AddDeletedToBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :deleted, :integer
  end
end
