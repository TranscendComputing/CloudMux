require 'service_spec_helper'

describe UpdateProjectRepresenter do

  before :each do
    @project = FactoryGirl.build(:project, :cloud_credential_id=>"abcd")
  end

  describe "#to_json" do
    it "should export to json" do
      @project.extend(UpdateProjectRepresenter)
      result = @project.to_json
      result.should eq("{\"project\":{\"name\":\"#{@project.name}\",\"description\":\"#{@project.description}\",\"project_type\":\"#{@project.project_type}\",\"region\":\"#{@project.region}\",\"cloud_credential_id\":\"#{@project.cloud_credential_id}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"project\":{\"name\":\"#{@project.name}\",\"description\":\"#{@project.description}\",\"project_type\":\"#{@project.project_type}\",\"cloud_credential_id\":\"#{@project.cloud_credential_id}\"}}"
      new_project = Project.new
      new_project.extend(UpdateProjectRepresenter)
      new_project.from_json(json)
      new_project.name.should eq(@project.name)
      new_project.description.should eq(@project.description)
      new_project.project_type.should eq(@project.project_type)
    end
  end
end
