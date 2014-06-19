require 'sinatra'
require 'fog'

class TopStackRdsApp < ResourceApiBase

  before do
    params["provider"] = "topstack"
    params["service_type"] = "RDS"
    @service_long_name = "Relational Database"
    @service_class = Fog::AWS::RDS
    @rds = can_access_service(params)
  end

  #
  # Databases
  #
  ##~ sapi = source2swagger.namespace("topstack_rds")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Database"] = {:id => "Database", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/topstack/databases"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe RDS Databases (Topstack cloud)"
  ##~ op.nickname = "describe_rds_databases"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for topics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of database servers returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/databases' do
    filters = params[:filters]

    if filters.nil?
      response = @rds.servers
    else
      response = @rds.servers.all(filters)
    end

    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/databases"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create RDS Database Server (Topstack cloud)"
  ##~ op.nickname = "create_rds_databases"  
  ##~ sapi.models["CreateRDS"] = {:id => "CreateRDS", :properties => {:engine => {:type => "string"},:allocated_storage => {:type => "string"},:master_username => {:type => "string"},:password => {:type => "string"}}}  
  ##~ op.parameters.add :name => "relational_database", :description => "RDS Database to Create", :dataType => "CreateRDS", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, database server created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/databases' do
    json_body = body_to_json_or_die("body" => request)
    can_create_instance(
      "cred_id" => params[:cred_id],
      "action"  => "create_rds",
      "options" => {
          :resources => @rds.servers,
          :uid => @rds.current_user['id']
      }
    )

    region = get_creds(params[:cred_id]).cloud_account.default_region
    json_body["relational_database"]['availability_zone'] = region
    response = @rds.servers.create(json_body["relational_database"])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/databases/:id"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete RDS Databases (Topstack cloud)"
  ##~ op.nickname = "delete_rds_databases"   
  ##~ op.parameters.add :name => "id", :description => "Database to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, rds databases deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/databases/:id' do
    response = @rds.servers.get(params[:id]).destroy
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/engine_versions"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe RDS Engine Versions (Topstack cloud)"
  ##~ op.nickname = "describe_rds_engine_versions"  
  ##~ op.errorResponses.add :reason => "Success, list of database engine versions returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/engine_versions' do
    engine_versions = @rds.describe_db_engine_versions
                          .body['DescribeDBEngineVersionsResult']['DBEngineVersions']
                          .as_json

    engine_versions.each do |v|
      v.each_pair do |name, value|
        v[name] = value.strip
      end
    end

    [OK, engine_versions.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/parameter_groups"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe RDS Parameter Groups (Topstack cloud)"
  ##~ op.nickname = "describe_rds_parameter_groups"
  ##~ op.parameters.add :name => "filters", :description => "Filters for parameter groups", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"  
  ##~ op.errorResponses.add :reason => "Success, list of database parameter groups returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/parameter_groups' do
    filters = params[:filters]

    if filters.nil?
      response = @rds.parameter_groups
    else
      response = @rds.parameter_groups.all(filters)
    end

    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/security_groups"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe RDS Security Groups (Topstack cloud)"
  ##~ op.nickname = "describe_rds_security_groups"
  ##~ op.parameters.add :name => "filters", :description => "Filters for parameter groups", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"  
  ##~ op.errorResponses.add :reason => "Success, list of database security groups returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/security_groups' do
    filters = params[:filters]

    if filters.nil?
      response = @rds.security_groups
    else
      response = @rds.security_groups.all(filters)
    end

    [OK, response.to_json]
  end
  
  #
  #Create Security Groups
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/security_groups"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create RDS Database Security Groups (Topstack cloud)"
  ##~ op.nickname = "create_rds_security_groups"  
  ##~ sapi.models["CreateRDSSecurity"] = {:id => "CreateRDSSecurity", :properties => {:id => {:type => "string"},:description => {:type => "string"}}}  
  ##~ op.parameters.add :name => "security_group", :description => "RDS Security Group to Create", :dataType => "CreateRDSSecurity", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, database security groups created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/security_groups' do
    json_body = body_to_json_or_die("body" => request)
    response = @rds.security_groups.create(json_body["security_group"])
    [OK, response.to_json]
  end
    
  post '/security_groups/:id/ipranges' do
    json_body = body_to_json_or_die("body" => request)
    response = @rds.security_groups.get(params[:id])
                   .authorize_cidrip(json_body["cidrip"])
    [OK, response.to_json]
  end
    
  post '/security_groups/:id/ec2_groups' do
    json_body = body_to_json_or_die("body" => request)
    response = @rds.security_groups.get(params[:id])
                   .authorize_ec2_security_group(json_body["ec2_group"])
    [OK, response.to_json]
  end
    
  post '/security_groups/:id/revoke_ipranges' do
    json_body = body_to_json_or_die("body" => request)
    response  = @rds.security_groups.get(params[:id])
                    .revoke_cidrip(json_body["cidrip"])
    [OK, response.to_json]
  end
    
  post '/security_groups/:id/revoke_ec2_groups' do
    json_body = body_to_json_or_die("body" => request)
    response = @rds.security_groups.get(params[:id])
                   .revoke_ec2_security_group(json_body["ec2_group"])
    [OK, response.to_json]
  end
  
  #
  #Delete Security Groups
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/security_groups/:id"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete RDS Security Group (Topstack cloud)"
  ##~ op.nickname = "delete_rds_security_group"   
  ##~ op.parameters.add :name => "id", :description => "Security Group to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, rds security group deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/security_groups/:id' do
    response = @rds.security_groups.get(params[:id]).destroy
    [OK, response.to_json]
  end
  
  #
  #Create Parameter Groups
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/parameter_groups"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create RDS Database Parameter Groups (Topstack cloud)"
  ##~ op.nickname = "create_rds_parameter_groups"  
  ##~ sapi.models["CreateRDSParameter"] = {:id => "CreateRDSParameter", :properties => {:id => {:type => "string"},:description => {:type => "string"},:family => {:type => "string"}}}  
  ##~ op.parameters.add :name => "parameter_group", :description => "RDS Parameter Group to Create", :dataType => "CreateRDSParameter", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, database parameter groups created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/parameter_groups' do
    json_body = body_to_json_or_die("body" => request)
    response = @rds.parameter_groups.create(json_body["parameter_group"])
    [OK, response.to_json]
  end
  
  #
  #Delete Parameter Groups
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/parameter_groups/:id"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete RDS Parameter Group (Topstack cloud)"
  ##~ op.nickname = "delete_rds_parameter_group"   
  ##~ op.parameters.add :name => "id", :description => "Parameter Group to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, rds parameter group deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/parameter_groups/:id' do
    response = @rds.parameter_groups.get(params[:id]).destroy
    [OK, response.to_json]
  end
  
  #
  #Describe Parameter Group
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/rds/parameter_groups/describe/:id"
  ##~ a.description = "Manage RDS resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Describe RDS Parameters (Topstack cloud)"
  ##~ op.nickname = "describe_rds_parameters"  
  ##~ sapi.models["DescribeParameters"] = {:id => "DescribeParameters", :properties => {:source => {:type => "string"}}}  
  ##~ op.parameters.add :name => "options", :description => "RDS Database Parameter Group Options", :dataType => "DescribeParameters", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.parameters.add :name => "id", :description => "Parameter Group to describe Parameters for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, database parameters returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/parameter_groups/describe/:id' do
    json_body = body_to_json_or_die("body" => request)
    response = @rds.describe_db_parameters(params[:id],json_body["options"])
    [OK, response.to_json]
  end
end
