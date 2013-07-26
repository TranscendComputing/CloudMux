require 'sinatra'
require 'fog'

class OpenstackNetworkApp < ResourceApiBase

	before do
        if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                options = cloud_cred.cloud_attributes
                begin
                    @network = Fog::Network::OpenStack.new(options)
                    halt [BAD_REQUEST] if @network.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

	#
	# Networks
	#
  ##~ sapi = source2swagger.namespace("openstack_network")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Network"] = {:id => "Network", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
    
	get '/networks' do
        begin
            response = @network.list_networks.body["networks"]
    		[OK, response.to_json]
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
				response = @network.networks.create(json_body["network"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	delete '/networks/:id' do
        begin
			response = @network.networks.destroy(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Subnets
	#
	get '/subnets' do
        begin
            response = @network.list_subnets.body["subnets"]
    		[OK, response.to_json]
        rescue => error
            handle_error(error)
        end
	end
	
    post '/subnets' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @network.subnets.create(json_body["subnet"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    delete '/subnets/:id' do
        begin
            response = @network.subnets.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    #
    # Ports
    #
    get '/ports' do
        begin
            response = @network.list_ports.body["ports"]
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    post '/ports' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @network.ports.create(json_body["port"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    delete '/ports/:id' do
        begin
            response = @network.ports.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    #
    # Floating IPs
    #
    get '/floating_ips' do
        begin
            response = @network.list_floating_ips.body["floating_ips"]
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    post '/floating_ips' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @network.floating_ips.create(json_body["floating_ip"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    delete '/floating_ips/:id' do
        begin
            response = @network.floating_ips.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
end
