require 'sinatra'
require 'fog'

class AwsLoadBalancerApp < ResourceApiBase
	#
	# Load Balancers
	#
	get '/load_balancers/describe' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = elb.load_balancers
			else
				response = elb.load_balancers.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/load_balancers/create' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					lb = json_body["load_balancer"]
					if lb["options"].nil?
						response = elb.create_load_balancer(lb["availability_zones"], lb["id"], lb["listeners"])
					else
						response = elb.create_load_balancer(lb["availability_zones"], lb["id"], lb["listeners"], lb["options"])
					end
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/load_balancers/delete' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["load_balancer"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.load_balancers.get(json_body["load_balancer"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/load_balancers/configure_health_check' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["load_balancer"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.configure_health_check(json_body["load_balancer"]["id"], json_body["load_balancer"]["health_check"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	def get_load_balancer_interface(cred_id, region)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				if region.nil? or region == "undefined" or region == ""
					return Fog::AWS::ELB.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					return Fog::AWS::ELB.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => region})
				end
			end
		end
	end
end
