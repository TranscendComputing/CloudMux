require 'sinatra'
require 'fog'

class AwsCacheApp < ResourceApiBase
	#
	# Cache
	#
	get '/cache' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = che.clusters
			else
				response = che.clusters.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/cache/create' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					lb = json_body["cluster"]
					if lb["options"].nil?
						response = che.create_cluster(lb["availability_zones"], lb["id"], lb["listeners"])
					else
						response = che.create_cluster(lb["availability_zones"], lb["id"], lb["listeners"], lb["options"])
					end
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/cache/delete' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["cluster"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.cluster.get(json_body["cluster"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/cache/configure_health_check' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["cluster"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.configure_health_check(json_body["cluster"]["id"], json_body["cluster"]["health_check"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/cache/availability_zones/enable' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["availability_zones"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.enable_availability_zones_for_cluster(json_body["availability_zones"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/cache/availability_zones/disable' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["availability_zones"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.disable_availability_zones_for_cluster(json_body["availability_zones"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/cache/instances/register' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance_ids"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.register_instances_with_cluster(json_body["instance_ids"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/cache/instances/deregister' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance_ids"].nil? || json_body["id"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.deregister_instances_from_cluster(json_body["instance_ids"], json_body["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/cache/instances/available' do
		
	end

	get '/cache/describe_health' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil? || params[:availability_zones].nil? || params[:id].nil?)
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
				instance_health = che.describe_instance_health(params[:id]).body["DescribeInstanceHealthResult"]["InstanceStates"]
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
	get '/cache/listeners/describe' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			cluster = params[:cluster]
			if(cluster.nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.cluster.get(cluster).listeners
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	put '/cache/listeners/create' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["cluster"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.create_cluster_listeners(json_body["cluster"]["id"], json_body["cluster"]["listeners"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	delete '/cache/listeners/delete' do
		che = get_cache_interface(params[:cred_id], params[:region])
		if(che.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["cluster"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = che.delete_cluster_listeners(json_body["cluster"]["id"], json_body["cluster"]["ports"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	def get_cache_interface(cred_id, region)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				if region.nil? or region == "undefined" or region == ""
					return Fog::AWS::Elasticache.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					return Fog::AWS::Elasticache.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => region})
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
