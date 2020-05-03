require 'httparty'
require 'json'

def init
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
  puts "Printing labels..."
  jobs&.each do |job|
    puts "----"
    puts job["qr"]
    puts job["copies"]
    puts job["job_id"]
    puts "----"
  end
  success!
rescue Exception => ex
  notify_error ex.message
end

def mark_as_printed jobs
  puts
  puts "marking as printed"
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
  print_labels jobs
  mark_as_printed jobs
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
