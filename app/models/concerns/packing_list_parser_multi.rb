class PackingListParserMulti < PackingListParser
  MAX_ROWS_COUNT=1000

  # Este parser se utiliza para listas internas y la principal diferencia que
  # tiene con el resto es que puede contener multiples rangos de datos por hoja
  # y multiples hojas por archivo.
  def initialize(brand, path)
    super

    @packing_list_name = workbook.sheets[0]
    @style_column_name = "A"
    @style_column_text = "STYLE"

    # Esto atributos son propios de este parser.
    @lo = 0
    @hi = 0
  end

  def match_headers
    headers[0]&.upcase == "STYLE"
    headers[1]&.upcase == "COLOR"
    headers[2]&.upcase == "XXS"
  end

  def can_parse_packing_list?
    super && match_headers
  end

  def parse
    return nil unless can_parse_packing_list?

    # Recordar que esta packing list es especial. Podemos tener multiples hojas
    # y multiples rangos de datos en cada hoja.

    result = []
    parse_size_names

    loop do
      next_data_range = fetch_next_data_range
      return result unless next_data_range.any?

      next_data_range.each do |row|
        style = current_sheet.cell('A', row)
        color = current_sheet.cell('B', row) || "UNKNOWN"

        size_columns.each do |col|
          size  = size_name(col)
          size_order  = size_order_for(size)
          units = current_sheet.cell(col, row)
          sku   = Sku.new(style: style, color: color, size: size)
          result << StockEntry.new(brand, sku, units, size_order)
        end
      end
    end
    result
  end

  def current_sheet
    name = workbook.sheets[0]
    workbook.sheet(name)
  end

  def find_high
    @hi = @lo
    consecutive_empties = 0
    loop do
      @hi += 1
      break if @hi == MAX_ROWS_COUNT

      val = current_sheet.cell('A', @hi)
      break if val&.upcase == "STYLE" # <- Nuevo bloque de datos dentro de la misma hoja.

      if val.present?
        consecutive_empties = 0
      else
        consecutive_empties += 1
      end
      # Si llegamos a 10 filas consecutivas sin encontrar contenido, asumimos
      # que llegamos al final del rango de datos.
      break if consecutive_empties >= 10
    end
    @hi -= 1
  end

  def find_low
    @lo = @lo > 0 ? @hi : 1

    loop do
      @lo += 1
      val = current_sheet.cell('A', @lo)
      break if val&.upcase == "STYLE"

      break @lo >= MAX_ROWS_COUNT
    end
    @lo +=1
  end

  def next_hilo
    find_low
    find_high

    # puts "#{@lo}..#{@hi}"
    @lo..@hi
  end

  def fetch_next_data_range
    data_range = []
    next_hilo.each do |row_num|
      val = current_sheet.cell('A', row_num)
      if val.present? # <- De esta forma nos sacamos de encima las empty rows.
        data_range << row_num
      end
    end
    data_range
  end

  def fetch_all_data_ranges
    result = []
    loop do
      data_range = fetch_next_data_range
      if data_range.any?
        result << data_range
      else
        return result
      end
    end
  end

  def possible_size_column_names
    ['C', 'D', 'E', 'F', 'G', 'H']
  end

  def find_head_row
    # Con la estrategia default tenemos un off by 1
    super - 1
  end
end

