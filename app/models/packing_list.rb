class PackingList < ApplicationRecord
  ACTIVE  = 1
  DELETED = 2

  validates  :path, presence: true

  belongs_to :brand, optional: true
  has_many   :stock_transactions

  scope      :active, -> { where(status: [ACTIVE]) }
  before_validation :set_default_status

  def self.describe_active_lists brand
    return PackingList.active.map &:describe unless brand.present?
    PackingList.active.where(brand: brand).map &:describe
  end

  def describe
    pl_description.new(id, brand&.describe, File.basename(path), created_at)
  end

  private

  def pl_description
    @pl_description ||= Struct.new(:id, :brand, :path, :created_at)
  end

  def set_default_status
    return unless new_record?

    self.status = ACTIVE unless self.status.present?
  end
end
