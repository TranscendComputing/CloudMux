require 'sinatra'
require 'debugger'
require 'json'

require File.join(File.dirname(__FILE__),'..','..','lib','ansible','rest_client.rb')

class AnsibleApiApp < ApiBase

  before do
    if params[:account_id]
      cloud_acc = CloudAccount.find(params[:account_id])
      config = cloud_acc.config_managers.select{
        |c| c['type'] == 'ansible'}[0]
      if config
       url = config.protocol + "://" + config.host + ":" + config.port
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
  end

  get '/playbooks' do
    begin
      ## Results
      #
      #Each job template data structure includes the following fields:
      #
      #* `id`: Database ID for this job template. (integer, read-only)
      #* `url`: URL for this job template. (string, read-only)
      #* `related`: Data structure with URLs of related resources. (object, read-only)
      #* `summary_fields`: Data structure with name/description for related resources. (object, read-only)
      #* `created`: Timestamp when this job template was created. (datetime, read-only)
      #* `modified`: Timestamp when this job template was last modified. (datetime, read-only)
      #* `name`:  (string, required)
      #* `description`:  (string)
      #* `job_type`:  (multiple choice, required)
      #* `inventory`:  (field)
      #* `project`:  (field)
      #* `playbook`:  (string, required)
      #* `credential`:  (field)
      #* `forks`:  (integer)
      #* `limit`:  (string)
      #* `verbosity`:  (integer)
      #* `extra_vars`:  (string)
      #* `job_tags`:  (string)
      #* `host_config_key`:  (string)
      #
      results = @ansible.list_job_templates
      [OK, results.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end
end
