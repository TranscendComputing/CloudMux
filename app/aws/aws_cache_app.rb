require 'sinatra'
require 'fog'

class AwsCacheApp < ResourceApiBase
	
	before do
    @service_long_name = "Elasticache"
    @service_class = Fog::AWS::Elasticache
    @elasticache = can_access_service(params)
  end
    
	#
	# Clusters
	#
  ##~ sapi = source2swagger.namespace("aws_cache")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Cluster"] = {:id => "Cluster", :properties => {:id => {:type => "string"}, :node_type => {:type => "string"}, :security_group_names => {:type => "string"}, :num_nodes => {:type => "string"}, :auto_minor_version_upgrade => {:type => "string"}, :engine => {:type => "string"}, :engine_version => {:type => "string"}, :notification_topic_arn => {:type => "string"}, :port => {:type => "string"}, :preferred_availablility_zone => {:type => "string"}, :preferred_maintenance_window => {:type => "string"}, :parameter_group_name => {:type => "string"}}}
  ##~ sapi.models["ParameterGroup"] = {:id => "ParameterGroup", :properties => {:id => {:type => "string"}, :description => {:type => "string"}, :family => {:type => "string"}}}
  ##~ sapi.models["SecurityGroup"] = {:id => "SecurityGroup", :properties => {:id => {:type => "string"}, :description => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/clusters"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Cluster"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Cache Clusters (AWS cloud)"
  ##~ op.nickname = "describe_cache_clusters"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for clusters", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of cache clusters returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/clusters' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @elasticache.clusters
  		else
  			response = @elasticache.clusters.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/clusters"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Cluster"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Cache Clusters (AWS cloud)"
  ##~ op.nickname = "create_cache_clusters"  
  ##~ sapi.models["CreateCluster"] = {:id => "CreateCluster", :properties => {:id => {:type => "string"}, :node_type => {:type => "string"}, :security_group_names => {:type => "Array", :items => {:$ref => "string"}}, :num_nodes => {:type => "int"}, :auto_minor_version_upgrade => {:type => "boolean"}, :parameter_group_name => {:type => "string"}, :engine => {:type => "string"}, :engine_version => {:type => "string"}, :notification_topic_arn => {:type => "string"}, :port => {:type => "int"}, :preferred_availablility_zone => {:type => "string"}, :preferred_maintenance_window => {:type => "string"}}}
  ##~ op.parameters.add :name => "cluster", :description => "Cluster to Create", :dataType => "CreateCluster", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, list of cache cluster created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/clusters' do
	  json_body = body_to_json_or_die("body" => request)
		begin
			response = @elasticache.clusters.create(json_body["cluster"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/clusters/:id"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Cluster"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Cache Clusters (AWS cloud)"
  ##~ op.nickname = "delete_cache_clusters"  
  ##~ op.parameters.add :name => "id", :description => "Cluster to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of cache cluster deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/clusters/:id' do
		begin
			response = @elasticache.clusters.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Get Security/Parameter Groups
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/parameter_groups"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "ParameterGroup"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Cache Cluster Parameter Groups (AWS cloud)"
  ##~ op.nickname = "describe_cache_cluster_parameter_groups"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for parameter groups", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of cache cluster parameter groups returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/parameter_groups' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @elasticache.parameter_groups
  		else
  			response = @elasticache.parameter_groups.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/security_groups"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "SecurityGroup"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Cache Cluster Security Groups (AWS cloud)"
  ##~ op.nickname = "describe_cache_cluster_security_groups"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for security groups", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of cache cluster security groups returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/security_groups' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @elasticache.security_groups
  		else
  			response = @elasticache.security_groups.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
  
  #
  #Create Security/Parameter Groups
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/security_groups"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "SecurityGroup"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Cache Cluster Security Groups (AWS cloud)"
  ##~ op.nickname = "create_cache_cluster_security_groups"  
  ##~ sapi.models["CreateCacheSecurity"] = {:id => "CreateCacheSecurity", :properties => {:id => {:type => "string"},:description => {:type => "string"}}}  
  ##~ op.parameters.add :name => "security_group", :description => "Cache Security Group to Create", :dataType => "CreateCacheSecurity", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, Security Group Created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/security_groups' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @elasticache.security_groups.create(json_body["security_group"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/parameter_groups"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "ParameterGroup"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Cache Cluster Parameter Groups (AWS cloud)"
  ##~ op.nickname = "create_cache_cluster_parameter_groups"  
  ##~ sapi.models["CreateCacheParameter"] = {:id => "CreateCacheParameter", :properties => {:id => {:type => "string"},:description => {:type => "string"}}}  
  ##~ op.parameters.add :name => "parameter_group", :description => "Cache Parameter Group to Create", :dataType => "CreateCacheParameter", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, Parameter Group Created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/parameter_groups' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @elasticache.parameter_groups.create(json_body["parameter_group"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Delete Security/Parameter Groups
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/security_groups/:id"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "SecurityGroup"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Cache Cluster Security Group (AWS cloud)"
  ##~ op.nickname = "delete_cache_cluster_security_group"  
  ##~ op.parameters.add :name => "id", :description => "Cluster Security Group to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, Security Group deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/security_groups/:id' do
		begin
			response = @elasticache.security_groups.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/parameter_groups/:id"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "ParameterGroup"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Cache Cluster Parameter Group (AWS cloud)"
  ##~ op.nickname = "delete_cache_cluster_parameter_group"  
  ##~ op.parameters.add :name => "id", :description => "Cluster Parameter Group to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, Parameter Group deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/parameter_groups/:id' do
		begin
			response = @elasticache.parameter_groups.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Modify
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/clusters/modify/:id"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Cluster"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Modify Cache Clusters (AWS cloud)"
  ##~ op.nickname = "modify_cache_clusters"  
  ##~ sapi.models["ModifyCluster"] = {:id => "ModifyCluster", :properties => {:apply_immediately => {:type => "boolean"}, :nodes_to_remove => {:type => "Array", :items => {:$ref => "string"}}, :security_group_names => {:type => "Array", :items => {:$ref => "string"}}, :num_nodes => {:type => "int"}, :auto_minor_version_upgrade => {:type => "boolean"}, :parameter_group_name => {:type => "string"}, :engine_version => {:type => "string"}, :notification_topic_arn => {:type => "string"}, :notification_topic_status => {:type => "string"}, :preferred_maintenance_window => {:type => "string"}}}
  ##~ op.parameters.add :name => "options", :description => "Cluster Options to Modify", :dataType => "ModifyCluster", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.parameters.add :name => "id", :description => "Cluster ID to modify", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, cache cluster modified", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/clusters/modify/:id' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @elasticache.modify_cache_cluster(params[:id],json_body["options"].symbolize_keys!)
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Describe Parameter Group
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/cache/parameter_groups/describe/:id"
  ##~ a.description = "Manage Elastic Cache resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "ParameterGroup"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Describe Cache Cluster Parameter Group (AWS cloud)"
  ##~ op.nickname = "describe_cache_cluster_parameter_group"  
  ##~ sapi.models["DescribeParameters"] = {:id => "DescribeParameters", :properties => {:marker => {:type => "string"},:max_records => {:type => "int"},:source => {:type => "string"}}}  
  ##~ op.parameters.add :name => "options", :description => "Cache Describe Parameter Group Options", :dataType => "DescribeParameters", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.parameters.add :name => "id", :description => "Parameter Group to Describe", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, Parameter Group Description returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/parameter_groups/describe/:id' do
		json_body = body_to_json_or_die("body" => request)
		begin
      #require "debugger"
      #debugger
			response = @elasticache.describe_cache_parameters(params[:id],json_body["options"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
end
