class StockEntry
  attr_reader product, units

  def initialize(product, units)
    @product = product
    @units = units
  end
end
