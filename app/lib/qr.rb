module Qr
  SEP = "~"
  FILLER = '^'
  STR_SIZE = 100
  IMG_SIZE = 180

  @@root_path = nil

  def set_qr_root path
    @@root_path = path
  end

  def create_qr_code_for_id(id:)
    content = id.to_s.rjust(10, '0')
    uid     = "#{content}.png"
    create_qr(content, uid, 90)
  end

  def create_qr_code(brand_id:, style:, color:, size:)
    ensure_args_present! brand_id, style, color, size

    content = "#{brand_id}#{SEP}#{style}#{SEP}#{color}#{SEP}#{size}#{SEP}".
      ljust(STR_SIZE, FILLER)

    uid = create_uid(brand_id, style, color, size)
    create_qr(content, uid)
  end

  def delete_all
    FileUtils.rm_rf(qr_dir)
    :ok
  end

  private

  def create_qr content, uid, size = nil
    qrcode = RQRCode::QRCode.new(content)
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: size || IMG_SIZE,
    )
    save_qr(png, qr_path(uid))
    uid
  end

  def create_uid(brand_id, style, color, size)
    "#{brand_id}_#{style}_#{color}_#{size}.png".gsub " ", "_"
  end

  def ensure_args_present!(brand_id, style, color, size)
    # no utilizamos present? para que se posible consumir esta lib
    # desde los servicios que tenemos fuera de rails.
    raise "brand_id is required" unless brand_id
    raise "style is required"    unless style
    raise "color is required"    unless color
    raise "size is required"     unless size
  end

  def save_qr(png, path)
    # Si el QR ya existe, no-op.
    IO.binwrite(path, png.to_s) unless File.exists?(path)
    path
  end

  def qr_dir
    path = ""
    if @@root_path
      path = File.join(@@root_path, "qr")
    else
      path = Rails.root.join('public', 'qr')
    end
    FileUtils.mkdir(path) unless Dir.exists?(path)
    path
  end

  def qr_path(uid)
    path = File.join(qr_dir, uid.to_s)
    path.gsub " ", "_"
  end
end
