class Qrcode < ApplicationRecord
  include ::Qr

  def create_img
    uid  = create_qr_code_for_id(id: self.id)
    path = Rails.root.join('public', 'qr', uid)
    self.update!(path: path)
  end

  def print
    # El metodo print se tiene que ejecutar con un delayed job.
    create_img unless self.path

    pdf_name = Label::create(
      qr_path:  self.path, 
      style: self.style, 
      size:  self.size,
      color: self.color)
    
    pdf_path = File.join(Label::labels_path, pdf_name.pdf_path)
    puts "TODO: Send #{pdf_path} to the printer via delayed job."
  end

  def self.print_all qrcodes
    # En este caso no usamos el clasico ok, errors porque la impresion en si
    # la vamos a manejar con un delayed job.
    qrcodes.each { |qr| qr.print }
  end
end
