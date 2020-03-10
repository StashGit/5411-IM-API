class StockEntry
  attr_reader :brand, :sku, :units

  def initialize(brand, sku, units)
    @brand = brand
    @sku = sku
    @units = units
  end
end
