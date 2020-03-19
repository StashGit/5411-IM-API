module Qr
  SEP = "~"
  SIZE = 100
  FILLER = '^'

  def create_qr_code(brand_id:, style:, color:, size:)
    content = "#{brand_id}#{SEP}#{style}#{SEP}#{color}#{SEP}#{size}#{SEP}".
      ljust(SIZE, FILLER)

    qrcode = RQRCode::QRCode.new(content)
    svg = qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
  end
end
