class Brand < ApplicationRecord
  def to_s
    "#{name} (#{id})"
  end
end
