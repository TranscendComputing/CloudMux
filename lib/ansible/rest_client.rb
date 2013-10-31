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

    def get_job_templates
      resp = @rest['/api/v1/job_templates'].get
      job_templates = JSON.parse(resp)["results"]
      return job_templates
    end

    def get_inventories
      resp = @rest['/api/v1/inventories'].get
      hosts = JSON.parse(resp)["results"]
      return hosts
    end

  end
end
