class Add < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :s3_key, :string
  end
end
