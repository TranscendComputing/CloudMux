require 'sinatra'
require 'fog'

class AwsMonitorApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil? && Auth.validate(params[:cred_id],"CloudWatch","action")
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@monitor = Fog::AWS::CloudWatch.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@monitor = Fog::AWS::CloudWatch.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
				halt [BAD_REQUEST] if @monitor.nil?
			else
				halt [NOT_FOUND, "Credentials not found."]
			end
		else
			message = Error.new.extend(ErrorRepresenter)
		    message.message = "Cannot access this service under current policy."
		    halt [NOT_AUTHORIZED, message.to_json]
		end
    end

	#
	# Alarms
	#
  ##~ sapi = source2swagger.namespace("aws_monitor")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Alarm"] = {:id => "Alarms", :properties => {:id => {:type => "string"}, :comparison_operator => {:type => "string"}, :evaluation_periods => {:type => "string"}, :metric_name => {:type => "string"}, :namespace => {:type => "string"}, :period => {:type => "string"}, :statistic => {:type => "string"}, :threshold => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/monitor/alarms"
  ##~ a.description = "Manage Monitor resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Alarms (AWS cloud)"
  ##~ op.nickname = "describe_alarms"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for alarms", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of alarms returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/alarms' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @monitor.alarms
  		else
  			response = @monitor.alarms.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
    
    get '/alarms/:id/alarm_history' do
        #response = @monitor.describe_alarm_history({"AlarmName"=>params[:id],"HistoryItemType"=>"StateUpdate"}).body['DescribeAlarmHistoryResult']['AlarmHistoryItems']
        response = @monitor.describe_alarm_history({"AlarmName"=>params[:id]}).body['DescribeAlarmHistoryResult']['AlarmHistoryItems']
        [OK, response.to_json]
    end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/monitor/alarms"
  ##~ a.description = "Manage Monitor resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Alarms (AWS cloud)"
  ##~ op.nickname = "create_alarms"  
  ##~ op.parameters.add :name => "alarm", :description => "Alarm to Create", :dataType => "Alarm", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, alarm created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/monitor/alarms/:id"
  ##~ a.description = "Manage Monitor resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Alarms (AWS cloud)"
  ##~ op.nickname = "delete_alarms"  
  ##~ op.parameters.add :name => "id", :description => "Alarm to delete", :dataType => "Alarm", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, alarm deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/monitor/metrics"
  ##~ a.description = "Manage Monitor resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Metrics (AWS cloud)"
  ##~ op.nickname = "describe_metrics"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for metrics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of metrics returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/monitor/metric_statistics"
  ##~ a.description = "Manage Monitor resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Metric Statistics (AWS cloud)"
  ##~ op.nickname = "describe_metrics_statistics"  
  ##~ op.parameters.add :name => ":time_range", :description => "timerange for metrics", :dataType => "Date", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":namespace", :description => "namespace for metrics", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":metric_name", :description => "metric name for metrics", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":period", :description => "period for metrics", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":statistic", :description => "statistic for metrics", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":dimension_name", :description => "dimension name for metrics", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":dimension_value", :description => "dimension value for metrics", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of metric statistics returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/metric_statistics' do
		if(	params[:time_range].nil? || params[:namespace].nil? || params[:metric_name].nil? || params[:period].nil? ||
			params[:statistic].nil? || params[:dimension_name].nil? || params[:dimension_value].nil?)
			[BAD_REQUEST]
		else
			begin
        options = {}
        
        options["Period"] = params[:period].to_i
        options["Statistics"] = params[:statistic]
        options["Namespace"] = params[:namespace]
        
        if(!params[:dimension_name2].nil?)
          options["Dimensions"] = [{"Name"=>params[:dimension_name], "Value"=>params[:dimension_value]},{"Name"=>params[:dimension_name2], "Value"=>params[:dimension_value2]}]
        else
          options["Dimensions"] = [{"Name"=>params[:dimension_name], "Value"=>params[:dimension_value]}]
        end
        
        options["MetricName"] = params[:metric_name]
        options["StartTime"] = DateTime.now - params[:time_range].to_i.seconds
        options["EndTime"] = DateTime.now
				
        
        #options = {
				#	"Period"=>params[:period].to_i,
				#	"Statistics"=>params[:statistic],
				#	"Namespace"=>params[:namespace],
				#	"Dimensions"=>[{"Name"=>params[:dimension_name], "Value"=>params[:dimension_value]}],
				#	"MetricName"=>params[:metric_name],
				#	"StartTime"=>DateTime.now - params[:time_range].to_i.seconds,
				#	"EndTime"=>DateTime.now
				#}
        
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
