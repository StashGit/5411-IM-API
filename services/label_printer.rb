require 'httparty'
require 'json'
require 'rqrcode'
require 'fileutils'
require_relative '../app/lib/qr.rb'

include ::Qr

def init
    # Utilizamos un directorio propio del servicio para no tener conflictos con
    # los qrs que generamos en app/public.
    set_root "./qrs"
    url   = ENV['HOST']  || 'http://localhost:3000'
    token = ENV['TOKEN'] || '99310f56f95becb1d9b339151a22c621'

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

  jobs&.each do |job|
    puts "----"
    qr = job["qr"]
    path = create_qr_code brand_id: qr["brand_id"]&.to_s, 
                          style:    qr["style"], 
                          color:    qr["color"], 
                          size:     qr["size"]
    puts path
    puts job["copies"]
    puts job["job_id"]
    puts "----"
    # Una vez que logramos imprimir el archivo lo eliminamos.
    # FileUtils.rm_rf path
  end
  success!
rescue Exception => ex
  notify_error ex.message
end

def mark_as_printed jobs
  puts
  puts jobs&.count > 0 ? "Dequeuing jobs..." : "No jobs to dequeue."
  jobs_ids = jobs.collect { |job| job["job_id"] }
  body = { jobs_ids: jobs_ids }.to_json

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
  ok = print_labels jobs
  if ok
    mark_as_printed jobs
  end
end

def main
  loop do
    begin
      do_work
    rescue Exception => ex
      puts ex
    end

    sleep 5
  end
end

init
main
