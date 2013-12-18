require 'sinatra/base'

class FakeAnsible < Sinatra::Base
  post '/api/v1/authtoken' do
    json_response 200, 'ansible/authtoken_ok.json'
  end

  post '/api/v1/me' do
    json_response 200, 'ansible/me_ok.json'
  end

  get 'api/v1/job_templates' do
    json_response 200, 'ansible/job_templates_ok.json'
  end

  get '/api/v1/job_templates/1/jobs' do
    json_response 200, 'ansible/job_templates_1_jobs_ok.json'
  end

  get '/api/v1/inventories' do
    json_response 200, 'ansible/inventories_ok.json'
  end

  get '/api/v1/hosts' do
    json_response 200, 'ansible/hosts_ok.json'
  end

  post '/api/v1/hosts' do
    json_response 200, 'ansible/post_hosts_ok.json'
  end

  post '/api/v1/hosts/1/groups' do
    json_response 200, 'ansible/post_hosts_1_groups_ok.json'
  end

  delete '/api/v1/hosts/1' do
    json_response  204, 'ansible/delete_hosts_1_nocontent.json'
  end

  post '/api/v1/groups' do
    json_response 200, 'ansible/post_groups_ok.json'
  end

  get '/api/v1/organizations' do
    json_response 200, 'ansible/get_organizations_ok.json'
  end

  post '/api/v1/organizations' do
    json_response 200, 'ansible/post_organizations_ok.json'
  end

  get '/api/v1/users' do
    json_response 200, 'ansible/get_users_ok.json'
  end

  post '/api/v1/users' do
    json_response 200, 'ansible/post_users_ok.json'
  end

  get '/api/v1/users/1/credentials' do
    json_response 200, 'ansible/get_users_1_credentials_ok.json'
  end

  # [TODO] missing coverage for post_users_credentials_remove
  post '/api/v1/users/1/credentials' do
    json_response 200, 'ansible/post_users_1_credentials_ok.json'
  end

  private
  def json_response(response_code, filename)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__),'/fixtures/'+filename,'rb').read
  end
end
