require 'sinatra'

class CloudApiApp < ApiBase
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
