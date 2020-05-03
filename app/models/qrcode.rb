class Qrcode < ApplicationRecord
  include ::Qr

  def create_img
    uid  = create_qr_code_for_id(id: self.id)
    path = Rails.root.join('public', 'qr', uid)
    self.update!(path: path)
  end

  def print number_of_copies, opts={}
    # Esto es async. Envia el job a la cola de impresion.
    PrintLabelJob.perform_later(self, number_of_copies,  opts)
  end

  def self.mass_prepare params
    # params[:qrs] => [{ id: 1, copies: 1 }, {id: 2, copies: 6 }]
    params[:qrs].collect do |qr|
      { qr: Qrcode.find_by_id(qr[:id]), copies: qr[:copies] }
    end
  end

  def self.create_from_transaction ids
    res = []
    StockTransaction.where(id: ids).each do |st|
      qr = Qrcode.create!(brand_id: st.brand_id,
                          style:    st.style, 
                          color:    st.color,
                          size:     st.size)
      qr.create_img
      res << { qr: qr, copies: st.units }
    end
    res
  end

  def qr_id
    self.id
  end

  def self.print_all qrcodes, opts={}
    # Esta es la estructura que tiene *qrcodes*:
    # qrcodes = [{ qr: qr1, copies: 2 }, { qr: qr2, copies: 3 }]
    qrcodes.each do |e|
      e[:qr].print(e[:copies], opts)
    end
  end
end
