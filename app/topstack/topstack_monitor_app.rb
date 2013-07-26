require 'sinatra'
require 'fog'

class TopStackMonitorApp < ResourceApiBase

	before do
		if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                begin
                    # Find Monitor service endpoint
                    endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"Monitor"}).first
                    halt [BAD_REQUEST] if endpoint.nil?
                    fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
                    fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
                    @monitor = Fog::AWS::CloudWatch.new(fog_options)
                    halt [BAD_REQUEST] if @monitor.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

	#
	# Alarms
	#
  ##~ sapi = source2swagger.namespace("topstack_monitor")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Alarm"] = {:id => "Alarm", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
	get '/alarms' do
		filters = params[:filters]
		if(filters.nil?)
			response = @monitor.alarms
		else
			response = @monitor.alarms.all(filters)
		end
		[OK, response.to_json]
	end
	
	post '/alarms' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @monitor.alarms.create(json_body["alarm"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	delete '/alarms/:id' do
		begin
			response = @monitor.alarms.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Metrics
	#
	get '/metrics' do
		begin
			filters = params[:filters]
			if(filters["Dimensions"].is_a?String)
				filters["Dimensions"] = [{"Name"=>filters["Dimensions"]}]
			end
			if(filters.nil?)
				raw_response = @monitor.metrics
			else
				raw_response = @monitor.metrics.all(filters)
			end
			#Cast to and from JSON to workaround circular reference bug
			new_response = JSON.parse(raw_response.to_json)
			response = new_response.sort_by {|s| s["dimensions"].first["Value"]}
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Metric Statistics
	#
	get '/metric_statistics' do
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
				response = @monitor.get_metric_statistics(options).body['GetMetricStatisticsResult']['Datapoints']
				first_datapoint = response.first
				statistic = ""
				if(!first_datapoint.nil?)
					if(first_datapoint.has_key?("Average"))
						statistic = "Average"
					elsif(first_datapoint.has_key?("Sum"))
						statistic = "Sum"
					elsif(first_datapoint.has_key?("SampleCount"))
						statistic = "SampleCount"
					elsif(first_datapoint.has_key?("Maximum"))
						statistic = "Maximum"
					elsif(first_datapoint.has_key?("Minimum"))
						statistic = "Minimum"
					end

					if(statistic != "")
						response.each {|d| d[statistic] = d[statistic].round(5)}
					end
				end
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
end
