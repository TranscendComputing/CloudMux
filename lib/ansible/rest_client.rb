require 'rest-client'
require 'json'
require 'debugger'

# [TODO] Use Logging module; ie lib/salt/rest_client
RestClient.log = "/home/thethethe/Development/MomentumSI/CloudMux/rest_log"

class Ansible
  class Client
		def initialize(url, user, password)
			resp = RestClient.post(url+"/api/v1/authtoken/", {:username=>user,
				:password=>password})
			auth_token = JSON.parse(resp)["token"]
			@rest = RestClient::Resource.new(
				"#{url}/",
				:headers => {:accept=>"application/json",
					"Authorization"=>"Token " +auth_token}
			)
		end	

    def get_me
      resp = @rest['/api/v1/me'].get
      JSON.parse(resp)["results"]
    end

    # [XXX] All of these requests return paged results - no support
    # for that as of yet.
    def get_job_templates
      resp = @rest['/api/v1/job_templates/'].get
      # ruby's implicit return
      JSON.parse(resp)["results"]
    end

    def post_job_templates_run(job_template_ids, host)
     success = true
     job_template_ids.each{ |job_template_id|
        data = {
          :name => "CloudMux triggered job %d for host %s" % [job_template_id, host],
          :job_type => 'run',
          :limit => host}
        url = '/api/v1/job_templates/%d/jobs/' % job_template_id
        resp = @rest[url].post(data)
        #[TODO] add error handling for all these calls
        job_id = JSON.parse(resp)['id']
        url = '/api/v1/jobs/%d/start/' % job_id
        resp = @rest[url].post({})
        # check if failed
        resp = @rest['/api/v1/jobs/%d/' %job_id].get
        if JSON.parse(resp)['failed'] == true
          success = false
        end
      }
      if success
        return true
      end
      false
    end

    def get_inventories
      resp = @rest['/api/v1/inventories/'].get
      JSON.parse(resp)["results"]
    end

    def post_inventories(name,description, organization=1,variables='')
      resp = @rest['/api/v1/hosts'].post({
        :name => name,
        :description => description,
        :organization => organization,
        :variables => variables
      })
      #[XXX] Theoretical what this is at this point - need to see 
      # actual response
      JSON.parse(resp)["results"]
    end

    def get_hosts(id=nil)
      url = '/api/v1/hosts' 
      if id
        url = '/api/v1/hosts/%s/' %id
      end
      resp = @rest[url].get
      if id
        return JSON.parse(resp)
      end
      JSON.parse(resp)["results"]
    end

    def post_hosts(name,description, variables='')
      resp = @rest['/api/v1/hosts/'].post({
        :name => name,
        :description => description,
        :inventory => '1', # 'same inventory, we use 'limit' on other calls to choose hosts
        :variables => variables
      })
      host = JSON.parse(resp)
      resp = @rest['/api/v1/hosts/%d/groups/' % host['id']].post({:id=>'1'})
      host
    end

    def delete_hosts(host_id)
      resp = @rest['/api/v1/hosts/'+host_id].delete
      JSON.parse(resp)["results"]
    end

    def get_groups
      resp = @rest[url].get
      JSON.parse(resp)["results"]
    end

    def post_groups(name,description, inventory,variables)
      resp = @rest['/api/v1/groups'].post({
        :name => name,
        :description => description,
        :inventory => '1',
        :variables => variables
      })
      JSON.parse(resp)["results"]
    end

    def get_organizations
      resp = @rest['/api/v1/organizations'].get
      JSON.parse(resp)["results"]
    end

    def post_organizations(name,description, inventory,variables)
      resp = @rest['/api/v1/organizations'].post({
        :name => name,
        :description => description })
      JSON.parse(resp)["results"]
    end

    def get_users
      resp = @rest['/api/v1/users/'].get
      JSON.parse(resp)["results"]
    end

    def post_users(username, first_name, last_name, email, password)
      resp = @rest['/api/v1/users/'].post(
        :username => username,
        :first_name => first_name,
        :last_name => last_name,
        :email => email,
        :password => password)
      JSON.parse(resp)["results"]
    end

    def get_users_credentials(user_id)
      resp = @rest['/api/v1/users/'+user_id+'/credentials'].get
      JSON.parse(resp)["results"]
    end

    def post_users_credentials(user_id, name, ssh_username, ssh_password, ssh_key_data,
      ssh_key_unlock, sudo_username, sudo_password)
      resp = @rest['/api/v1/users/'+user_id+'/credentials/'].post(
        name,
        ssh_username,
        ssh_password,
        ssh_key_data,
        ssh_key_unlock,
        sudo_username,
        sudo_password)
      JSON.parse(resp)["results"]
    end

    def post_users_credentials_remove(user_id, credentials_id)
      resp = @rest['/api/v1/users/'+user_id+'/credentials/'].post(
        :id => credentials_id,
        :disassociate => true)
      JSON.parse(resp)["results"]
    end

    # [TODO] move the logic here to ansible_api_app
    def post_find_hosts (instances)
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
      return result
    end
  end
end
