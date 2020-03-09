class StockEntry
  attr_reader :sku, :units

  def initialize(sku, units)
    @sku = sku
    @units = units
  end
end
