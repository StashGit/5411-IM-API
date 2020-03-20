module Qr
  SEP = "~"
  FILLER = '^'
  STR_SIZE = 100
  IMG_SIZE = 180

  def create_qr_code(brand_id:, style:, color:, size:)
    ensure_args_present! brand_id, style, color, size

    content = "#{brand_id}#{SEP}#{style}#{SEP}#{color}#{SEP}#{size}#{SEP}".
      ljust(STR_SIZE, FILLER)

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
      size: IMG_SIZE,
    )

    uid = create_uid(brand_id, style, color, size)
    save(png, qr_path(uid))
    uid
  end

  def delete_all
    FileUtils.rm_rf(qr_dir)
    :ok
  end

  private

  def create_uid(brand_id, style, color, size)
    "#{brand_id}_#{style}_#{color}_#{size}.png".gsub " ", "_"
  end

  def ensure_args_present!(brand_id, style, color, size)
    raise "brand_id is required" unless brand_id.present?
    raise "style is required"    unless style.present?
    raise "color is required"    unless color.present?
    raise "size is required"     unless size.present?
  end

  def save(png, path)
    # Si el QR ya existe, no-op.
    IO.binwrite(path, png.to_s) unless File.exists?(path)
    path
  end

  def qr_dir
    path = Rails.root.join('public', 'qr')
    FileUtils.mkdir(path) unless Dir.exists?(path)
    path
  end

  def qr_path(uid)
    "#{qr_dir}/#{uid}".gsub " ", "_"
  end
end
