class AddStatusToPackingLists < ActiveRecord::Migration[6.0]
  def change
    add_column :packing_lists, :status, :integer
  end
end
