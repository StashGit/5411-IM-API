module QR
  SEP = "~"

  def create_qr_code(brand:, style:, color:, size:)
    puts ">>>> cede"
    qrcode = RQRCode::QRCode.new(
      "#{brand}#{SEP}#{style}#{SEP}#{color}#{SEP}#{size}")
    svg = qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
  end
end
