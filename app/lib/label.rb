module Label
  # Un punto importante a tener en cuenta es que Pawn no usa el tipico 
  # esquema top/left partiendo del margen superior izquierdo de la pagina. 
  # Lo que hacen ellos es partir del centro de la hoja. 
  # Todas las coordenadas con relativas a ese punto central y no al clasico 
  # top/left al que estamos acostumbrados.

  HEIGHT      =  72 #<- 1   Inch.
  WIDTH       = 108 #<- 1.5 Inches.
  LEFT        = -33
  TEXT_START  = -19
  TEXT_SIZE   =   6
  LINE_HEIGHT =  -7

  def self.create(qr_path:, style:, color:, size:) 
    result = Struct.new(:ok, :pdf_path, :errors)
    begin
      pdf_path = pdf_path_from(qr_path)

      Prawn::Document.generate(
        pdf_path,
        page_size: [HEIGHT, WIDTH], 
        page_layout: :landscape) do
          image qr_path, width: 68, at: [LEFT - 11, 44]
          current_line = TEXT_START
          draw_text style, at: [LEFT, current_line], size: TEXT_SIZE

          current_line += LINE_HEIGHT
          draw_text color, at: [LEFT, current_line], size: TEXT_SIZE

          current_line += LINE_HEIGHT
          draw_text size,  at: [LEFT, current_line], size: TEXT_SIZE
        end
      filename = File.basename(pdf_path)
      result.new(true, filename, [])
    rescue Exception => ex
      result.new(false, nil, [ex.message])
    end
  end

  def self.pdf_path_from(qr_path)
    filename = File.basename(qr_path)
    File.join(labels_path, filename.gsub(".png", ".pdf"))
  end

  def self.labels_path
    path = File.join("public", "labels")
    FileUtils.mkdir(path) unless Dir.exists?(path)
    path
  end
end