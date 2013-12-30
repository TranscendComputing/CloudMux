require 'sinatra'
require 'debugger'
require 'json'

class ConfigManagerValidatorApiApp < ApiBase
  before do
    if params[:manager_id]
      @manager = ConfigManager.find(params[:manager_id])
      @client = CloudMux::ConfigurationManager::Chef.new(
        @manager.url,
        @manager.auth_properties.name,
        @manager.auth_properties.key,
        jenkins_server: @manager.continuous_integration_server.url,
        scm_url: @manager.source_control_uri,
        scm_branch: @manager.branch,
        scm_paths: @manager.source_control_paths,
        repo_name: @manager.repo_name
      )
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = 'Account ID must be passed in as a parameter'
      halt [BAD_REQUEST, message.to_json]
    end
  end

  post '/:manager_id' do
    begin
      @client.generate_all_build_jobs
      @client.generate_all_deploy_jobs
    rescue Mongoid::Errors::DocumentNotFound
      [NOT_FOUND, 'Configuration manager does not exist in database.']
    end
  end

  get '/:manager_id' do
    begin
      response = @client.get_build_status
    rescue Mongoid::Errors::DocumentNotFound
      [NOT_FOUND, 'Configuration manager does not exist in database.']
    end
  end  
end
