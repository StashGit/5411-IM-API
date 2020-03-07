class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true

  def is_admin?
    self.is_admin
  end
end
