require 'sinatra'
require 'fog'

class VCloudApp < ResourceApiBase
  before do
    cloud_cred = get_creds(params[:cred_id])
    if cloud_cred.nil?
      halt [BAD_REQUEST, 'Credentials not found.']
    else
      @compute = Fog::Compute.new(
        :provider => 'vclouddirector',
        :vcloud_director_username => cloud_cred.cloud_attributes['vcloud_username'],
        :vcloud_director_password => cloud_cred.cloud_attributes['vcloud_api_key'],
        :vcloud_director_host => cloud_cred.cloud_attributes['vcloud_director_url'],
        :vcloud_director_show_progress => false,
        :connection_options => {
          :ssl_verify_peer => false
        }
      )
      @org = @compute.organizations.get_by_name(cloud_cred.cloud_attributes['vcloud_organization'])
    end
  end
end
