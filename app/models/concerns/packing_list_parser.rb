class PackingListParser
  include SizeNameValidator
  include SizeNameSorter

  attr_reader :brand, :size_columns, :size_names, :xls_path,
    :packing_list_name

  # Estos atributos nos sirven como referencia para poder establecer
  # el rango de datos de la hoja actual.
  attr_accessor :style_column_name, :style_column_text

  def initialize(brand, path)
    raise missing_file(path) unless File.exists?(path)

    @brand = brand
    @xls_path = path
    @packing_list_name = 'PL'
    @style_column_name = "C"
    @style_column_text = "STYLE #"
  end

  def parse
    return nil unless can_parse_packing_list?

    result = []
    parse_size_names
    data_range.each do |row|
      style = packing_list.cell('C', row)
      color = packing_list.cell('D', row)

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

  def can_parse_packing_list?
    # Con este metodo tenemos que determinar si es posible parsear
    # la packing list especificada utilizando la instancia actual del
    # parser.
    # Si detectamos que no podemos parsearla, simplemente retornamos false
    # y el sistema le asigna el trabajo a otro parser.
    contains_sheet?(@packing_list_name) && head_row != packing_list.last_row
  end

  def find_last_row
    first_row.upto packing_list.last_row do |row|
      cell_value = packing_list.cell(style_column_name, row)
      return row - 1 unless cell_value
    end
    packing_list.last_row
  end

  def find_head_row
    1.upto packing_list.last_row do |row|
      # return row + 1 if packing_list.cell('C', row) == "STYLE #"
      return row + 1 if packing_list.cell(style_column_name, row) == style_column_text
    end
    packing_list.last_row
  end

  def possible_size_column_names
    ['E', 'F', 'G', 'H', 'I', 'J', 'K']
  end

  def packing_list
    @packing_list ||= open_packing_list
  end

  def data_range
    (first_row..last_row)
  end

  # Este metodo es publico solo a los fines del testing. Los parsers
  # que exiendand esta clase no deberian tener la necesidad de
  # sobre-escribirlo.
  def parse_size_names
    @size_columns = []
    @size_names   = []
    @size_names_by_column = {}
    possible_size_column_names.each do |col|
      val = packing_list.cell(col, head_row)&.to_s
      if valid_size_name?(val)
        @size_columns << col
        @size_names << val
        @size_names_by_column[col] = val
      end
    end
    @size_names
  end

  def headers
    @headers ||= parse_headers
  end

  def parse_headers
    headers     = []
    headers_row = data_range.first - 1;
    cols    = ('A'..'Z').to_a
    cols.each do |col|
      cell_value = packing_list.cell(col, headers_row)
      if (cell_value.present?)
        headers << cell_value.to_s.strip.upcase!
      else
        return headers
      end
    end
    headers
  end

  def self.can_parse?(path)
    subject = self.new(Brand.first, path)
    subject.can_parse_packing_list?
  end

  def self.has_header?(path, name)
    subject = self.new(Brand.first, path)
    subject.headers.include?(name)
  end

  private

  def contains_sheet?(name)
    workbook.sheets.include?name
  end

  def workbook
    @wb ||= Roo::Spreadsheet.open(xls_path)
  end

  def open_packing_list
    workbook.sheet(packing_list_name)
  end

  # Nombre de la columna. (Capturado cuando armamos los headers.)
  def size_name(col)
    @size_names_by_column[col]
  end

  def is_num?(value)
    return false unless value
    value.to_s.match(/^(\d)+$/)
  end

  # head_row and last_row give us the data range we
  # have to work on.
  def head_row
    @head_row ||= find_head_row
  end

  def first_row
    head_row + 1
  end

  def last_row
    @last_row ||= find_last_row
  end

  def missing_file(path)
    ArgumentError.new("The file '#{path}' does not exists.")
  end
end
