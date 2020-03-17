class PackingListParserT4 < PackingListParser
  def initialize(brand, path)
    super

    # En este caso, el nombre de la packing list es lo 
    # que sea que tengan en la primera hoja del libro..
    @packing_list_name = workbook.sheets[0]
    @style_column_name = "D"
    @style_column_text = "Style No."
  end

  def parse
    return nil unless can_parse_packing_list?

    result = []
    parse_size_names
    data_range.each do |row|
      style = packing_list.cell('D', row)
      # Tener en cuenta que este parser es un caso especial 
      # donde podemos tener filas en blanco.
      if style.present?
        color = packing_list.cell('C', row)

        size_columns.each do |col|
          size  = size_name(col)
          size_order  = size_order_for(size)
          units = packing_list.cell(col, row)
          sku   = Sku.new(style: style, color: color, size: size)
          result << StockEntry.new(brand, sku, units, size_order)
        end
      end
    end
    result
  end

  def possible_size_column_names
    ['F', 'G', 'H', 'I', 'J']
  end

  def find_last_row
    # Este formato permite filas en vacias dentro del rango de datos.
    # Asumimos que llegamos al fin del archivo cuando encontramos
    # cinco filas vacias de forma consecutiva.
    empty_rows = 0
    first_row.upto packing_list.last_row do |row|
      cell_value = packing_list.cell(style_column_name, row)
      if cell_value
        empty_rows = 0
      else
        empty_rows += 1
      end
      return row - 1 if empty_rows > 4
    end
    packing_list.last_row
  end
end

