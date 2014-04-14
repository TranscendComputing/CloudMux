require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'configuration_manager.rb')

class ConfigManagerApiApp < ApiBase
   # Get a Config Manager by ID
  get '/:id' do
    cm = ConfigManager.where(id: params[:id]).first
      if cm.nil?
        [NOT_FOUND]
      else
        [OK, cm.to_json]
      end
  end
   # Get Config Managers for org
  get '/org/:org_id' do
    cms = ConfigManager.where(org_id: params[:org_id])
    response = []
    cms.each do |cm|
      response << cm.as_json
    end
    [OK, response.to_json]
  end

   # Create a Config Manager
  post '/' do
    json_body = body_to_json(request)
    if json_body.nil?
      [BAD_REQUEST]
    else
      case json_body['type']
      when 'chef'
        new_manager = ChefConfigurationManager.new(json_body)
      when 'puppet'
      # TODO: new Puppet that inherits ConfigManager
        new_manager = ConfigManager.new(json_body)
      when 'salt'
      # TODO: new Salt that inherits ConfigManager
        new_manager = ConfigManager.new(json_body)
      when 'ansible'
      # TODO: new Ansible that inherits ConfigManager
        new_manager = ConfigManager.new(json_body)
      else
        new_manager = ConfigManager.new(json_body)
      end
      if new_manager.valid?
        new_manager.save!
        [CREATED, new_manager.to_json]
      else
        [BAD_REQUEST]
      end
    end
  end

  # Update a Config Manager
  put '/:id' do
    json_body = body_to_json(request)
    if json_body.nil?
      [BAD_REQUEST]
    else
      update_cm = ConfigManager.where(id: params[:id]).first
      if update_cm.nil?
        [NOT_FOUND]
      else
        begin
          update_cm.update_attributes!(json_body)
          [OK, update_cm.to_json]
        rescue
          [BAD_REQUEST]
        end
      end
    end
  end

  # Delete a Config Manager
  delete '/:id' do
    cm = ConfigManager.where(id: params[:id]).first
    if cm.nil?
      [NOT_FOUND]
    else
      cm.delete
      [OK, { 'message' => 'Config Manager Deleted' }.to_json]
    end
  end

  # Update  Config Manager Component
  put '/:id/components/:component_id' do
    cm = ConfigManager.where(id: params[:id]).first
    if cm.nil?
      [NOT_FOUND]
    else
      case cm.type
      when "chef"
        component = cm.cookbooks.where(id: params[:component_id]).first
      end

      if component.nil?
        [NOT_FOUND]
      else
        json_body = body_to_json(request)
        if json_body.nil?
          [BAD_REQUEST]
        else
          component.update_attributes!(json_body)
          updated_cm = ConfigManager.where(id: params[:id]).first
          [OK, updated_cm.to_json]
        end
      end
    end
  end
end
