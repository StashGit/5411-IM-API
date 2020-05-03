require 'httparty'
require 'json'
require 'rqrcode'
require 'fileutils'
require_relative '../app/lib/qr.rb'

class Service
include ::Qr

def init
    # Utilizamos un directorio propio del servicio para no tener conflictos con
    # los qrs que generamos en app/public.
    root_path = "/Users/amiralles/dev/stash/5411-IM-API/services"
    url   = ENV['HOST']  || 'http://localhost:3000'
    token = ENV['TOKEN'] || '99310f56f95becb1d9b339151a22c621'

    set_root root_path
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
    success!
    return jobs
  else
    notify_error JSON.parse(response.body)["errors"]
  end
rescue Exception => ex
  notify_error ex.message
end

def print_label path, copies
  puts "copies: #{copies}"
  puts "file:   #{File.join(@@root_path, path)}"
  return true
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
  puts jobs&.count > 0 ? "Printing labels..." : "No jobs on the queue."

  printed_jobs_ids = []
  jobs&.each do |job|
    puts "----"
    qr = job["qr"]
    path = create_qr_code brand_id: qr["brand_id"]&.to_s, 
                          style:    qr["style"], 
                          color:    qr["color"], 
                          size:     qr["size"]

    ok = print_label path, job["copies"].to_i
    if ok
      printed_jobs_ids << job["job_id"]
    end
    # No borramos el archivo porque las chances de que quieran volver a
    # imprimir la misma etiqueta son grandes. Actualmente, la libreria que
    # armamos para los QR no hace nada si el arhivo ya existe, con lo cual
    # mejoramos la performance de la impresion dejando los archivos previos
    # ahi.
    puts "----"
  end
  success!
  printed_jobs_ids
rescue Exception => ex
  notify_error ex.message
end

def mark_as_printed printed_jobs_ids
  puts
  puts printed_jobs_ids&.count > 0 ? "Dequeuing jobs..." : "No jobs to dequeue."
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




