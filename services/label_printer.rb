require 'httparty'
require 'json'
require 'rqrcode'
require 'prawn'
require 'fileutils'
require_relative '../app/lib/qr.rb'
require_relative '../app/lib/label.rb'

class Service
  include ::Qr
  include ::Label

  def init
    # Utilizamos un directorio propio del servicio para no tener conflictos con
    # los qrs que generamos en app/public.
    root_path = ENV['PRINT_ROOT'] || "."
    url       = ENV['HOST']  || 'https://stock-api-5411.herokuapp.com/'# 'http://localhost:3000'
    token     = ENV['TOKEN'] || '99310f56f95becb1d9b339151a22c621'

    # Este flag hace que el servicio se ejecute normalmente pero no manda el
    # trabajo la impresora. Solo imprime un mensaje en la terminal.
    # Generalmente solo se usa en sesiones de debug.
    @qrs_path  = File.join(root_path, "qr")
    @lbls_path = File.join(root_path, "labels")
    @printer   = ENV["LBL_PRINTER"]
    @virtual_printing = true

    set_qr_root root_path
    set_lbl_root root_path

    @pending_jobs_url = "#{url}/print/pending"
    @dequeue_jobs_url = "#{url}/print/dequeue"
    @headers = {
      "Content-Type": 'application/json',
      "Access-Token": token
    }
  end

  def success!
    puts "SUCCESS"
    true
  end

  def notify_error message
    puts "ERROR"
    puts message
  end

  def get_jobs
    puts
    puts "Getting jobs..."

    response = HTTParty.get(@pending_jobs_url, headers: @headers)
    if response.code == 200
      jobs = JSON.parse(response.body)["jobs"]
      puts jobs
      success!
      return jobs
    else
      notify_error JSON.parse(response.body)["errors"]
    end
  rescue Exception => ex
    notify_error ex.message
  end

  def print_pdf_label pdf_path, copies
    puts "number of copies: #{copies}"
    puts "file path: #{pdf_path}"

    if @virtual_printing
      puts "VIRTUAL PRINTING IS ON"
      puts "----------------------"
      1.upto copies do |num|
        puts "pringing #{num}"
      end
      puts "----------------------"
    else
      pdf_path = File.join(@lbls_path, pdf_path)
      # Para ver mas opciones sobre el comando print:
      # https://www.cups.org/doc/options.html
      #
      # para ver el estado de la impresora desde la terminal podemos ejecutar:
      # lpstat -p -d
      1.upto copies do |num|
        if @printer
          # `lp -d #{@printer} -o media=Custom.108x72 #{pdf_path}`
          `./sumatra_pdf.exe -print-to-#{@printer} #{pdf_path}`
        else
          # `lp -o media=Custom.108x72 #{pdf_path}`
          `./sumatra_pdf.exe -print-to-default #{pdf_path}`
        end
        puts "ERROR: #{$?.exitstatus} - copy number #{num}" unless $?.success?
        return false unless $?.success?
      end
    end
    true
  end

  def print_label qr_hash, img_path, copies

    # Creamos la etiqueta.
    label = Label::create(
      qr_path:  File.join(@qrs_path, img_path),
      style:    qr_hash["style"], 
      size:     qr_hash["size"],
      color:    qr_hash["color"])
    
    puts "y ahora?"
    if label.ok
      print_pdf_label label.pdf_path, copies
    else
      puts "ERROR creating label for QR ##{qr_hash["id"]}."
      puts "QR's image path ##{img_path}."
      label.errors.each { |e| puts e }
    end
  rescue Exception => ex
    puts ex.message
  end

  def print_labels jobs
    # [
    #   {
    #     "qr":{ "id":305,"brand_id":1,"style":"GRACE","color":"RED","size":"M"},
    #     "copies":2,
    #     "job_id":"123"
    #   }
    # ]
    puts
    puts jobs ? "Printing labels..." : "No jobs on the queue."

    printed_jobs_ids = []
    jobs&.each do |job|
      puts job
      qr_hash = job["qr"]
      # ID-based QR
      qr_id = qr_hash["id"]
      puts "printing qr id: #{qr_id}"
      path = create_qr_code_for_id id: qr_id

      ok = print_label qr_hash, path, job["copies"].to_i
      if ok
        printed_jobs_ids << job["job_id"]
      end
      # No borramos el archivo porque las chances de que quieran volver a
      # imprimir la misma etiqueta son grandes. Actualmente, la libreria que
      # armamos para los QR no hace nada si el arhivo ya existe, con lo cual
      # mejoramos la performance de la impresion dejando los archivos previos
      # ahi.
    end
    success!
    printed_jobs_ids
  rescue Exception => ex
    notify_error ex.message
  end

  def mark_as_printed printed_jobs_ids
    puts
    puts printed_jobs_ids.count > 0 ? "Dequeuing jobs..." : "No jobs to dequeue."
    body = { jobs_ids: printed_jobs_ids }.to_json

    response = HTTParty.post(@dequeue_jobs_url,
                             body: body,
                             headers: @headers)

    if response.code == 200
      success!
    else
      notify_error JSON.parse(response.body)["errors"]
    end
  rescue Exception => ex
    notify_error ex.message
  end

  def do_work
    jobs = get_jobs
    printed_jobs_ids = print_labels(jobs)

    # Solo tenemos que marcar como impresos los que efectivamente logramos
    # imprimir.
    mark_as_printed(printed_jobs_ids)
  end

  def main
    loop do
      begin
        do_work
      rescue Exception => ex
        puts ex
      end

      puts "sleeping..."
      sleep 5
    end
  end
end

service = Service.new
service.init
service.main




