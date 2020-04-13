class StockEntry
  attr_reader :brand, :sku, :units, :size_order
  validate_presence_of :brand, :sku, :units, :size_order

  def initialize(brand, sku, units, size_order)
    @brand = brand
    @sku = sku
    @units = units
    @size_order = size_order
  end

  def to_s
    "| #{brand} | #{sku} | #{units} | #{size_order} |"
  end

  def self.all_valid? entries
    entries.each do |e|
      return false unless e.valid?
    end
    true
  end
end
