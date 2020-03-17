class Brand < ApplicationRecord
  def soft_delete(user)
    update! deleted: 1, user_id: user.id
  end

  def deleted?
    self.deleted == 1
  end

  def to_s
    "#{name} (#{id})"
  end
end
