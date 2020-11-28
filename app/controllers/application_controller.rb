class ApplicationController < ActionController::Base
  def set_access_token
    token = request.headers["Access-Token"]
    @token = ApiKey.find_by_access_token(token)
    puts "access-token: #{@token}"
  end

  def upload_file file, dir=uploads_dir
    return unless file&.original_filename

    path = dir.join(file.original_filename)
    File.open(path, 'wb') do |f|
      f.write(file.read)
    end
    path.to_s
  end

  def upload_logo file
    upload_file file, logos_dir
  end

  def logos_dir
    create_dir_if_not_exists Rails.root.join('public', 'logos')
  end

  def uploads_dir
    create_dir_if_not_exists Rails.root.join('public', 'uploads_dir')
  end

  def create_dir_if_not_exists path
    Dir.mkdir(path) unless Dir.exist?(path)
    path
  end
end
