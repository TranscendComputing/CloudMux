require 'spec_helper'
require File.join(File.dirname(__FILE__), '..','..','lib','ansible','rest_client')


describe "AnsibleRestClient" do
  it 'should initialize' do
    pending "needs to finish"
    uri = URI  'https://the.ansibleserver.com/api/v1/authtoken/'
    resp = JSON.load Net::HTTP.get(uri)
    expect(resp.to eq [])
  end
end
