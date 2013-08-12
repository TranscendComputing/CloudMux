require 'sinatra'
require 'fog'

class GoogleComputeApp < ResourceApiBase
  
  before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
        #cloud_cred.cloud_attributes['google_private_key']
			  #@compute = Fog::Compute::Google.new({:google_project => cloud_cred.cloud_attributes['google_project_id'], :google_client_email => cloud_cred.cloud_attributes['google_client_email'], :google_key_location => cloud_cred.cloud_attributes['google_private_key']})
        @compute = Fog::Compute::Google.new({
          :google_project => "momentumsi1",
          :google_client_email => "33172512232-vvejocpdgtvoi845n28di5tn1hholvkr@developer.gserviceaccount.com",
          :google_key_location => "app/google/key/googlecompute.p12",
        })
			end
		end
		halt [BAD_REQUEST] if @compute.nil?
  end
  
  #
  #Instance
  #
	get '/instances' do
    begin
		  filters = params[:filters]
  		if(filters.nil?)
  			response = @compute.servers.all
  		else
  			response = @compute.servers.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
	post '/instances' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
        server = @compute.servers.create(defaults = {
          :name => json_body["instance"]["name"],
          :image_name => json_body["instance"]["image_name"],
          :machine_type => "n1-standard-1",
          :zone_name => json_body["instance"]["zone_name"],
          :private_key_path => File.expand_path("app/google/key/id_rsa"),
          :public_key_path => File.expand_path("app/google/key/id_rsa.pub"),
          :user => ENV['USER'],
        })
        
        [OK, server.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
	delete '/instances/:id' do
		begin
			response = @compute.servers.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Images
  #
	get '/images' do
    begin
  		response = @compute.list_images
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
	post '/images' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @compute.images.create(json_body["image"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
	delete '/images/:id' do
		begin
			response = @compute.delete_image(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Zones
  #
	get '/availability_zones' do
    begin
  		response = @compute.list_zones
  		[OK, response.body["items"].to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  #
  #Machine Types
  #
	get '/machine_types' do
    begin
  		response = @compute.list_machine_types
  		[OK, response.body["items"].to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  #
  #Flavors
  #
	get '/flavors' do
    begin
  		response = @compute.flavors
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  #
  #Disks
  #
	get '/disks' do
    begin
  		response = @compute.list_disks(params[:region])
  		[OK, response.body["items"].to_json]
    rescue => error
				handle_error(error)
		end
	end
  
	post '/disks' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
        disk = @compute.disks.create({
          :name => json_body["disk"]["name"],
          :image_name => json_body["disk"]["image_name"],
          :zone_name => json_body["disk"]["zone_name"],
          :size_gb => json_body["disk"]["size_gb"]
        })
        
        [OK, disk.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

end