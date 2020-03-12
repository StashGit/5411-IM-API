module Qr
  SEP = "~"

  def create_qr_code(brand_id:, style:, color:, size:)
    qrcode = RQRCode::QRCode.new(
      "#{brand_id}#{SEP}#{style}#{SEP}#{color}#{SEP}#{size}")
    svg = qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
  end
end
