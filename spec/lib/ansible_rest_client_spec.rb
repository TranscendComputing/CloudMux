require 'spec_helper'
require File.join(File.dirname(__FILE__), '..','..','lib','ansible','rest_client')
=begin
describe "Ansible::Client" do

  before :each do
    @ansible = Ansible::Client.new(
      'https://the.ansibleserver.com', 'user', 'pass')
  end

  describe "#get_me" do
    it "should return information about current Ansible user" do
      pending 'finishing mock api'
      r = @ansible.get_me
      expect r.to eq []
    end
  end

  describe "#get_job_templates" do
    it "should return valid job templates" do
      pending 'finishing mock api'
      r = @ansible.get_job_templates
      expect r.to eq []
    end
  end

  describe "#post_job_templates_run" do
    it "should expect job_template_ids and host for argments" do
      pending 'finishing mock api'
      r = @ansible.post_job_templates_run(job_template_ids,host)
      expect r.to eq []
    end
  end

end
=end
