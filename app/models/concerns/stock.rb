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

      res = adjust(entry.brand, entry.sku, entry.units.abs, user,
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
      units: units.abs,
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
      units: units.abs,
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
      units:           units.abs,
      reason:          reason,
      comments:        comments

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

  def self.stock_entry
    @@stock_entry ||= Struct.new :style, :code, :color, :status, :kind, :sizes
  end

  def self.size_entry
    @@size_entry ||= Struct.new \
      :size, :size_order, :units, :reference_id, :box_id
  end

  def self.compute_transactions_grouping_by_box_id(brand_id)
    sql = %{
      SELECT id, style, code, color, size, size_order,
             reference_id, box_id, units, kind, status
      FROM stock_transactions
      WHERE brand_id=#{brand_id}
      /* We only want active transactions*/
      AND (status IS NULL OR NOT status IN ('hidden', 'deleted'))
      GROUP BY id, style, color, size, reference_id, box_id
      ORDER BY size, reference_id, box_id
    }
    rows = StockTransaction.connection.execute sql

    result = []
    last_sku  = {}
    rows.each do |row|
      sku = { style: row["style"], code: row["code"], color: row["color"] }
      if sku != last_sku
        last_sku = sku
        result << stock_entry.new(*sku.values, row["status"], row["kind"], [])
      end
      result.last.sizes << size_entry.new(
        row["size"],
        row["size_order"],
        row["units"],
        row["reference_id"],
        row["box_id"])
    end

    merge_boxes(result)
  end

  def self.merge_boxes entries
    result = []
    box    = Struct.new :reference_id, :box_id, :units
    size_details = Struct.new :size, :size_order, :total_units, :boxes

    entries.each do |entry|
      result << stock_entry.new(
        entry.style, entry.code, entry.color, entry.status, entry.kind, [])

      merged_sizes = {}
      entry.sizes.each do |size_entry|
        size = size_entry.size
        unless merged_sizes.key?(size)
          merged_sizes[size] = size_details.new \
            size, size_entry.size_order, 0, []
        end
        merged_sizes[size].boxes << box.new(
          size_entry.reference_id, size_entry.box_id, size_entry.units)

        if entry.kind == KIND_IN
          merged_sizes[size].total_units += size_entry.units || 0
        else
          merged_sizes[size].total_units -= size_entry.units || 0
        end
      end
      result.last.sizes = merged_sizes.values
    end

    sum_boxes_by_ref_id result
  end

  private

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

      box = Struct.new :reference_id, :box_id, :units
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

    # boxes: [
    #   {"reference_id":"PO123","box_id":"BOX 1","units": 2},
    #   {"reference_id":"PO123","box_id":"BOX 1","units": 2},
    #   {"reference_id":"PO222","box_id":"BOX 1","units":10},
    # ]
    # out:
    # [PO123][BOX1] =  4
    # [PO222][BOX1] = 10
    # return sorted_by_ref_id
    # raise "hell"
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

  # TODO: En lugar de hacer esto tenemos que tener una vista materializada
  #       que nos permita hacer un select * y a otra cosa mariposa.
  #       Con muchas transacciones de stock esto se puede llegar a clavar.
  #       Si podemos cocinar la vista a medida que vamos grabando mejor.
  def self.compute_transactions_by(brand)
    res = []
    collect_skus_by(brand).each do |entry|
      sku, order, status = entry
      res << {
        sku: sku,
        units: units(brand, sku),
        size_order: order,
        status: status
      }
    end
    res
  end

  def self.collect_skus_by(brand)
    # Como agregamos el campo "status" volvimos a listar todas las transacciones.
    sts = StockTransaction.where(brand_id: brand.id)
    tmp = sts.collect { |t|
      [
        {
          style: t.style, color: t.color, size: t.size, code: t.code,
          reference_id: t.reference_id, box_id: t.box_id
         },
        t.size_order,
        t.status
      ]
    }.uniq

    tmp.collect { |entry|
      sku, order, status = entry
      [Sku.new(**sku), order, status]
    }
  end
end
