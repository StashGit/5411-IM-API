class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true

  def is_admin?
    self.is_admin
  end

  def create_api_key
    ApiKey.create! user_id: self.id
  end
end
