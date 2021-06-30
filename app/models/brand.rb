class Brand < ApplicationRecord
  def soft_delete(user)
    update! deleted: 1, user_id: user.id
  end

  def deleted?
    self.deleted == 1
  end

  def describe
  	brand_description.new(id, name)
  end

  def brand_description
  	@brand_description ||= Struct.new(:id, :name)
  end

  def stock_transactions
    StockTransaction.where(brand_id: self.id)
  end

  def active_stock_transactions
    StockTransaction.active.where(brand_id: self.id)
  end

  # Soft delete stock transactions for the brand.
  def delete_stock_transactions
    ids = active_stock_transactions.collect &:id
    StockTransaction.where(id: ids).update(status: StockTransaction::DELETED)
  end

  def to_s
    "#{name} (#{id})"
  end
end
