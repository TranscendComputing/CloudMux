require 'sinatra'
require 'pry'

class PackedImagesApiApp < ApiBase
    get '/' do
        uri = URI.parse("http://localhost:8080/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
end