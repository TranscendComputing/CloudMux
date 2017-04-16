require 'sinatra'
require 'fog'

class AwsMonitorApp < ResourceApiBase

  before do
    params["provider"] = "aws"
    @service_long_name = "CloudWatch"
    @service_class = Fog::AWS::CloudWatch
    @monitor = can_access_service(params)
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
      filters  = params[:filters]
      response = filters.nil? ? @monitor.alarms : @monitor.alarms.all(filters)
      [OK, response.to_json]
    rescue => error
      pre_handle_error(@monitor, error)
    end
  end
    
  get '/alarms/:id/alarm_history' do
    response = @monitor.describe_alarm_history({"AlarmName"=>params[:id]})
                       .body['DescribeAlarmHistoryResult']['AlarmHistoryItems']
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
    json_body = body_to_json_or_die("body" => request)
    response = @monitor.alarms.create(json_body["alarm"])
    [OK, response.to_json]
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
    response = @monitor.alarms.get(params[:id]).destroy
    [OK, response.to_json]
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
    filters = params[:filters]
    if filters["Dimensions"].is_a?(String)
      filters["Dimensions"] = [{"Name"=>filters["Dimensions"]}]
    end

    #Cast to and from JSON to workaround circular reference bug
    raw_response = filters.nil? ? @monitor.metrics : @monitor.metrics.all(filters)
    new_response = JSON.parse(raw_response.to_json)
    response = new_response.sort_by {|s| s["dimensions"].first["Value"]}
    [OK, response.to_json]
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
    req_params = [
      params[:time_range],
      params[:namespace],
      params[:metric_name],
      params[:period],
      params[:statistic],
      params[:dimension_name],
      params[:dimension_value]
    ]

    halt [BAD_REQUEST] if req_params.length == 0
    halt [BAD_REQUEST] unless req_params.compact.length == req_params.length

    options = {
      "Period"     => params[:period].to_i,
      "Statistics" => params[:statistic],
      "Namespace"  => params[:namespace],
      "MetricName" => params[:metric_name],
      "StartTime"  => DateTime.now - params[:time_range].to_i.seconds,
      "EndTime"    => DateTime.now,
    }

    options["Dimensions"] = params[:dimension_name2].nil? ?
      [{"Name"=>params[:dimension_name], "Value"=>params[:dimension_value]}] :
      [
        {"Name"=>params[:dimension_name], "Value"=>params[:dimension_value]},
        {"Name"=>params[:dimension_name2], "Value"=>params[:dimension_value2]}
      ] 
    
    response = @monitor.get_metric_statistics(options)
                       .body['GetMetricStatisticsResult']['Datapoints']
    first_datapoint = response.first

    unless first_datapoint.nil?
      if first_datapoint.has_key?("Average")
        statistic = "Average"
      elsif first_datapoint.has_key?("Sum")
        statistic = "Sum"
      elsif first_datapoint.has_key?("SampleCount")
        statistic = "SampleCount"
      elsif first_datapoint.has_key?("Maximum")
        statistic = "Maximum"
      elsif first_datapoint.has_key?("Minimum")
        statistic = "Minimum"
      end

      if statistic.nil? 
        response.each {|d| d[statistic] = d[statistic].round(5)}
      end
    end
    [OK, response.to_json]
  end
end
