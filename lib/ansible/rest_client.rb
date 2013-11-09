require 'rest-client'
require 'json'
require 'debugger'

# [XXX] Logging...
#RestClient.log = "/home/thethethe/Development/MomentumSI/CloudMux/rest_log"

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

    def get_inventories
      resp = @rest['/api/v1/inventories/'].get
      JSON.parse(resp)["results"]
    end

    def post_inventories(name,description, organization,variables)
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

    def get_hosts
      resp = @rest['/api/v1/hosts'].get
      JSON.parse(resp)["results"]
    end

    def post_hosts(name,description, inventory,variables)
      resp = @rest['/api/v1/hosts'].post({
        :name => name,
        :description => description,
        :inventory => '1', # [XXX] Hardcoding to 1 for simplicity...
        :variables => variables
      })
      JSON.parse(resp)["results"]
    end

    def delete_hosts(host_id)
      resp = @rest['/api/v1/hosts/'+host_id].delete
      JSON.parse(resp)["results"]
    end

    def get_groups
      resp = @rest['/api/v1/groups'].get
      JSON.parse(resp)["results"]
    end

    def post_groups(name,description, inventory,variables)
      resp = @rest['/api/v1/groups'].post({
        :name => name,
        :description => description,
        :inventory => inventory,
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

    def find_hosts (instances)
      result = []
      hosts = get_hosts
      instances.each_with_index{|inst, i|
        name = inst["name"]
        ips = inst["ip_addresses"]
        host =  hosts.select{ |h| ips.include? h['name']}
        if host.length > 0
          result << {:name => host[:description]}
        else
          result << {}
        end
      }
      return result
    end
  end
end
