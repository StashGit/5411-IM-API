class Stock
  include TransactionKind
  
  def self.units(style:, color:, size:)
    transactions = StockTransactions.where(style: style, color: color, size: size)
    ins=0
    outs=0
    transactions.each do |t|
      if t.type == TRANSACTION_IN
        ins += 1
      elsif t.type == TRANSACTION_IN
        outs += 1
      else
        raise "Unknow transaction kind."
      end
    end
    ins - outs
  end
end