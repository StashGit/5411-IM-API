module SizeNameSorter
  include SizeNameValidator

  # Si no logramos extraer el orden numerico para el talle especificado,
  # lo que hacemos es retornar -1.
  # La logica detras de esto es que preferimos que las columnas queden
  # desordenadas a que la pagina crashee.
  def size_order_for(size_name)
    return size_to_number(size_name)     if is_number?(size_name)
    return std_size_order_for(size_name) if std_size_name?(size_name)

    return 0 if valid_tu_name?(size_name)

    if valid_us_size_name?(size_name) || valid_au_size_name?(size_name)
      return extract_order_from(size_name)
    end

    if valid_beaumont_size?(size_name)
      return size_order_for(size_name.split("/")[0])
    end

    notify_cant_extract_order_from(size_name)
    -1
  end

  private

  def valid_beaumont_size?(size_name)
    /\// =~ size_name
  end

  def size_to_number(size_number)
    size_number.to_f
  end

  def std_size_order_for(size_name)
    std_sizes_order[size_name.upcase] || -1
  end

  def std_sizes_order
    @std_sizes_order ||= init_std_sizes_order
  end

  def init_std_sizes_order
    orders = {}
    orders['XXS'] = 1
    orders['XS']  = 2
    orders['S']   = 3
    orders['M']   = 4
    orders['L']   = 5
    orders['XL']  = 6
    orders['XXL'] = 7
    orders
  end


  def std_size_name?(size_name)
    valid_std_size_name?(size_name)
  end

  def extract_order_from(size_name)
    # Extraemos el prefijo y utilizamos la parte numerica
    # para ordenar el talle. (Si es AU o US, da lo mismo.)
    # "US1"     ->  1
    # "US2 AU1" ->  2 (Dos nombres para el mismo talle.)
    # "US10"    -> 10
    # Si tenemos dos nombres para el mismo talle (e.g., 'US6 AU2'),
    # para todo_ lo referente al **orden**, tomamos el primer talle y ya. La
    # logica indica que la correlacion se va a mantener para todos los talles
    # de ese set.
    start = /[0-9]/ =~ size_name
    tmp = size_name[start..].split(/\/| /)
    if tmp.length > 0
      order = tmp[0]
      return order.to_i if /^[0-9]+$/ =~ order
    end
    -1
  end

  def notify_cant_extract_order_from(size_name)
    puts "Can't extract size order from #{size_name}"
  end
end
