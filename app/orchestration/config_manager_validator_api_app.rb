require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'configuration_manager.rb')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'chef', 'continuous_integration.rb')

class ConfigManagerValidatorApiApp < ApiBase

  get '/refresh' do
    begin
      if params[:manager_id]
        @config_manager = ConfigManager.find(params[:manager_id])
        @manager_client = CloudMux::ConfigurationManager.new(@config_manager)
      else
        message = Error.new.extend(ErrorRepresenter)
        message.message = 'Account ID must be passed in as a parameter'
        halt [BAD_REQUEST, message.to_json]
      end
      @manager_client.update_status
      [OK, 'OK']
    rescue Mongoid::Errors::DocumentNotFound
      [NOT_FOUND, 'Configuration manager does not exist in database.']
    end
  end

  post '/deploy_suite' do
    job_name = params[:job_name]
    deploy_config = params[:file]
    config = CloudMux::Chef::ContinuousIntegration.generate_deploy_suites(job_name, deploy_config)
    [OK, config]
  end

end
