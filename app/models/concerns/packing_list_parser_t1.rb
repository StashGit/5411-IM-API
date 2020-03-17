class PackingListParserT1 < PackingListParser
  def initialize(brand, path)
    super

    # En este caso, el nombre de la packing list es lo 
    # que sea que tengan en la primera hoja del libro..
    @packing_list_name = workbook.sheets[0]
    @style_column_name = "A"
    @style_column_text = "STYLE NUMBER"
  end

  def can_parse_packing_list?
    super && headers.include?("STYLE NUMBER")
  end

  def parse
    return nil unless can_parse_packing_list?

    result = []
    parse_size_names
    data_range.each do |row|
      style = packing_list.cell('A', row)
      color = packing_list.cell('C', row)

      size_columns.each do |col|
        size  = size_name(col)
        size_order  = size_order_for(size)
        units = packing_list.cell(col, row)
        sku   = Sku.new(style: style, color: color, size: size)
        result << StockEntry.new(brand, sku, units, size_order)
      end
    end
    result
  end

  def possible_size_column_names
    ['E', 'F', 'G', 'H']
  end

  def find_head_row
    # Con la estrategia default tenemos un off by 1
    super - 1
  end
end

