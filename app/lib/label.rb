module Label
  # Un punto importante a tener en cuenta es que Pawn no usa el tipico 
  # esquema top/left partiendo del margen superior izquierdo de la pagina. 
  # Lo que hacen ellos es partir del centro de la hoja. 
  # Todas las coordenadas con relativas a ese punto central y no al clasico 
  # top/left al que estamos acostumbrados.

  HEIGHT      =  72 #<- 1   Inch.
  WIDTH       = 108 #<- 1.5 Inches.
  LEFT        =   6
  TEXT_START  =   6
  TEXT_SIZE   =   6
  LINE_HEIGHT =  -7
  IMG_TOP     = 38

  @@root_path = nil

  def set_lbl_root path
    @@root_path = path
  end

  def self.experimental_create(qr_path:, style:, color:, size:) 
    result = Struct.new(:ok, :pdf_path, :errors)
    begin
      pdf_path = pdf_path_from(qr_path)

      Prawn::Document.generate(
        pdf_path,
        page_size: [HEIGHT * 2, WIDTH * 2], 
        page_layout: :portrait) do
          image qr_path, width: 80, at: [LEFT - 48, 180]
          current_line = 94
          draw_text style, at: [LEFT - 36, current_line], size: TEXT_SIZE * 2

          current_line += LINE_HEIGHT * 2
          draw_text color, at: [LEFT - 36, current_line], size: TEXT_SIZE * 2

          current_line += LINE_HEIGHT * 2
          draw_text size,  at: [LEFT - 36, current_line], size: TEXT_SIZE * 2
        end
      filename = File.basename(pdf_path)
      result.new(true, filename, [])
    rescue Exception => ex
      result.new(false, nil, [ex.message])
    end
  end

  def self.create(qr_path:, style:, color:, size:) 
    # En base a las pruebas que hicimos con Andrew, esta es la configuracion
    # que va. (En el preview se ve medio bizarra, pero cuando se manda a
    # imprimir, sale bien.)
    return self.experimental_create(qr_path, style, color, size)

    # create original
    # Este metodo no genera las etiquetas correctamente cuando 
    # la impresora esta conectada a la mac.
    # 
    # result = Struct.new(:ok, :pdf_path, :errors)
    # begin
    #   pdf_path = pdf_path_from(qr_path)
    #
    #   Prawn::Document.generate(
    #     pdf_path,
    #     page_size: [HEIGHT, WIDTH], 
    #     page_layout: :landscape) do
    #       image qr_path, width: 50, at: [LEFT - 7, 38]
    #       current_line = TEXT_START
    #       draw_text style, at: [LEFT, current_line], size: TEXT_SIZE
    #
    #       current_line += LINE_HEIGHT
    #       draw_text color, at: [LEFT, current_line], size: TEXT_SIZE
    #
    #       current_line += LINE_HEIGHT
    #       draw_text size,  at: [LEFT, current_line], size: TEXT_SIZE
    #     end
    #   filename = File.basename(pdf_path)
    #   result.new(true, filename, [])
    # rescue Exception => ex
    #   result.new(false, nil, [ex.message])
    # end
  end

  def self.pdf_path_from(qr_path)
    filename = File.basename(qr_path)
    File.join(labels_path, filename.gsub(".png", ".pdf"))
  end

  def self.labels_path
    path = ""
    
    if @@root_path
      path = File.join(@@root_path, "labels")
    else
      path = File.join("public", "labels")
    end

    FileUtils.mkdir(path) unless Dir.exists?(path)
    path
  end
end
