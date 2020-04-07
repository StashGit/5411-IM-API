class Stock
  extend SizeNameSorter
  KIND_IN  = 1
  KIND_OUT = -1

  # Parsea un packing list y genera todas las transacciones necesarias para
  # ingresar los productos de esa lista al stock.
  def self.import(brand, file_path, user)
    entries = parse_packing_list(brand, file_path)
    # TODO: Validar que todos los movimientos de stock sean validos
    #       antes de grabar en al base de datos. Creo que en el caso de los
    #       imports, lo mas sano va a ser se "graba todo_" o 
    #       "no se graba nada."
    #       De esta forma, si algun registro tiene un error lo pueden corregir
    #       a manopla en el Excel y re-intentar la operacion.
    Stock.create(entries, user)
    { ok: true }
  rescue Exception => ex
    puts ex.message
    { ok: false, errors: [ex.message] }
  end

  def self.create(entries, user)
    entries.each do |entry|
      next unless entry.units

      adjust(entry.brand, entry.sku, entry.units.abs, 
             user, "Mass Import", entry.size_order)
    end
  end

  def self.buy(brand, sku, units, user, comments="")
    t = StockTransaction.new(
      brand: brand,
      style: sku.style, color: sku.color, size: sku.size,
      size_order: size_order_for(sku.size),
      kind: KIND_IN, units: units.abs, reason: Reason::BUY, 
      comments: comments)

    save_transaction(t, user)
  end

  def self.sale(brand, sku, units, user, comments="")
    t = StockTransaction.new(
      brand: brand,
      style: sku.style, color: sku.color, size: sku.size, 
      size_order: size_order_for(sku.size),
      kind: KIND_OUT, units: units.abs, reason: Reason::SALE, 
      comments: comments)

    save_transaction(t, user)
  end

  def self.adjust(brand, sku, units, user, comments="", size_order=nil)
    t = StockTransaction.new(
      brand: brand,
      style: sku.style, color: sku.color, size: sku.size, 
      size_order: size_order || size_order_for(sku.size),
      units: units.abs, reason: Reason::ADJUSTMENT, 
      comments: comments)

    t.kind  = units > 0 ? KIND_IN : KIND_OUT
    save_transaction(t, user)
  end

  # Computa todas las transacciones de stock para el SKU especificado.
  def self.units(brand, sku)
    # TODO: Bound by date o algo por el estilo.
    transactions = collect_transactions_by(brand, sku)
    total = 0
    transactions.each do |t|
      if t.kind == KIND_IN
        total += t.units
      else
        total -= t.units
      end
    end
    total
  end

  # Para testear, nos queda mas comodo que esto sea public.
  def self.select_parser_class(file_path)
    available_parsers.each do |parser_class|
      return parser_class if parser_class.can_parse?(file_path)
    end
  end

  private

  def self.parse_packing_list(brand, file_path)
    parser_class = select_parser_class(file_path)
    parser = parser_class.new(brand, file_path)
    entries = parser.parse
    entries
  end

  def self.create_parser(file_path)
    parser_class = select_parser_class(file_path)
    parser_class&.new(brand, file_path)
  end

  def self.available_parsers
    @@available_parsers ||= [
      PackingListParser,
      PackingListParserT1,
      PackingListParserT4,
      PackingListParserT5,
      PackingListParserT6,
    ]
  end

  def self.save_transaction(t, user)
    t.user = user
    t.save ? Result.new(true, t.id, nil) : Result.new(false, -1, t.errors)
  end

  def self.collect_transactions_by(brand, sku)
    StockTransaction.where(
      brand_id: brand.id, style: sku.style, color: sku.color, size: sku.size)
  end

  # TODO: En lugar de hacer esto tenemos que tener una vista materializada
  #       que nos permita hacer un select * y a otra cosa mariposa.
  #       Con muchas transacciones de stock esto se puede llegar a clavar.
  #       Si podemos cocinar la vista a medida que vamos grabando mejor.
  def self.compute_transactions_by(brand)
    res = []
    collect_skus_by(brand).each do |entry|
      sku, order, user_id = entry
      res << { 
        sku: sku, 
        units: units(brand, sku), 
        size_order: order,
        user_email: User.find(user_id).email
      }
    end
    res
  end

  def self.collect_skus_by(brand)
    sts = StockTransaction.where(brand_id: brand.id)
    tmp = sts.collect { |t| 
      [{ style: t.style, color: t.color, size: t.size }, t.size_order] 
    }.uniq

    tmp.collect { |entry| 
      sku, order, user_id = entry
      [Sku.new(**sku), order, user_id]
    }
  end
end
