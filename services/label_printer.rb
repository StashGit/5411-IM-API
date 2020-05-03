require 'httparty'
require 'json'

loop do
  begin
    url   = ENV['HOST']  || 'http://localhost:3000'
    token = ENV['TOKEN'] || '99310f56f95becb1d9b339151a22c621'

    uri = URI("#{url}/stock/labels_queue")

    headers = {
      "Content-Type": 'application/json',
      "Access-Token": token
    }

    response = HTTParty.get(uri, headers: headers)

    if response.code == 200
      puts "SUCCESS"
      transactions = JSON.parse(response.body)["transactions"]
      transactions.each {|t| puts t }
    else
      puts "ERROR"
      puts JSON.parse(response.body)["errors"]
    end
  rescue Exception => ex
    puts ex
  end

  sleep 5
end
