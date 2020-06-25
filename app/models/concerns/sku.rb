class Sku
  attr_reader :style, :color, :size, :code

  # code: se utiliza solo para listas internas.
  def initialize(style:, color:, size:, code: nil)
    validate_sku_args(style, color, size)

    @style = style.upcase
    @color = color.upcase
    @size  = size.upcase
    @code  = code&.upcase
  end

  def to_s
    str = "#{self.style}-#{self.color}-#{self.size}"
    code ?  "#{str}-#{code}" : str
  end

  private

  def validate_sku_args(style, color, size)
    raise ArgumentError.new("style is required") unless style.present?
    raise ArgumentError.new("color is required") unless color.present?
    raise ArgumentError.new("size is required")  unless size.present?
  end
end
