class Image < ApplicationRecord
  def describe
    image_description.new(self.id, self.s3_key, self.url)
  end

  private

  def image_description
    @image_description ||= Struct.new(:id, :s3_key, :url)
  end
end
