# require 'rspec'
# require 'cloudmux/configuration_manager/chef'

# describe CloudMux::ConfigurationManager::Chef do
#   let(:cookbook_name) { 'sample_component' }
#   let(:cookbook_version) { 'latest' }
#   let(:chef_server_url) {'https://api.opscode.com/organizations/cstewart_dev'}
#   let(:chef_client_name) { 'cstewart' }
#   let(:chef_client_key) { "#{ENV['HOME']}/.chef/cstewart_dev/cstewart.pem" }
#   let(:scm_repo_url) { File.join(File.dirname(__FILE__), '..', 'scm', 'fixtures', 'sample_repo.git') }
#   let(:scm_repo_name) { 'sample_chef_repo' }
#   let(:scm_branch) { 'develop' }
#   let(:scm_paths) { %w{ cookbooks/profiles cookbooks/components } }
#   let(:ci_server_url) { 'http://localhost:8080' }
#   let(:ci_test_result) {
#     {
#       "empty"=>false,
#       "failCount"=>0,
#       "passCount"=>43,
#       "skipCount"=>0,
#       "suites"=> [
#         { "cases"=> [{ "name"=>"foodcritic", "status"=>"PASSED" },{ "name"=>"foodcritic", "status"=>"PASSED" }], "name"=>"foodcritic" },
#         { "cases"=> [{ "name"=>"alpha_auth", "status"=>"PASSED" }], "name"=>"knife_cookbook_test" }
#       ]
#     }
#   }
#   let(:manager) do
#     described_class.new(chef_server_url, chef_client_name, chef_client_key,
#       repo_name: scm_repo_name,
#       scm_paths: scm_paths,
#       scm_branch: scm_branch,
#       scm_url: scm_repo_url,
#       jenkins_server: ci_server_url
#     )
#   end


#   before(:each) do
#     @server_client = double('Ridley')
#     @cookbook_resource = double('Ridley::CookbookResource')
#     Ridley.stub(:new).and_return(@server_client)
#     @server_client.stub(:cookbook).and_return(@cookbook_resource)
#     @cookbook_resource.stub(:download).and_return('')
#     @ci_client = double('JenkinsApi::Client')
#     @logger = double('Logger')
#     @job = double('JenkinsApi::Job')
#     JenkinsApi::Client.stub(:new).and_return(@ci_client)
#     @ci_client.stub(:logger).and_return(@logger)
#     @logger.stub(:level=).with(3).and_return(3)
#     @ci_client.stub(:job).and_return(@job)
#     @job.stub(:get_test_results).and_return(ci_test_result)
#     @job.stub(:create_or_update).and_return('200')
#     @job.stub(:build).and_return('200')
#   end

#   after(:each) do
#     manager.cleanup
#   end


#   describe '#new' do
#     it 'takes four parameters and returns a CloudMux::ConfigurationManager::Chef object' do
#       manager.should be_instance_of CloudMux::ConfigurationManager::Chef
#     end
#   end

#   describe '#url' do
#     it 'returns correct Chef server url' do
#       manager.url.should eql chef_server_url
#     end
#   end

#   describe '#client_name' do
#     it 'returns correct Chef server client_name' do
#       manager.client_name.should eql chef_client_name
#     end
#   end

#   describe '#client_key' do
#     it 'returns correct Chef server client_key' do
#       manager.client_key.should eql chef_client_key
#     end
#   end

#   describe '#check_repo_sync' do
#     it 'diffs Chef server cookbook and repo cookbook'
#     # it 'diffs Chef server cookbook and repo cookbook' do
#     #   manager.check_repo_sync('sample_profile').should eql true
#     # end
#   end  

#   describe '#create_build_job' do
#     it 'creates ci build job for single cookbook' do
#       manager.create_build_job('sample_profile').should eql '200'
#     end
#   end

#   describe '#create_deploy_job' do
#     it 'creates deploy job for single cookbook' do
#       manager.create_deploy_job('sample_profile', 'vagrant', 'ubuntu-12.04').should eql '200'
#     end
#   end

#   describe '#generate_all_build_jobs' do
#     it 'creates build jobs for all cookbooks' do
#       manager.generate_all_build_jobs.should be_instance_of Array
#     end
#   end

#   describe '#generate_all_deploy_jobs' do
#     it 'creates deploy jobs for all cookbooks' do
#       manager.generate_all_deploy_jobs.should be_instance_of Hash
#     end
#   end

#   describe '#generate_deploy_suites' do
#     it 'creates yaml file for deploy job' do
#       gen_conf = manager.generate_deploy_suites('sample_profile__develop__vagrant_ubuntu-12.04__chef')
#       gen_conf.should be_instance_of String
#     end
#   end

#   describe '#build_all' do
#     it 'builds all managed jobs' do
#       manager.build_all.should be_instance_of Array
#     end
#   end

#   describe '#get_build_status' do
#     it 'returns ci build status of all generated jobs' do
#       manager.get_build_status.should be_instance_of Array
#     end
#   end  

#   describe '#cleanup' do
#     it 'removes all tmp directories that have been created' do
#       removed_dir = manager.cleanup
#       File.exists?(removed_dir.first).should eql false
#     end
#   end

# end