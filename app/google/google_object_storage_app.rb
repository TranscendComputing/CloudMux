require 'sinatra'
require 'fog'

class GoogleObjectStorageApp < ResourceApiBase
  before do
    cred_id = params[:cred_id]
    if ! cred_id.nil?
      cloud_cred = get_creds(cred_id)
      if ! cloud_cred.nil?
        @object_storage = Fog::Storage::Google.new({
          :google_storage_access_key_id     => cloud_cred.cloud_attributes['google_storage_access_key_id'],
          :google_storage_secret_access_key => cloud_cred.cloud_attributes['google_storage_secret_access_key']
        })
      end
    end
    halt [BAD_REQUEST] if @object_storage.nil?
  end

  #
  # Buckets
  #
  get '/directories' do
    response = params[:filters].nil? ?
      @object_storage.directories :
      @object_storage.directories.all(params[:filters])
    [OK, response.to_json]
  end

  post '/directories' do
    json_body = body_to_json(request)
    halt [BAD_REQUEST] if json_body.nil?

    response = @object_storage.directories.create(json_body["directory"])
    [OK, response.to_json]
  end

  before %r{/directories/([\w]+).*} do |id|
    @dir = @object_storage.directories.get(id)
    halt NOT_FOUND if @dir.nil?
  end

  delete '/directories/:id' do
    response = @dir.destroy
    [OK, response.to_json]
  end

  #
  # Files
  #
  get '/directories/:id/files' do
    response = @dir.files
    [OK, response.to_json]
  end

  post '/directory/file/download' do
    file, directory = params[:file], params[:directory]
    halt [BAD_REQUEST] if file.nil? || directory.nil?

    response = @object_storage.directories.get(directory).files.get(file)
    headers["Content-disposition"] = "attachment; filename=" + file
    [OK, response.to_json]
  end

  post '/directory/file/upload' do
    file, directory = params[:file_upload], params[:directory]
    halt [BAD_REQUEST] if file.nil? || directory.nil?

    response = @object_storage.put_object(directory, file[:filename], file[:tempfile])
    [OK, response.to_json]
  end

  delete '/directories/:id/files/:file_id' do
    response = @object_storage.delete_object(params[:id], params[:file_id]).body
    [OK, response.to_json]
  end
end
