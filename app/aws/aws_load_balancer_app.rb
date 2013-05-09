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

	post '/load_balancers/availability_zones/enable' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["availability_zones"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.enable_availability_zones_for_load_balancer(json_body["availability_zones"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/load_balancers/availability_zones/disable' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["availability_zones"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.disable_availability_zones_for_load_balancer(json_body["availability_zones"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/load_balancers/instances/register' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance_ids"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.register_instances_with_load_balancer(json_body["instance_ids"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/load_balancers/instances/deregister' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance_ids"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.deregister_instances_from_load_balancer(json_body["instance_ids"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/load_balancers/instances/available' do
		
	end

	get '/load_balancers/describe_health' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil? || params[:availability_zones].nil? || params[:id].nil?)
			[BAD_REQUEST]
		else
			begin
				availability_zones_health = []
				availability_zones = JSON.parse(params[:availability_zones])
				availability_zones.each do |az|
					az_health = {}
					az_health["LoadBalancerName"] = params[:id]
					az_health["AvailabilityZone"] = az
					az_health["InstanceCount"] = 0
					az_health["Healthy"] = false
					availability_zones_health << az_health
				end
				instance_health = elb.describe_instance_health(params[:id]).body["DescribeInstanceHealthResult"]["InstanceStates"]
				compute = get_compute_interface(params[:cred_id], params[:region])
				instance_health.each do |i|
					instance = compute.servers.get(i["InstanceId"])
					i["AvailabilityZone"] = instance.availability_zone
					availability_zones_health.each do |a|
						if a["AvailabilityZone"] == i["AvailabilityZone"]
							a["InstanceCount"] = a["InstanceCount"] + 1
							if i["State"] == "InService"
								a["Healthy"] = true
							end
						end
					end
				end
				response = {"AvailabilityZonesHealth" => availability_zones_health, "InstancesHealth" => instance_health}
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

	#
	# Load Balancer Listeners
	#
	get '/load_balancers/listeners/describe' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			load_balancer = params[:load_balancer]
			if(load_balancer.nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.load_balancers.get(load_balancer).listeners
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	put '/load_balancers/listeners/create' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["load_balancer"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.create_load_balancer_listeners(json_body["load_balancer"]["id"], json_body["load_balancer"]["listeners"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	delete '/load_balancers/listeners/delete' do
		elb = get_load_balancer_interface(params[:cred_id], params[:region])
		if(elb.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["load_balancer"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = elb.delete_load_balancer_listeners(json_body["load_balancer"]["id"], json_body["load_balancer"]["ports"])
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

	def get_compute_interface(cred_id, region)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				if region.nil? or region == "undefined" or region == ""
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => region})
				end
			end
		end
	end
end
