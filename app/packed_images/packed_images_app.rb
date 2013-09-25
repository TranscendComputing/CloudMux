require 'sinatra'
require 'pry'

class PackedImagesApiApp < ApiBase
    get '/' do
        uri = URI.parse("http://localhost:8080/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders' do
        uri = URI.parse("http://localhost:8080/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders/:id' do
        uri = URI.parse("http://localhost:8080/templates/builders/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners' do
        uri = URI.parse("http://localhost:8080/templates/provisioners")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners/:id' do
        uri = URI.parse("http://localhost:8080/templates/provisioners/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
end