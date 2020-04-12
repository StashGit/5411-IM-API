class Qrcode < ApplicationRecord
  include ::Qr

  def create_img
    uid  = create_qr_code_for_id(id: self.id)
    path = Rails.root.join('public', 'qr', uid)
    self.update!(path: path)
  end

  def print opts={}
    # Esto es async. Envia el job a la cola de impresion.
    PrintLabelJob.perform_later(self, opts)
  end

  def self.print_all qrcodes, opts={}
    # En este caso no usamos el clasico [ok, errors] porque la impresion en si
    # la vamos a manejar con un delayed job.
    qrcodes.each { |qr| qr.print(opts) }
  end
end
