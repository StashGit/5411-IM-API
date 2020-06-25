class PackingListParserTemplate < PackingListParser
  # Este parser se utiliza para listas internas y la principal diferencia que
  # tiene con el resto es que ademas de *style*, *color*, y *size*, tambien
  # tiene **code**.
  def initialize(brand, path)
    super

    @packing_list_name = workbook.sheets[0]
    @style_column_name = "A"
    @style_column_text = "STYLE NAME"
  end

  def can_parse_packing_list?
    super && headers.include?("CODE")
  end

  def parse
    return nil unless can_parse_packing_list?

    result = []
    parse_size_names
    data_range.each do |row|

      style = packing_list.cell('A', row)
      code  = packing_list.cell('B', row)
      color = packing_list.cell('C', row)

      size_columns.each do |col|
        size  = size_name(col)
        size_order  = size_order_for(size)
        units = packing_list.cell(col, row)
        sku   = Sku.new(style: style, color: color, size: size, code: code)
        result << StockEntry.new(brand, sku, units, size_order)
      end
    end
    result
  end

  def possible_size_column_names
    ['D', 'E', 'F', 'G', 'H', 'I']
  end

  def find_head_row
    # Con la estrategia default tenemos un off by 1
    super - 1
  end
end

