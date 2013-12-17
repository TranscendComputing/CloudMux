require 'sinatra'
require 'fog'

class OpenstackLoadBalancerApp < ResourceApiBase

	before do
        if(params[:cred_id].nil?)
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Cannot access this service under current policy."
            halt [NOT_AUTHORIZED, message.to_json]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                begin
                    # Find ELB service endpoint
                    endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"ELB"}).first
                    halt [BAD_REQUEST] if endpoint.nil?
                    fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
                    fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
                    @load_balancer = Fog::AWS::ELB.new(fog_options)
                    halt [BAD_REQUEST] if @load_balancer.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

	#
	# LoadBalancers
	#
    
	get '/load_balancers' do
        begin
            response = @load_balancer.load_balancers
    		[OK, response.to_json]
        rescue => error
            handle_error(error)
        end
	end
	
	post '/load_balancers' do
        json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @load_balancer.load_balancers.create(json_body["load_balancer"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	delete '/load_balancers/:id' do
        begin
			response = @load_balancer.load_balancers.destroy(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	post '/load_balancers/:id/configure_health_check' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body['health_check'])
            [BAD_REQUEST]
        else
            begin
                response = @load_balancer.configure_health_check(params[:id], json_body["health_check"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    post '/load_balancers/:id/availability_zones' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["availability_zones"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @load_balancer.enable_availability_zones_for_load_balancer(json_body["availability_zones"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    delete '/load_balancers/:id/availability_zones' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["availability_zones"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @load_balancer.disable_availability_zones_for_load_balancer(json_body["availability_zones"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    post '/load_balancers/:id/instances' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["instance_ids"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @load_balancer.register_instances_with_load_balancer(json_body["instance_ids"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    delete '/load_balancers/:id/instances' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["instance_ids"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @load_balancer.deregister_instances_from_load_balancer(json_body["instance_ids"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    get '/load_balancers/:id/describe_health' do
        begin
            load_balancer = @load_balancer.load_balancers.get(params[:id])
            response = load_balancer.instance_health
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    #
    # Load Balancer Listeners
    #
    get '/load_balancers/:id/listeners' do
        begin
            response = @load_balancer.load_balancers.get(params[:id]).listeners
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    post '/load_balancers/:id/listeners' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["listeners"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @load_balancer.create_load_balancer_listeners(params[:id], json_body["listeners"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    delete '/load_balancers/:id/listeners' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["ports"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = elb.delete_load_balancer_listeners(params[:id], json_body["ports"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
end
