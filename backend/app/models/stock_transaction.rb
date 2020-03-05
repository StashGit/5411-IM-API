require_relative '../../lib/transaction_kind.rb'

class StockTransaction < ApplicationRecord
  include ::TransactionKind

  validates_presence_of :style, :color, :units, :type, :reason, :user_id

  def self.in(style:, color:, size:, units:, created_by:, reason:, comments:)
    txn = new StockTransaction();
    txn.style = style
    txn.color = color
    txn.size = size
    txn.type = TRANSACTION_IN
    txn.units = units
    txn.user_id = created_by.id
    txn.reason = reason
    txn.comments = comments

  end

  def self.out(style:, color:, size:, units:, created_by:, reason:, comments:)
    txn = new StockTransaction();
    txn.style = style
    txn.color = color
    txn.size = size
    txn.type = TRANSACTION_OUT
    txn.units = units
    txn.user_id = created_by.id
    txn.reason = reason
    txn.comments = comments
  end
end
