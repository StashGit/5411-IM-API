class StockEntry
  attr_reader :brand, :sku, :units, :size_order

  def initialize(brand, sku, units, size_order)
    @brand = brand
    @sku = sku
    @units = units
    @size_order = size_order
  end

  def valid?
    self.brand && self.sku
  end

  def to_s
    "| #{brand} | #{sku} | #{units} | #{size_order} |"
  end

  def self.select_invalid entries
    result = []
    entries.each do |e|
      (result << e) unless e.valid?
    end
    result
  end

  def self.all_valid? entries
    entries.each do |e|
      return false unless e.valid?
    end
    true
  end
end
