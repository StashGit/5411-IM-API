module S3Helper
  BUCKET = ENV['APP_S3_BUCKET'] || 'test-bucket'

  # Returns [s3_key, public_url]
  def upload_to_s3(file)
    return unless file&.original_filename

    s3_key = create_unique_file_name(file.original_filename)
    upload_public_file s3_key, file
  end

  private

  def app_s3_bucket
    s3.bucket(BUCKET)
  end

  # @param [String] s3_key
  # @param [File] file
  def upload_public_file(s3_key, file)
    obj = app_s3_bucket.object(s3_key)
    obj.upload_file(file)
    make_object_public s3_key
    [s3_key, obj.public_url]
  end

  def make_object_public(s3_key)
    aws_client.put_object_acl({
      acl: "public-read",
      bucket: BUCKET,
      key: s3_key,
    })
  end

  def s3_region
    ENV['APP_S3_REGION']
  end

  def s3_access_key
    ENV['APP_S3_ACCESS_KEY']
  end

  def s3_secret
    ENV['APP_S3_SECRET']
  end

  def aws_client
    @aws_cli ||= Aws::S3::Client.new(
      region: s3_region,
      access_key_id: s3_access_key,
      secret_access_key: s3_secret,
    )
  end

  def s3
    @s3 ||= Aws::S3::Resource.new(
        region: s3_region,
        access_key_id: s3_access_key,
        secret_access_key: s3_secret,
      )
  end

  def create_unique_file_name(original_filename)
   fullname = original_filename.gsub /\ /, "-"
   ext = File.extname(fullname)
   name = File.basename(fullname, ext)
   "#{name}_#{SecureRandom.hex}.#{ext}"
  end

end
