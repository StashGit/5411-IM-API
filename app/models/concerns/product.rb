class Product
  attr_reader :style, :color, :size

  def initialize opts=[]
    @style = opts[:style]
    @color = opts[:color]
    @size  = opts[:size]
  end
end
