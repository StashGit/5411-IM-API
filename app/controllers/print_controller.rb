class PrintController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def enqueue
    # Para saber como obtener el ID de los codigos QR ver qr/encode-decode
    # labels: [{ qr_id: 1, copies: 2 }, { qr_id: 2, copies: 2 }]
    ok = QrQueue.enqueue params[:labels]
    if ok
      render :json => { message: "Success!" }, :status => 200
    else
      render :json => { errors: [ "Failed to enqueue QR codes."] }, :status => 400
    end
  end

  def dequeue 
    # ID del codigo QR en el queue (No es el ID del QR en si.)
    ok = QrQueue.dequeue params[:qrq_ids]
    if ok
      render :json => { message: "Success!" }, :status => 200
    else
      render :json => { errors: [ "Failed to dequeue QR codes."] }, :status => 400
    end
  end

  def pending
    render :json => QrQueue.pending, :status => 200
  end
end
