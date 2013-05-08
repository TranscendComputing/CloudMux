require 'sinatra'

class CloudApiApp < ApiBase
  ##~ sapi = source2swagger.namespace("clouds")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/clouds"
  ##~ a.description = "Manage clouds supported by the system"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "List configured clouds supported by the system"  
  ##~ op.nickname = "list_clouds"
  ##~ op.parameters.add :name => "page", :description => "The page number of the query. Defaults to 1 if not provided", :dataType => "integer", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "per_page", :description => "Result set page size", :dataType => "integer", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Query successful", :code => 200
  ##~ op.errorResponses.add :reason => "API down", :code => 500

  get '/' do
    per_page = (params[:per_page] || 1000).to_i
    page = (params[:page] || 1).to_i
    offset = (page-1)*per_page
    clouds = Cloud.all
    count = Cloud.count
    query = Query.new(count, page, offset, per_page)
    cloud_query = CloudQuery.new(query, clouds).extend(CloudQueryRepresenter)
    [OK, cloud_query.to_json]
  end

  ##~ a = sapi.apis.add   
  ##~ a.set :path => "/api/v1/clouds/{id}.{format}"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Retrieve a specific cloud supported by the system"  
  ##~ op.nickname = "get_cloud"
  ##~ op.parameters.add :name => "id", :description => "ID of the cloud", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Query successful", :code => 200
  ##~ op.errorResponses.add :reason => "API down", :code => 500

  get '/:id.json' do
    cloud = Cloud.find_by_permalink(params[:id]) || Cloud.find(params[:id])
    cloud.extend(CloudRepresenter)
    cloud.to_json
  end

  post '/' do
    new_cloud = Cloud.new.extend(UpdateCloudRepresenter)
    new_cloud.from_json(request.body.read)
    if new_cloud.valid?
      new_cloud.save!
      # refresh without the Update representer, so that we don't serialize private data back
      cloud = Cloud.find(new_cloud.id).extend(CloudRepresenter)
      [CREATED, cloud.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_cloud.errors.full_messages.join(";")}"
      message.validation_errors = new_cloud.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  put '/:id' do
    update_cloud = Cloud.find(params[:id])
    update_cloud.extend(UpdateCloudRepresenter)
    update_cloud.from_json(request.body.read)
    if update_cloud.valid?
      update_cloud.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      cloud = Cloud.find(update_cloud.id).extend(CloudRepresenter)
      [OK, cloud.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_cloud.errors.full_messages.join(";")}"
      message.validation_errors = update_cloud.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  delete '/:id' do
	  cloud = Cloud.find(params[:id])
	  cloud.delete
	  [OK]
  end
end
