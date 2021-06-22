class Stock
  extend SizeNameSorter
  KIND_IN  = 1
  KIND_OUT = -1

  # Parsea un packing list y genera todas las transacciones necesarias para
  # ingresar los productos de esa lista al stock.
  def self.import(brand, file_path, user)
    entries = parse_packing_list(brand, file_path)

    if StockEntry.all_valid? entries
      ok, ids, errors = Stock.create(brand, file_path, entries, user)

      # Dado que validamos los registros antes de generar la transaccion,
      # no deberiamos tener ningun error. De todas formas, en el caso de que se
      # produzca algun error, lo que hacemos es loguearlo en el server y
      # retornar la lista de errores al codigo cliente para que la manejen
      # desde el front.
      puts errors unless ok
      { ok: true, errors: errors, token: create_token(ids).hashcode }
    else
      # puts StockEntry.select_invalid entries
      # TODO: Con un poco mas de tiempo aca podemos mostrar informacion
      # detallada. Por ejemplo, que fila tiene datos incorrectos y cosas por el
      # esitlo.
      { ok: true, errors: ["Failed to import the packing list. The list contains invalid records."] }
    end
  rescue Exception => ex
    puts ex.message
    { ok: false, errors: [ex.message] }
  end

  def self.create(brand, pl_path, entries, user)
    ids = []
    errors = []

    pl = PackingList.create! path: pl_path, brand: brand
    entries.each do |entry|
      next unless entry.units

      res = adjust(entry.brand, entry.sku, entry.units.to_i, user,
        reason: "Mass Import", size_order: entry.size_order, pl: pl)

      if res.ok
        ids << res.id
      else
        errors << t.errors
      end
    end
    [errors.count == 0, ids, errors]
  end

  def self.create_token(ids)
    hs = nil
    begin
      hs = SecureRandom.hex
    end while Token.find_by_hashcode hs
    Token.create! hashcode: hs, value: ids.to_json
  end

  def self.buy(brand, sku, units, user, comments="")
    t = StockTransaction.new(
      brand: brand,
      style: sku.style,
      color: sku.color,
      size: sku.size,
      code: sku.code,
      box_id: sku.box_id,
      reference_id: sku.reference_id,
      size_order: size_order_for(sku.size),
      kind: KIND_IN,
      units: units.to_i,
      reason: Reason::BUY,
      comments: comments)

    save_transaction(t, user)
  end

  def self.sale(brand, sku, units, user, comments="")
    t = StockTransaction.new(
      brand: brand,
      style: sku.style,
      color: sku.color,
      size:  sku.size,
      code:  sku.code,
      box_id: sku.box_id,
      reference_id: sku.reference_id,
      size_order: size_order_for(sku.size),
      kind: KIND_OUT,
      units: units.to_i,
      reason: Reason::SALE,
      comments: comments
    )

    save_transaction(t, user)
  end

  def self.adjust(brand, sku, units, user, comments="", size_order: nil, reason: nil, pl: nil)
    t = StockTransaction.new \
      brand:           brand,
      style:           sku.style,
      color:           sku.color,
      size:            sku.size,
      code:            sku.code,
      box_id:          sku.box_id,
      reference_id:    sku.reference_id,
      packing_list_id: pl&.id,
      size_order:      size_order || size_order_for(sku.size),
      units:           units.to_i,
      reason:          reason,
      comments:        comments

    t.kind  = units > 0 ? KIND_IN : KIND_OUT
    save_transaction(t, user)
  end

  def self.move(brand, sku_from, sku_to, units, user, comments="", size_order=nil)
    StockTransaction.transaction do
      StockTransaction.create! \
        brand:        brand,
        style:        sku_from.style,
        color:        sku_from.color,
        size:         sku_from.size,
        code:         sku_from.code,
        box_id:       sku_from.box_id,
        reference_id: sku_from.reference_id,
        size_order:   size_order || size_order_for(sku_from.size),
        units:        units.to_i,
        reason:       Reason::MOVE,
        comments:     comments,
        kind:         KIND_OUT,
        user: user

      StockTransaction.create! \
        brand:        brand,
        style:        sku_to.style,
        color:        sku_to.color,
        size:         sku_to.size,
        code:         sku_to.code,
        box_id:       sku_to.box_id,
        reference_id: sku_to.reference_id,
        size_order:   size_order || size_order_for(sku_to.size),
        units:        units.to_i,
        reason:       Reason::MOVE,
        comments:     comments,
        kind:         KIND_IN,
        user: user
    end
    return Result.new(true, StockTransaction.last.id, nil)

    rescue ActiveRecord::Rollback => e
      return Result.new(false, -1, e.message)
  end

  # TODO: Better name!!!
  def self.sku_description
    @@sku_description ||= Struct.new(:sku, :units)
  end

  def self.move_description
    @@move_description ||= Struct.new(:from, :to)
  end

  def self.describe_move(brand, sku_from, sku_to)
    units_from = units(brand, sku_from)
    units_to   = units(brand, sku_to)

    from = sku_description.new(sku_from, units_from)
    to   = sku_description.new(sku_to, units_to)

    move_description.new(from, to)
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

  def self.stock_entry
    @@stock_entry ||= Struct.new :style, :code, :color, :sizes
  end

  def self.size_entry
    @@size_entry ||= Struct.new \
      :size, :size_order, :units, :reference_id, :box_id, :status, :kind
  end

  def self.compute_transactions(brand_id, damaged_only: false)
    sql = prepare_compute_transactions_query(brand_id, damaged_only)

    rows = StockTransaction.connection.execute sql

    result = []
    last_sku  = {}
    rows.each do |row|
      sku = { style: row["style"], code: row["code"], color: row["color"] }
      if sku != last_sku
        last_sku = sku
        result << stock_entry.new(*sku.values, [])
      end

      if row["kind"] == KIND_OUT
        row["units"] = row["units"].to_i * -1
      end

      result.last.sizes << size_entry.new(
        row["size"],
        row["size_order"],
        row["units"],
        row["reference_id"],
        row["box_id"],
        row["status"],
        row["kind"]
      )
    end

    merge_boxes(result)
  end

  def self.merge_boxes stock_entries
    result = []

    stock_entries.each do |entry|
      result << stock_entry.new(
        entry.style, entry.code, entry.color, [])

      merged_sizes = merge_sizes(entry)

      result.last.sizes = sort_by_size_order(merged_sizes).values
    end

    sum_boxes_by_ref_id result
  end

  def self.merge_sizes entry
    {}.tap do |merged_sizes|
      entry.sizes.each do |size_entry|
        size = size_entry.size

        unless merged_sizes.key?(size)
          merged_sizes[size] = size_details.new \
            size, size_entry.size_order, 0, []
        end
        merged_sizes[size].boxes << box.new(
          size_entry.reference_id, size_entry.box_id, size_entry.units)

        # Si se trata de una tranasccion de **salida**, en este punto **units**
        # contiene un valor **negativo**. Por ese motivo, no hacemos ningun
        # chequeo sobre el tipo de transaccion.
        merged_sizes[size].total_units += size_entry.units || 0
      end
    end
  end

  private

  def self.box
    @@box ||= Struct.new :reference_id, :box_id, :units
  end

  def self.size_details
    @@size_details ||= Struct.new :size, :size_order, :total_units, :boxes
  end

  def self.prepare_compute_transactions_query(brand_id, damaged_only)
    reason_clause =
      if damaged_only
        "reason =  '#{Reason::DAMAGED}'"
      else
        # En este caso queremos todos los tipos de transaccion para que
        # descuente correctamente los productos danados.
        # "reason <> '#{Reason::DAMAGED}'"
        "1 = 1"
      end

    # La consulta original tenia este group by, pero aparentemente
    # no agrega nada al resultado...
    # GROUP BY id, style, code, color, size, reference_id, box_id
    %{
      SELECT id, style, code, color, size, size_order,
             units, kind, status,
             COALESCE(reference_id, 'NO REF') reference_id,
             COALESCE(box_id,'NO BOX') box_id,
             reason
      FROM stock_transactions
      WHERE brand_id=#{brand_id}
      /* We only want active transactions*/
      AND (status IS NULL OR NOT status IN ('hidden', 'deleted'))
      AND #{reason_clause}
      ORDER BY style, code, color, size, reference_id, box_id
    }
  end

  # TODO: Revisar este metodo. Ver con Andrew si esta es la estructura definitiva
  #       y si funciona para todos los casos que tenemos que soportar.
  #       Para la demo, parece que va.
  def self.sum_boxes_by_ref_id entries
    entries.each do |entry|
      entry.sizes.each do |size|
        size.boxes.sort_by! &:reference_id
      end

      # boxes are sorted by ref_id
      entry.sizes.each do |size|
        size.boxes = size.boxes.group_by &:box_id
      end

      entry.sizes.each do |size|
        boxes = []
        size.boxes.each do |box_id, grouped_boxes|
          next unless grouped_boxes

          ref_id = grouped_boxes.first.reference_id
          sum = grouped_boxes.inject(0) { |acc, box| acc += box.units }
          boxes << box.new(ref_id, box_id, sum)
        end
        size.boxes = boxes
      end
    end

    entries
  end

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
      PackingListParserTemplate,
      PackingListParserMulti,
    ]
  end

  def self.save_transaction(t, user)
    t.user = user
    t.save ? Result.new(true, t.id, nil) : Result.new(false, -1, t.errors)
  end

  def self.collect_transactions_by(brand, sku)
    StockTransaction.where \
      brand_id: brand.id,
      style: sku.style,
      color: sku.color,
      size: sku.size,
      code: sku.code,
      box_id: sku.box_id,
      reference_id: sku.reference_id
  end
end
