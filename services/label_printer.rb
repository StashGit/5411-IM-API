require 'httparty'
require 'json'

loop do
  begin
    url = ENV['HOST'] || 'http://localhost:3000'
    uri = URI("#{url}/stock/labels_queue")
    puts uri

    headers = {
      "content-type": 'application/json',
      "access-token": '',
    }

    response = HTTParty.get(url, headers: headers)
    puts response.body

    if response.status == 200
      transactions = JSON.parse(response.body)["transactions"]
      transactions.each {|t| puts t }
    else
      puts "error"
      errors = JSON.parse(response.body)["errors"]
    end
  rescue Exception => ex
    puts ex
  end

  sleep 5
end
