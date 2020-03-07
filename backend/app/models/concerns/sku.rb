class Sku
  attr_reader :style, :color, :size

  def initialize(style:, color:, size:)
    validate_sku_args(style, color, size)

    @style = style.upcase
    @color = color.upcase
    @size  = size.upcase
  end

  def to_s
    "#{self.style}-#{self.color}-#{self.size}"
  end

  private

  def validate_sku_args(style, color, size)
    raise ArgumentError.new("style is required") unless style.present?
    raise ArgumentError.new("color is required") unless color.present?
    raise ArgumentError.new("size is required")  unless size.present?
  end
end
