class ApiKey < ApplicationRecord
  validates :user_id, presence: true
  before_create :generate_access_token

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)

    # At the moment we are not going to check this, but it's
    # nice to have an expiration date. Just in case.
    self.expires_at = 30.days.from_now
  end

  def user
    User.find(self.user_id)
  end
end
