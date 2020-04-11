class AddPathToQrcodes < ActiveRecord::Migration[6.0]
  def change
    add_column :qrcodes, :path, :string
  end
end
