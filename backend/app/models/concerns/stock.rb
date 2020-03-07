class Stock
  KIND_IN  = 1
  KIND_OUT = -1

  def self.import xls
    raise "Not Impl."
  end

  def self.buy(sku, units, user, comments="")
    t = StockTransaction.new(style: sku.style,
                             color: sku.color,
                             size: sku.size,
                             kind: KIND_IN,
                             units: units,
                             reason: Reason::BUY,
                             comments: comments)
    save_transaction(t, user)
  end

  def self.sale(sku, units, user, comments="")
    t = StockTransaction.new(style: sku.style, 
                             color: sku.color,
                             size: sku.size,
                             kind: KIND_OUT,
                             units: units,
                             reason: Reason::SALE,
                             comments: comments)
    save_transaction(t, user)
  end

  def self.adjust(sku, units, user, comments="")
    t = StockTransaction.new(style: sku.style, 
                             color: sku.color,
                             size: sku.size,
                             reason: Reason::ADJUSTMENT,
                             comments: comments)

    t.kind  = units > 0 ? KIND_IN : KIND_OUT
    t.units = units.abs
    save_transaction(t, user)
  end

  # This method computes all stock transactions for a given SKU.
  def self.units(sku)
    # TODO: Bound the query to a date range. (This is not a problem right
    #       now, but it might be depending on the number of transactions.)
    transactions = collect_transactions_by(sku)
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

  def self.collect_transactions_by(sku)
    StockTransaction.where(style: sku.style, color: sku.color, size: sku.size)
  end
end
