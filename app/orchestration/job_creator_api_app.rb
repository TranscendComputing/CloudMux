require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'chef', 'continuous_integration.rb')

class JobCreatorApiApp < ApiBase
  before do
    if params[:manager_id]
      config_manager = ConfigManager.find(params[:manager_id])
      @manager_client = CloudMux::ConfigurationManager.new(config_manager)
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = 'Account ID must be passed in as a parameter'
      halt [BAD_REQUEST, message.to_json]
    end
  end

  post '/' do
    begin
      @manager_client.generate_all_jobs
      @manager_client.get_status
    rescue Mongoid::Errors::DocumentNotFound
      [NOT_FOUND, 'Configuration manager does not exist in database.']
    end
  end

  get '/' do
    begin
      @manager_client.get_status
    rescue Mongoid::Errors::DocumentNotFound
      [NOT_FOUND, 'Configuration manager does not exist in database.']
    end
  end
end
