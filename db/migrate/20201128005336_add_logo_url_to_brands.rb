class AddLogoUrlToBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :logo_url, :string
  end
end
