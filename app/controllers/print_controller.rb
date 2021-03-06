class PrintController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_access_token

  def enqueue
    # Para saber como obtener el ID de los codigos QR, ver qr/encode-decode.
    # jobs: [{ qr_id: 1, copies: 2 }, { qr_id: 2, copies: 2 }]
    ok, errors = QrQueue.enqueue params[:jobs]
    if ok
      render :json => { message: "Success!" }, :status => 200
    else
      render :json => { errors: errors }, :status => 400
    end
  end

  def dequeue 
    # Por medio de los jobs_ids podemos marcar todos los items que ya fueron
    # impresos.
    # Los jobs_ids los obtenemos consultando el metodo "pending"
    ok, errors = QrQueue.dequeue params[:jobs_ids]
    if ok
      render :json => { message: "Success!" }, :status => 200
    else
      render :json => { errors: errors }, :status => 400
    end
  end

  def dequeue_all
    # Marca todos los items de la cola como impresos.
    ok, errors = QrQueue.dequeue_all
    if ok
      render :json => { message: "Success!" }, :status => 200
    else
      render :json => { errors: errors }, :status => 400
    end
  end

  def pending
    render :json => { jobs: QrQueue.pending }, :status => 200
  end

  def pending_jobs_ids
    render :json => { jobs_ids: QrQueue.pending_jobs_ids }, :status => 200
  end
end
