require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'configuration_manager.rb')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'chef', 'continuous_integration.rb')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'chef', 'manager.rb')

class ConfigManagerValidatorApiApp < ApiBase

  get '/reset' do
    begin
      if params[:manager_id]
        @config_manager = ConfigManager.find(params[:manager_id])
        @manager_client = CloudMux::ConfigurationManager.new(@config_manager)
      else
        message = Error.new.extend(ErrorRepresenter)
        message.message = 'Account ID must be passed in as a parameter'
        halt [BAD_REQUEST, message.to_json]
      end
      @manager_client.ci_client.delete_all_jobs
      @manager_client.generate_all_jobs
      @manager_client.update_status
      [OK, 'OK']
    rescue Mongoid::Errors::DocumentNotFound
      [NOT_FOUND, 'Configuration manager does not exist in database.']
    end
  end

  post '/deploy_suite/:job_name' do
    job_name = params[:job_name]
    deploy_config = body_to_yaml(request)
    config = CloudMux::Chef::ContinuousIntegration.generate_deploy_suites(job_name, deploy_config)
    [OK, config]
  end

end
