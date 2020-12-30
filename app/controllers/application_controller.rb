class ApplicationController < ActionController::Base
  include S3Helper

  def set_access_token
    token = request.headers["Access-Token"]
    @token = ApiKey.find_by_access_token(token)
    puts "access-token: #{@token}"
  end

  # Dejamos este metodo para subir archivos temporales (e.g., las packing lists)
  # y agregamos otro metodo para subir archivos "persistentes" a S3.
  def upload_file file, dir=uploads_dir
    return unless file&.original_filename

    path = dir.join(file.original_filename)
    File.open(path, 'wb') do |f|
      f.write(file.read)
    end
    path.to_s
  end

  # Sube el logo a S3 y retorna la **public** key.
  def upload_logo file
    upload_to_s3 file
  end

  private

  def uploads_dir
    create_dir_if_not_exists Rails.root.join('public', 'uploads_dir')
  end

  def create_dir_if_not_exists path
    Dir.mkdir(path) unless Dir.exist?(path)
    path
  end
end
