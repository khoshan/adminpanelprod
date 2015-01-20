require 'uri'
require 'net/https'
require 'net/http'
require 'json'
require 'csv'

def getexchangerate
  uri = URI.parse('https://openexchangerates.org/api/latest.json?app_id=8a028362ba794bfe89588815676ea107')
  httpuri = Net::HTTP.new(uri.host, uri.port)
  httpuri.use_ssl = true
  httpuri.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = httpuri.request(request)
  json = JSON.parse(response.body)
  ratedata = json['rates']
  CSV.open("/root/myApp/config/ratetousd.txt", "w:UTF-8", {:col_sep => " "}) { |csv|
    ratedata.each do |k,v|
      csv << [k, (1.0/v)]
    end
  }
  # copy to sfs dev
  `/usr/local/bin/sshpass -p 'buncha11' /usr/bin/scp -o StrictHostKeychecking=no /root/myApp/config/ratetousd.txt lumbarunner@ec2-54-74-6-249.eu-west-1.compute.amazonaws.com:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core`
  # copy to sfs prod
  `/usr/local/bin/sshpass -p 'buncha11' /usr/bin/scp -o StrictHostKeychecking=no /root/myApp/config/ratetousd.txt lumbarunner@ec2-54-75-238-163.eu-west-1.compute.amazonaws.com:/home/lumbarunner/apps/SmartFoxServer_2X/SFS2X/data/lumba/core`
end

getexchangerate
