require 'sinatra'
require 'debugger'
require 'json'

require File.join(File.dirname(__FILE__),'..','..','lib','salt','rest_client.rb')

class AnsibleApiApp < ApiBase

  before do
    if params[:account_id]
      cloud_acc = CloudAccount.find(params[:account_id])
      config = cloud_acc.config_managers.select{
        |c| c['type'] == 'ansible'}[0]
      if ansible_config
       url = conffig.protocol + "://" + config.host + ":" + config.port
       @ansible = Ansible::Client.new(url, 
        config.auth_properties['ansible_user'], 
        config.auth_properties['ansible_pass'])
      else
        message = Error.new.extend(ErrorRepresenter)
        message.message = "Must configure an Ansible server with the cloud account"
        halt [BAD_REQUEST, message.to_json]
      end
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Account ID must be passed in as a parameter"
      halt[BAD_REQUEST, message.to_json]
    end

    get '/inventory' do
      begin
        result = @ansible.get_inventory
        [OK, result.to_json]
      rescue RestClient::Unauthorized
          [UNAUTHORIZED, {:message => "Invalid Ansible user/password combination."}];
      rescue Errno::ECONNREFUSED
          [BAD_REQUEST, {:message => "Connection was refused"}]
      end

