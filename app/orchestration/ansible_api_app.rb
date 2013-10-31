require 'sinatra'
require 'debugger'
require 'json'

require File.join(File.dirname(__FILE__),'..','..','lib','ansible','rest_client.rb')

#
# [XXX] The AWX API supports filtering for get requests... we don't yet
# [XXX] Don't-Repeat-Yourself! (the rescues in my code are obviously not DRY)
#

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

  get '/job_templates' do
    begin
      results = @ansible.get_job_templates
      [OK, results.to_json]
      ## Results
      #
      #Each job template data structure includes the following fields:
      #
      # `id`: Database ID for this job template. (integer, read-only)
      # `url`: URL for this job template. (string, read-only)
      # `related`: Data structure with URLs of related resources. (object, read-only)
      # `summary_fields`: Data structure with name/description for related resources. (object, read-only)
      # `created`: Timestamp when this job template was created. (datetime, read-only)
      # `modified`: Timestamp when this job template was last modified. (datetime, read-only)
      # `name`:  (string, required)
      # `description`:  (string)
      # `job_type`:  (multiple choice, required)
      # `inventory`:  (field)
      # `project`:  (field)
      # `playbook`:  (string, required)
      # `credential`:  (field)
      # `forks`:  (integer)
      # `limit`:  (string)
      # `verbosity`:  (integer)
      # `extra_vars`:  (string)
      # `job_tags`:  (string)
      # `host_config_key`:  (string)
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];

    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

# The hierarchy of Ansible goes like this:
# Inventories -> Groups -> Hosts
# nevar forget.
  get '/inventories' do 
    begin
      inventories = @ansible.get_inventories 
      [OK, inventories.to_json]

    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/inventories' do
    begin
      # Params for inventories post
      # * `name`:  (string, required)
      # * `description`:  (string)
      # * `organization`:  (field, required)
      # * `variables`: Variables in JSON or YAML format. (string)
      response = @ansible.post_inventories(
        :name => params[:name],
        :description => params[:description],
        :organization => params[:organization],
        :variables => params[:variables])
      [OK, response.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  get '/groups' do 
    begin
      # A groups result from ansible looks like:
      #  `id`: Database ID for this group. (integer, read-only)
      #  `url`: URL for this group. (string, read-only)
      #  `related`: Data structure with URLs of related resources. (object, read-only)
      #  `summary_fields`: Data structure with name/description for related resources. (object, read-only)
      #  `created`: Timestamp when this group was created. (datetime, read-only)
      #  `modified`: Timestamp when this group was last modified. (datetime, read-only)
      #  `name`:  (string, required)
      #  `description`:  (string)
      #  `inventory`:  (field, required)
      #  `variables`: Variables in JSON or YAML format. (string)
      #  `has_active_failures`:  (boolean, read-only)
      groups = @ansible.get_groups
      [OK, groups.to_json]

    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/groups' do
    begin
      # Request params expected in AWX:
      # `name`:  (string, required)
      # `description`:  (string)
      # `inventory`:  (field, required)
      # `variables`: Variables in JSON or YAML format. (string)
      #
      response = @ansible.post_groups(
        :name => params[:name],
        :description => params[:description],
        :inventory => params[:inventory],
        :variables => params[:variables])
      [OK, response.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  get '/hosts' do 
    begin
      hosts = @ansible.get_hosts 
      [OK, hosts.to_json]
      #Each host data structure includes the following fields:
      #
      # `id`: Database ID for this host. (integer, read-only)
      # `url`: URL for this host. (string, read-only)
      # `related`: Data structure with URLs of related resources. (object, read-only)
      # `summary_fields`: Data structure with name/description for related resources. (object, read-only)
      # `created`: Timestamp when this host was created. (datetime, read-only)
      # `modified`: Timestamp when this host was last modified. (datetime, read-only)
      # `name`:  (string, required)
      # `description`:  (string)
      # `inventory`:  (field, required)
      # `variables`: Variables in JSON or YAML format. (string)
      # `has_active_failures`:  (boolean, read-only)
      # `last_job`:  (field)
      # `last_job_host_summary`:  (field)
      #
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/hosts' do
    begin
      # [XXX] I need to figure out what the last_job* params are for
      #
      # Expected params
      # `name`:  (string, required)
      # `description`:  (string)
      # `inventory`:  (field, required)
      # `variables`: Variables in JSON or YAML format. (string)
      #
      # `last_job`:  (field)
      # `last_job_host_summary`:  (field)
      #
      response = @ansible.post_hosts(
        :name => params[:name], 
        :description => params[:description], 
        :inventory => params[:inventory], 
        :variables=> params[:variables])
      [OK, response.to_json]

    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];

    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end

  end

  get '/organizations' do 
    begin
      hosts = @ansible.get_organizations
      [OK, hosts.to_json]
      ## Results
      #
      #Each organization data structure includes the following fields:
      #
      # `id`: Database ID for this organization. (integer, read-only)
      # `url`: URL for this organization. (string, read-only)
      # `related`: Data structure with URLs of related resources. (object, read-only)
      # `summary_fields`: Data structure with name/description for related resources. (object, read-only)
      # `created`: Timestamp when this organization was created. (datetime, read-only)
      # `modified`: Timestamp when this organization was last modified. (datetime, read-only)
      # `name`:  (string, required)
      # `description`:  (string)
      #
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/organizations' do
    begin
      # Expected params
      # `name`:  (string, required)
      # `description`:  (string)
      response = @ansible.post_organizations(
        :name => params[:name], 
        :description => params[:description] )
      [OK, response.to_json]

    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];

    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end

  end
end
