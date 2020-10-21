class StockTransaction < ApplicationRecord
  HIDDEN = 'hidden'

  belongs_to :user
  belongs_to :brand
  validates_presence_of :size_order
  validates :reason, numericality: true

  scope :active, -> { where("status IS NULL OR NOT status IN (?)", HIDDEN) }

  def self.hide(brand_id:, style:, color:, size:, code: nil)
    transactions = StockTransaction.where \
     brand_id: brand_id,
     style:    style.to_s.upcase,
     color:    color.to_s.upcase,
     size:     size.to_s.upcase,
     code:     code.present? ? code.to_s.upcase : nil

    transactions.update_all status: HIDDEN
  end

  def reason=(value)
    # Si especifican un valor fuera de rango, utilizamos OTHER.
    reason = value&.to_i
    reason = Reason::OTHER unless (1..7).include?(reason)
    super reason.to_s
  end

  # Limite de entradas que retornamos cuando nos piden el registro
  # de transacciones.
  LOG_SIZE = 50

  def self.log
    sql = %(
      SELECT s.*, u.email 
      FROM stock_transactions s, users u
      WHERE s.user_id = u.id
      ORDER BY created_at DESC
      LIMIT #{LOG_SIZE}
    )

    ActiveRecord::Base.connection.execute(sql)
  end
end
