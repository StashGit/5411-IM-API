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

  def to_s
    "#{name} (#{id})"
  end
end
