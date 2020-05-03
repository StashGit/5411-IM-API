class QrQueue < ApplicationRecord
  # jobs = [{qr_id: 123, copies: 2}, {...}]
  def self.enqueue jobs
    QrQueue.transaction do
      jobs.each { |job| 
        QrQueue.create!(
          qr_id:  job["qr_id"], 
          copies: job["copies"], 
          printed: false)
      }
    end
    return [true, nil]
  rescue ActiveRecord::ActiveRecordError => ex
    return [false, [ex.message]]
  end

  # jobs_ids = [123, 456, etc...]
  def self.dequeue jobs_ids
    jobs = QrQueue.where(id: jobs_ids)
    QrQueue.transaction do
      jobs.each { |job| job.update! printed: true }
    end
    return [true, nil]
  rescue ActiveRecord::ActiveRecordError => ex
    return [false, [ex.message]]
  end

  def self.dequeue_all
    QrQueue.update_all printed: true
    [true, nil]
  rescue ActiveRecord::ActiveRecordError => ex
    return [false, [ex.message]]
  end

  # Retorna la lista items que tenemos que imprimir. Esta lista contiene todos
  # los datos del codigo QR y la cantidad de copias que tenemos que imprimir en
  # cada caso.
  # Este metodo tambien retorna el job_id que tenemos que utilizar para remover
  # el job de la cola de impresion.
  # [
  #   {
  #     qr: { brand_id: 1, style: 'GRACE', color: 'RED',  size: 'S' },
  #     copies: 3,
  #     job_id: 1
  #   },
  #   { 
  #     qr: { brand_id: 1, style: 'SPACE', color: 'BLUE', size: 'M' },
  #     copies: 1,
  #     job_id: 2
  #   }
  # ]
  def self.pending
    pending_jobs = QrQueue.where(printed: false)
    label  = Struct.new(:qr, :copies, :job_id)
    result = []
    pending_jobs.each do |job|
      qr = Qrcode.find_by(id: job.qr_id)
      if qr.present?
        # job_id nos permite remover el job cuando finaliza la impresion.
        result << label.new(qr, job.copies, job.id)
      end
    end
    result
  end

  def self.pending_jobs_ids
    self.pending.collect(&:job_id)
  end
end
