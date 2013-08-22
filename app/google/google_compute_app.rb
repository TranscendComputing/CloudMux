require 'sinatra'
require 'fog'
require 'debugger'

class GoogleComputeApp < ResourceApiBase
  
  before do
    if ! params[:cred_id].nil?
      cloud_cred = get_creds(params[:cred_id])
      if ! cloud_cred.nil?
       
        p12_file = Base64.decode64(cloud_cred.cloud_attributes['google_p12_key'])
        file = File.new('googlecompute.p12','w+')
        file.puts(p12_file)
        file.close
       
        @compute = Fog::Compute::Google.new({
          :google_project => cloud_cred.cloud_attributes['google_project_id'],
          :google_client_email => cloud_cred.cloud_attributes['google_client_email'],
          :google_key_location => file.path
          })
        
          File.delete('googlecompute.p12')
  
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
        
        server = nil
        
        cloud_cred = get_creds(params[:cred_id])
        
        private_key_file = File.new('id_rsa','w+')
        private_key_file.puts(cloud_cred.cloud_attributes['google_private_key'])
        private_key_file.close
        public_key_file = File.new('id_rsa.pub','w+')
        public_key_file.puts(cloud_cred.cloud_attributes['google_public_key'])
        public_key_file.close
        
        if ! json_body["instance"]["disk"].nil?
          disk = @compute.disks.get(json_body["instance"]["disk"],json_body["instance"]["zone_name"]).get_as_boot_disk(true)
          #debugger
          server = @compute.servers.create(defaults = {
            :name => json_body["instance"]["name"],
            #:image_name => json_body["instance"]["image_name"],
            :kernel => 'gce-v20130603',
            :machine_type => json_body["instance"]["machine_type"],
            :zone_name => json_body["instance"]["zone_name"],
            :disks => [ disk ],
            :private_key_path => File.expand_path("id_rsa"),
            :public_key_path => File.expand_path("id_rsa.pub"),
            :user => ENV['USER'],
          })
        else
          server = @compute.servers.create(defaults = {
            :name => json_body["instance"]["name"],
            :image_name => json_body["instance"]["image_name"],
            :machine_type => json_body["instance"]["machine_type"],
            :zone_name => json_body["instance"]["zone_name"],
            :private_key_path => File.expand_path("id_rsa"),
            :public_key_path => File.expand_path("id_rsa.pub"),
            :user => ENV['USER'],
          })
        end
        
        File.delete('id_rsa')
        File.delete('id_rsa.pub')
        
        [OK, server.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
	delete '/instances/:id' do
		begin
			response = @compute.delete_server(params[:id],params[:region])
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
  		#response = @compute.list_images
      response = @compute.images.all
      debugger
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
  		response = @compute.list_machine_types(params[:region])
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
          :source_image => json_body["disk"]["image_name"],
          :zone_name => json_body["disk"]["zone_name"],
          :size_gb => json_body["disk"]["size_gb"]
        })
        
        [OK, disk.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
	delete '/disks/:id' do
    begin
  		response = @compute.delete_disk(params[:id],params[:region])
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  #
  #Networks
  #
	get '/networks' do
    begin
  		response = @compute.list_networks
  		[OK, response.body["items"].to_json]
    rescue => error
				handle_error(error)
		end
	end
  
	post '/networks' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
        network = @compute.insert_network(json_body["network"]["network_name"],json_body["network"]["ip_range"])
        [OK, network.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
	delete '/networks/:id' do
    begin
  		response = @compute.delete_network(params[:id])
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  #
  #Firewalls
  #
	get '/firewalls' do
    begin
      response = @compute.list_firewalls
  		[OK, response.body["items"].to_json]
    rescue => error
				handle_error(error)
		end
	end
  
	post '/firewalls' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
        firewall = @compute.insert_firewall(json_body["firewall"]["firewall_name"],json_body["firewall"]["source_range"],json_body["firewall"]["allowed"],json_body["firewall"]["network"])
        [OK, firewall.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
	delete '/firewalls/:id' do
    begin
  		response = @compute.delete_firewall(params[:id])
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  #
  #Snapshots
  #
	get '/snapshots' do
    begin
      response = @compute.list_snapshots
  		[OK, response.body["items"].to_json]
    rescue => error
				handle_error(error)
		end
	end

end