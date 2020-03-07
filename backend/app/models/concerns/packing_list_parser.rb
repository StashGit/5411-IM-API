class PackingListParser
  attr_reader :packing_list, :size_columns

  def initialize(path)
    raise missing_file(path) unless File.exists?(path)

    @packing_list = open_packing_list(path)
    setup_size_columns
  end

  def open_packing_list(path)
    wb = Roo::Spreadsheet.open(path)
    wb.sheet('PL')
  end

  def possible_size_column_names
    ['E', 'F', 'G', 'H', 'I', 'J', 'K']
  end

  def setup_size_columns
    @size_columns = []
    @size_names   = []
    possible_size_column_names.each do |col|
      val = packing_list.cell(col, head_row)
      if valid_size_name?(val)
        @size_columns << col
        @size_names[col] = val
      end
    end
  end

  def valid_size_name?(name)
  end

  # Nombre de la columna. (Capturado cuando armamos los headers.)
  def size_name(col)
    @size_names[col]
  end

  # returns a collection of [sku, units]
  def parse
    result = []
    data_rage.each do |row|
      style = packing_list.cell('C', row)
      color = packing_list.cell('D', row)

      size_columns.each do |col|
        size  = size_name(col)
        units = packing_list.cell(col, row)
        prod  = Product.new(style: style, color: color, size: size)
        result << StockEntry.new(prod, units)
      end
    end
    result
  end

  def data_rage
    ((head_row + 1)..last_row)
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

  def last_row
    @last_row ||= find_last_row
  end

  def find_last_row
    (head_row + 1).upto packing_list.last_row do |row|
      cell_value = packing_list.cell('C', row) || 0
      return row - 1 unless is_num?(cell_value)
    end
    packing_list.last_row
  end

  def find_head_row
    1.upto packing_list.last_row do |row|
      return row + 1 if packing_list.cell('C', row) == "STYLE #"
    end
    packing_list.last_row
  end

  def missing_file(path)
    ArgumentError.new("The file '#{path}' does not exists.")
  end
end
