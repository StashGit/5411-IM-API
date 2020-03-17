class AddDeletedByToBrands < ActiveRecord::Migration[6.0]
  def change
    # En lugar de deleted_by vamos a utilizar user_id que nos
    # sirve para auditar created y updates tambien.
    # add_column :brands, :deleted_by, :integer
    add_column :brands, :user_id, :integer
  end
end
