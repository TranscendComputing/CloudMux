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
    
    post '/save' do
        body = JSON.parse(request.body.read)
        packed_image = body['packed_image']
        docid = params[:docid]
        response = nil
        if docid.nil?
            #uri = URI.parse("http://localhost:8080/packer/"+params[:uid])
            #http = Net::HTTP.new(uri.host, uri.port)
            #response = http.request(Net::HTTP::Put.new(uri.request_uri,packed_image))
            http = Net::HTTP.new('localhost', 8080)
            response = http.send_request('PUT', '/packer/'+params[:uid],packed_image.to_json)
        else
            uri = URI.parse("http://localhost:8080/packer/"+params[:uid]+"/"+docid)
            http = Net::HTTP.new(uri.host, uri.port)
            response = http.request(Net::HTTP::Post.new(uri.request_uri,packed_image))
        end
        #binding.pry
        [OK, response.body]
    end
end