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
        :inventory => inventory,
        :variables => variables
      })
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

  end
end
