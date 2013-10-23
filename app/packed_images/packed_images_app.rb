require 'sinatra'
require 'pry'
require 'httparty'

class PackedImagesApiApp < ApiBase
    get '/' do
        uri = URI.parse("http://172.31.254.6:8080/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders' do
        uri = URI.parse("http://172.31.254.6:8080/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders/:id' do
        uri = URI.parse("http://172.31.254.6:8080/templates/builders/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners' do
        uri = URI.parse("http://172.31.254.6:8080/templates/provisioners")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners/:id' do
        uri = URI.parse("http://172.31.254.6:8080/templates/provisioners/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/postprocessors' do
        uri = URI.parse("http://172.31.254.6:8080/templates/postprocessors")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/postprocessors/:id' do
        uri = URI.parse("http://172.31.254.6:8080/templates/postprocessors/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    post '/save' do
        docid = params[:docid]
        response = nil
        if docid.nil?
            body = JSON.parse(request.body.read)
            packed_image = body['packed_image']
            http = Net::HTTP.new('172.31.254.6', 8080)
            response = http.send_request('PUT', '/packer/'+params[:uid],packed_image.to_json)
            PackedImage.create(name: body['name'],doc_id:JSON.parse(response.body)['Id'],org_id:params[:uid], base_image: body['base_image'])
        else
            if(!params["mciaas_files"].nil?)
                old_doc = HTTParty.get("http://172.31.254.6:8080/packer/"+params[:uid]+"/"+docid)
                builder = old_doc['builders'][0]#.select{|b| b['type']=="qemu"}.first
                m_files = {params["mciaas_files"][:filename] => {"type" => "string","content"=> params["mciaas_files"][:tempfile].read}}
                builder.merge!({"mciaas_files" => m_files})
                payload = {"builders"=>[builder]}
                response = HTTParty.post("http://172.31.254.6:8080/packer/"+params[:uid]+"/"+docid, :body => payload.to_json)
            else
                body = JSON.parse(request.body.read)
                packed_image = body['packed_image']
                response = HTTParty.post("http://172.31.254.6:8080/packer/"+params[:uid]+"/"+docid, :body => packed_image.to_json)
            end
        end
        [OK, response.body]
    end
    
    post '/deploy' do
        body = JSON.parse(request.body.read)
        packed_image = body['packed_image']
        docid = params[:docid]
        response = nil
        http = Net::HTTP.new('172.31.254.6', 8080)
        response = http.send_request('PUT', '/image/'+params[:uid]+'/'+params[:doc_id])
        [OK, response.body]
    end
    
    get '/templates/:id' do
        [OK, PackedImage.where(org_id:params[:id]).to_a.to_json]
    end
    
    get '/templates/:uid/:doc_id' do
        old_doc = HTTParty.get("http://172.31.254.6:8080/packer/"+params[:uid]+"/"+params[:doc_id])
        [OK, old_doc.to_json]
    end
end
