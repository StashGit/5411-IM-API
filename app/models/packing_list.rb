class PackingList < ApplicationRecord
  ACTIVE  = 1
  DELETED = 2

  validates :path, presence: true
  has_many  :stock_transactions
  scope     :active, -> { where(status: [ACTIVE]) }
  before_validation :set_default_status

  def self.describe_active_lists
    PackingList.active.map &:describe
  end

  def describe
    pl_description.new(id, File.basename(path))
  end

  private

  def pl_description
    @pl_description ||= Struct.new(:id, :path)
  end

  def set_default_status
    return unless new_record?

    self.status = ACTIVE unless self.status.present?
  end
end
