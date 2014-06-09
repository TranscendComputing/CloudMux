require 'sinatra'
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
        # Now ensure that we have credentials 
        me = @ansible.get_me
        user_id = me[0]['id'].to_s
        credentials = @ansible.get_users_credentials(user_id)
        auth = config.auth_properties # shorten
        if credentials.count{|c|c["name"]=="CloudMux"} == 0
          result = @ansible.post_users_credentials(
            user_id,
            "CloudMux", # Something to set this one apart
            auth["ansible_ssh_username"],
            auth["ansible_ssh_password"],
            auth["ansible_ssh_key_data"],
            auth["ansible_ssh_key_unlock"],
            auth["ansible_sudo_username"],
            auth["ansible_sudo_password"])
        end
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

  post '/job_templates/run' do
    begin
      resp = @ansible.post_job_template_run(
        params[:job_template_id],
        params[:host])
      [OK, resp.to_json] 
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
        params[:name],
        params[:description],
        params[:inventory],
        params[:variables])
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
      # The 'name' parameter holds the IP or hostname (fqdn) for the host
      #
      # `name`:  (string, required)
      # `description`:  (string)
      # `inventory`:  (field, required)
      # `variables`: Variables in JSON or YAML format. (string)
      #
      # `last_job`:  (field)
      # `last_job_host_summary`:  (field)
      #
      response = @ansible.post_hosts(
        params[:name], 
        params[:description], 
        params[:inventory], 
        params[:variables])
      [OK, response.to_json]

    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];

    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/hosts/find' do
    instancedata = JSON.parse(request.body.read)
    if(!instancedata || instancedata.length == 0)
      message = Error.new.extend(ErrorRepresenter)
      message.message = "must supply ids of instances to search for"
      [BAD_REQUEST, message.to_json]
    else
      begin
        result = []
        add_instances = []
        hosts = get_hosts()
        instances.each_with_index{|inst|
          name = inst["name"]
          ips = inst["ip_addresses"]
          host =  hosts.select{ |h| ips.include? h['name']}
          if host.length > 0
            result << host[0]
          else
            # add hosts not already in results
            add_instances << inst
          end
        }
        add_instances.each {|inst|
          name = inst["name"]
          ips = inst["ip_addresses"]
          host = post_hosts(
            ips[-1], # Using the last ip address for name
            name) # SS name for Ansible description
          result << {:name => host}
        }
      rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message=>"could not connect to Ansible."}.to_json]
      end
      [OK, result.to_json];
    end
  end


  delete '/hosts/:host_id' do
    begin
      response = @ansible.delete_hosts(:host_id=>params[:host_id])
      [OK, response.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];

    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  # [XXX] From the url it is not transparent what this method does
  put '/hosts/:host_id' do
    begin
      jobs = JSON.parse(request.body.read)['jobtemplates']
      # we use the hostname for the limit option
      host = @ansible.get_hosts(params[:host_id])
      success = @ansible.post_job_templates_run(jobs, host['name'])
      if success == false
        return [BAD_REQUEST, {}]
      end
      [OK, {}]
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
        params[:name], 
        params[:description] )
      [OK, response.to_json]

    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];

    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  get '/users/' do
    begin
      users = @ansible.get_users
      [OK, users.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/users/' do
    begin
      # `username`: Required. 30 characters or fewer. Letters, numbers and @/./+/-/_ characters (string, required)
      # `first_name`:  (string)
      # `last_name`:  (string)
      # `email`:  (email)
      # `is_superuser`: Designates that this user has all permissions without explicitly assigning them. (boolean)
      # `password`: Write-only field used to change the password. (field)
      response = @ansible.post_users(
        params[:username],
        params[:first_name],
        params[:last_name],
        params[:email],
        password[:password])
      [OK, response.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end
  
  get '/users/:user_id/credentials' do
    begin
      credentials = @ansible.get_users_credentials(params[:user_id])
      [OK, credentials.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/users/:user_id/credentials' do
    begin
      # `name`:  (string, required)
      # `description`:  (string)
      # `ssh_username`: SSH username for a job using this credential. (string)
      # `ssh_password`:  (field)
      # `ssh_key_data`:  (field)
      # `ssh_key_unlock`:  (field)
      # `sudo_username`: Sudo username for a job using this credential. (string)
      # `sudo_password`:  (field)
      # `user`:  (field)
      # `team`:  (field)
      response = @ansible.post_users_credentials(
        params[:user_id],
        params[:name],
        params[:ssh_username],
        params[:ssh_password],
        params[:ssh_key_data],
        params[:ssh_key_unlock],
        params[:sudo_username],
        params[:sudo_password])
      [OK, response.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end

  post '/users/:user_id/credentials_remove/:credentials_id' do
    begin
      response = @ansible.post_users_credentials_remove(
        params[:user_id],
        params[:credentials_id])
      [OK, response.to_json]
    rescue RestClient::Unauthorized
        [BAD_REQUEST, {:message => "Invalid Ansible user/password combination."}];
    rescue Errno::ECONNREFUSED
        [BAD_REQUEST, {:message => "Connection was refused"}]
    end
  end
end
