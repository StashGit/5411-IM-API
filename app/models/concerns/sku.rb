class Sku
  attr_reader :style, :color, :size, :code, :reference_id

  # code: se utiliza solo para listas internas.
  def initialize(style:, color:, size:, code: nil, reference_id: nil)
    validate_sku_args(style, color, size)

    @style         = style&.to_s&.upcase
    @color         = color&.to_s&.upcase
    @size          = size&.to_s&.upcase
    @code          = code&.to_s&.upcase
    @reference_id  = reference_id&.to_s&.upcase
  end

  def to_s
    # TODO: Refactor. Ver si podemos volar estos if.
    str = "#{self.style}-#{self.color}-#{self.size}"
    str = code ? "#{str}-#{code}" : str
    str = reference_id ? "#{str}-#{reference_id}" : str
  end

  private

  def validate_sku_args(style, color, size)
    raise ArgumentError.new("style is required") unless style.present?
    raise ArgumentError.new("color is required") unless color.present?
    raise ArgumentError.new("size is required")  unless size.present?
  end
end
