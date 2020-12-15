class AddBrandIdToPackingLists < ActiveRecord::Migration[6.0]
  def change
    add_column :packing_lists, :brand_id, :integer
  end
end
