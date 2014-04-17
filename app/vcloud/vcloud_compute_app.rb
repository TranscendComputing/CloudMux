require 'sinatra'
require 'fog'

class VCloudComputeApp < VCloudApp

	before do
		if(params[:cred_id].nil? || ! Auth.validate(params[:cred_id],"Identity","action"))
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Cannot access this service under current policy."
      halt [NOT_AUTHORIZED, message.to_json]
    else
      cloud_cred = get_creds(params[:cred_id])
      if cloud_cred.nil?
        halt [NOT_FOUND, "Credentials not found."]
      else
        options = cloud_cred.cloud_attributes.merge(:provider => "vcloud")
        puts options
        @compute = Fog::Compute::VcloudDirector.new(
					:vcloud_director_username => options["vcloud_username"],
				  :vcloud_director_password => options["vcloud_api_key"],
				  :vcloud_director_host => options["vcloud_director_url"],
				  :vcloud_director_show_progress => false,
				  :scheme => "https",
				  :port => 443
				)
				puts @compute.organizations.to_json
				# @org = @compute.organizations.get_by_name(options["vcloud_organization"])
      end
    end
	end

	get '/data_centers' do
		vdcs = @org.vdcs
		[OK, vdcs.to_json]
	end

	get '/data_centers/:id' do
		vdc = @org.vdcs.get_by_id(params[:id])
		[OK, vdc]
	end

	get '/vms' do
		vdc = @org.vdcs.get_by_id(params[:data_center_id])
		vms = vdc.vms
		[OK, vms]
	end

	post '/vms/power_on' do

	end


	get '/organizations' do
		orgs = @compute.organizations
		[OK, orgs.to_json]
	end
end