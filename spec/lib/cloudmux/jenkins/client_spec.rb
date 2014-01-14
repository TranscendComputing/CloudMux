require 'service_spec_helper'
require 'cloudmux/jenkins/client'

describe CloudMux::Jenkins::Client do
  let(:client) do
    described_class.new(@client)
  end

  before :each do
    @client = FactoryGirl.build(:jenkins_server)
    @ci_client = double('JenkinsApi::Client')
    @logger = double('Logger')
    @job = double('JenkinsApi::Job')
    JenkinsApi::Client.stub(:new).and_return(@ci_client)
    @ci_client.stub(:logger).and_return(@logger)
    @logger.stub(:level=).with(3).and_return(3)
    @ci_client.stub(:job).and_return(@job)
    @job.stub(:create_or_update).and_return('200')
    @job.stub(:build).and_return('200')
    @job.stub(:get_build_details).with('no_job', 0).and_return(nil)
    @job.stub(:get_build_details)
      .with('deploy_job', 0)
      .and_return('result' => 'PASSING', 'timestamp' => 1389390581000)
    @job.stub(:get_test_results)
      .with('deploy_job', 0)
      .and_return(nil)
    @job.stub(:get_build_details)
      .with('build_job', 0)
      .and_return('result' => 'PASSING', 'timestamp' => 1389390581000)
    @job.stub(:get_test_results)
      .with('build_job', 0)
      .and_return(
        'suites' => [{
          'cases' => [{
            'status' => 'PASSED',
            'timestamp' => ''
          }],
          'name' => 'test' }
        ])
  end

  context 'when job does not exist' do
    describe '#get_status' do
      it 'returns nil' do
        expect(client.get_status('no_job')).to eql(nil)
      end
    end
  end

  context 'when deploy job exists' do
    describe '#get_status' do
      it 'returns a hash' do
        status = client.get_status('deploy_job')
        expect(status).to have_key('global_status')
        expect(status).to have_key('timestamp')
      end
    end
  end

  context 'when build job exists' do
    describe '#get_status' do
      it 'returns a hash' do
        status = client.get_status('build_job')
        expect(status).to have_key('global_status')
        expect(status).to have_key('test')
        expect(status).to have_key('timestamp')
      end
    end
  end
end
