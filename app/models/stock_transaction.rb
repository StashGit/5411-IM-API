class StockTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :brand
  validates_presence_of :size_order
end
