require 'sinatra'
require 'pry'

class PackedImagesApiApp < ApiBase
    get '/' do
        uri = URI.parse("http://localhost:9090/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders' do
        uri = URI.parse("http://localhost:9090/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders/:id' do
        uri = URI.parse("http://localhost:9090/templates/builders/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners' do
        uri = URI.parse("http://localhost:9090/templates/provisioners")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners/:id' do
        uri = URI.parse("http://localhost:9090/templates/provisioners/"+params[:id])
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
            http = Net::HTTP.new('localhost', 9090)
            response = http.send_request('PUT', '/packer/'+params[:uid],packed_image.to_json)
            PackedImage.create(name:"testImage",doc_id:JSON.parse(response.body)['Id'],org_id:params[:uid])
        else
            #uri = URI.parse("http://localhost:9090/packer/"+params[:uid]+"/"+docid)
            #http = Net::HTTP.new(uri.host, uri.port)
            #response = http.request(Net::HTTP::Post.new(uri.request_uri,packed_image))
        end
        #binding.pry
        [OK, response.body]
    end
    
    get '/templates/:id' do
        [OK, PackedImage.where(org_id:params[:id]).to_a.to_json]
    end
end