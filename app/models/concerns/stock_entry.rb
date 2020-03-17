class StockEntry
  attr_reader :brand, :sku, :units, :size_order

  def initialize(brand, sku, units, size_order)
    @brand = brand
    @sku = sku
    @units = units
    @size_order = size_order
  end

  def to_s
    "| #{brand} | #{sku} | #{units} | #{size_order} |"
  end
end
