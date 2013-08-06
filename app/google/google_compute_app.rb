require 'sinatra'
require 'fog'

class GoogleComputeApp < ResourceApiBase
  
  before do
		if ! params[:cred_id].nil?
			#cloud_cred = get_creds(params[:cred_id])
      cloud_cred = {:google_project => "momentumsi1", :google_client_email => "33172512232@project.gserviceaccount.com", :google_key_location => "~/google_compute_engine.pub"}
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@compute = Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@compute = Fog::Compute::Google.new({:google_project => cloud_cred.google_project, :google_client_email => cloud_cred.google_client_email , :google_key_location => cloud_cred.google_key_location})
				end
			end
		end
		halt [BAD_REQUEST] if @compute.nil?
  end

end