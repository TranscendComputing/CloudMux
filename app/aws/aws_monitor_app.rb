require 'sinatra'
require 'fog'

class AwsMonitorApp < ResourceApiBase
	#
	# Alarms
	#
	get '/alarms/describe' do
		monitor = get_monitor_interface(params[:cred_id])
		if(monitor.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = monitor.alarms
			else
				response = monitor.alarms.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/alarms/create' do
		monitor = get_monitor_interface(params[:cred_id])
		if(monitor.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				response = monitor.alarms.create(json_body["alarm"])
				[OK, response.to_json]
			end
		end
	end
	
	delete '/alarms/delete' do
		monitor = get_monitor_interface(params[:cred_id])
		if(monitor.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["alarm"].nil?)
				[BAD_REQUEST]
			else
				response = monitor.alarms.get(json_body["alarm"]["id"]).destroy
				[OK, response.to_json]
			end
		end
	end
	
	#
	# Metrics
	#
	get '/metrics/describe' do
		monitor = get_monitor_interface(params[:cred_id])
		if(monitor.nil?)
			[BAD_REQUEST]
		else
			begin
				filters = params[:filters]
				if(filters["Dimensions"].is_a?String)
					filters["Dimensions"] = [{"Name"=>filters["Dimensions"]}]
				end
				if(filters.nil?)
					raw_response = monitor.metrics
				else
					raw_response = monitor.metrics.all(filters)
				end
				#Cast to and from JSON to workaround circular reference bug
				new_response = JSON.parse(raw_response.to_json)
				response = new_response.sort_by {|s| s["dimensions"].first["Value"]}
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	#
	# Metric Statistics
	#
	get '/metric_statistics/describe' do
		monitor = get_monitor_interface(params[:cred_id])
		if(monitor.nil?)
			[BAD_REQUEST]
		else
			if(	params[:time_range].nil? || params[:namespace].nil? || params[:metric_name].nil? || params[:period].nil? ||
				params[:statistic].nil? || params[:dimension_name].nil? || params[:dimension_value].nil?)
				[BAD_REQUEST]
			else
				begin
					options = {
						"Period"=>params[:period].to_i,
						"Statistics"=>params[:statistic],
						"Namespace"=>params[:namespace],
						"Dimensions"=>[{"Name"=>params[:dimension_name], "Value"=>params[:dimension_value]}],
						"MetricName"=>params[:metric_name],
						"StartTime"=>DateTime.now - params[:time_range].to_i.seconds,
						"EndTime"=>DateTime.now
					}
					response = monitor.get_metric_statistics(options).body['GetMetricStatisticsResult']['Datapoints']
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	def get_monitor_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::AWS::CloudWatch.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
