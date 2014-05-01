require 'sinatra'
require 'fog'

class VCloudApp < ResourceApiBase
	before do
        cloud_cred = get_creds(params[:cred_id])
        if cloud_cred.nil?
        	halt [BAD_REQUEST, "Credentials not found."]
        else
	        options = cloud_cred.cloud_attributes.merge(:provider => "vcloud")
	        puts options
	        @compute = Fog::Compute::VcloudDirector.new(
					  :vcloud_director_username => options["vcloud_username"],
					  :vcloud_director_password => options["vcloud_api_key"],
					  :vcloud_director_host => options["vcloud_director_url"],
					  :vcloud_director_show_progress => false
					)
			@org = @compute.organizations.get_by_name(options["vcloud_organization"])
  		end
	end
end