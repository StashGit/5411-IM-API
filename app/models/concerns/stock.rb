class Stock
  KIND_IN  = 1
  KIND_OUT = -1

  # Parsea un packing list y genera todas las transacciones necesarias para
  # ingresar los productos de esa lista al stock.
  def self.import(brand, file_path, user)
    parser = PackingListParser.new(brand, file_path)
    entries = parser.parse
    # TODO: Validar que todos los movimientos de stock sean validos
    #       antes de grabar en al base de datos. Creo que en el caso de los
    #       imports, lo mas sano va a ser se "graba todo_" o 
    #       "no se graba nada."
    #       De esta forma, si algun registro tiene un error lo pueden corregir
    #       a manopla en el Excel y re-intentar la operacion.
    Stock.create(entries, user)
    { ok: true }
  rescue Exception => ex
    { ok: false, errors: [ex.message] }
  end

  def self.create(entries, user)
    entries.each do |entry|
      next unless entry.units

      adjust(entry.brand, entry.sku, entry.units.abs, user, "Mass Import")
    end
  end

  def self.buy(brand, sku, units, user, comments="")
    t = StockTransaction.new(
      brand: brand,
      style: sku.style, color: sku.color, size: sku.size,
      kind: KIND_IN, units: units.abs, reason: Reason::BUY, 
      comments: comments)

    save_transaction(t, user)
  end

  def self.sale(brand, sku, units, user, comments="")
    t = StockTransaction.new(
      brand: brand,
      style: sku.style, color: sku.color, size: sku.size, 
      kind: KIND_OUT, units: units.abs, reason: Reason::SALE, 
      comments: comments)

    save_transaction(t, user)
  end

  def self.adjust(brand, sku, units, user, comments="")
    t = StockTransaction.new(
      brand: brand,
      style: sku.style, color: sku.color, size: sku.size, 
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

  private

  def self.save_transaction(t, user)
    t.user = user
    t.save ? Result.new(true, t.id, nil) : Result.new(false, -1, t.errors)
  end

  def self.collect_transactions_by(brand, sku)
    StockTransaction.where(
      brand_id: brand.id, style: sku.style, color: sku.color, size: sku.size)
  end
end