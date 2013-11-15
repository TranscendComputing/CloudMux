require 'app_spec_helper'
require 'ruby-debug'

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'project_api_app')

include HttpStatusCodes

describe ProjectApiApp do
  def app
    ProjectApiApp
  end

  before :each do
    @cloud_credential = FactoryGirl.build(:cloud_credential)    
    @account_1 = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
    #@account_1.cloud_credentials << @cloud_credential
    @account_1.save
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "GET /" do
    before :each do
      @owner = FactoryGirl.create(:account, :login=>"owner_1", :email=>"owner_1@example.com")
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      FactoryGirl.create_list(:project, 15, :cloud_credential_id=>@cloud_credential.id.to_s, :project_type=>Project::STANDARD, :owner=>@account_1)
      FactoryGirl.create_list(:project, 3, :cloud_credential_id=>@cloud_credential.id.to_s, :project_type=>Project::EMBEDDED, :owner=>@account_1)
      @total = Project.count
    end

    describe "defaults" do
      before :each do
        get "/"
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return all results by default" do
        @project_query = ProjectQuery.new
        @project_query.extend(ProjectQueryRepresenter)
        @project_query.from_json(last_response.body)
        @project_query.query.should_not eq(nil)
        @project_query.projects.length.should eq(@total)
        @project_query.query.offset.should eq(0)
        @project_query.query.total.should eq(@total)
        @project_query.query.page.should eq(1)
      end
    end

    describe "project_type filter" do
      before :each do
        get "/?project_type=#{Project::EMBEDDED}"
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return all results by default" do
        @project_query = ProjectQuery.new
        @project_query.extend(ProjectQueryRepresenter)
        @project_query.from_json(last_response.body)
        @project_query.query.should_not eq(nil)
        @project_query.projects.length.should eq(3)
        @project_query.query.offset.should eq(0)
        @project_query.query.total.should eq(3)
        @project_query.query.page.should eq(1)
      end
    end

    describe "owner_id filter" do
      before :each do
        get "/?owner_id=#{@owner.id.to_s}"
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return all results by default" do
        @project_query = ProjectQuery.new
        @project_query.extend(ProjectQueryRepresenter)
        @project_query.from_json(last_response.body)
        @project_query.query.should_not eq(nil)
        @project_query.projects.length.should eq(1)
        @project_query.query.offset.should eq(0)
        @project_query.query.total.should eq(1)
        @project_query.query.page.should eq(1)
      end
    end
  end

  describe "POST /:id/open/:account_id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@account_1)
      post "/#{@project.id}/open/#{@account_1.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid JSON payload" do
      project = Project.new.extend(ProjectRepresenter)
      project.from_json(last_response.body)
      project.id.should eq(@project.id)
      project.name.should eq(@project.name)
      project.name.should eq(@project.name)
    end

    it "should return 404 if not found" do
      post "/not_found/open/#{@account_1.id}"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "POST /" do
    before :each do
      @create_project = FactoryGirl.build(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@account_1).extend(UpdateProjectRepresenter)
      post "/", @create_project.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid project payload" do
      new_project = Project.new.extend(ProjectRepresenter)
      new_project.from_json(last_response.body)
      new_project.id.should_not eq(nil)
      new_project.name.should eq(@create_project.name)
    end

    it "should return the proper content type if data is missing" do
      @create_project = FactoryGirl.build(:project, :name=>nil, :owner=>@create_project.owner).extend(UpdateProjectRepresenter)
      post "/", @create_project.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      @create_project = FactoryGirl.build(:project, :name=>nil, :owner=>@create_project.owner).extend(UpdateProjectRepresenter)
      post "/", @create_project.to_json
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      @create_project = FactoryGirl.build(:project, :name=>nil, :owner=>@create_project.owner).extend(UpdateProjectRepresenter)
      post "/", @create_project.to_json
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end

#    it "should create a project with multiple environments" do
#      json = "{\"project\":{\"name\":\"Multi-env\",\"description\":\"desc\",\"project_type\":\"type\",\"cloud_credential_id\":\"4f8c6b07be8a7c443300023a\",\"owner_id\":\"4f8c6b07be8a7c443300023b\",\"with_environments\":[\"a\",\"b\",\"c\"]}}"
#      post "/", json
#      last_response.status.should eq(CREATED)
#      puts "**** response=#{last_response.body}"
#      new_project = Project.new.extend(ProjectRepresenter)
#      new_project.from_json(last_response.body)
#      new_project.id.should_not eq(nil)
#      new_project.name.should eq(@create_project.name)
#      new_project.environments.length.should eq(3)
#    end
  end

  describe "PUT /:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@account_1).extend(UpdateProjectRepresenter)
      @project.name = "#{@project.name}_new"
      put "/#{@project.id}", @project.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      updated_project = Project.new.extend(ProjectRepresenter)
      updated_project.from_json(last_response.body)
      updated_project.name.should eq(@project.name)
      updated_project.name.should eq(@project.name)
    end
  end

  describe "DELETE /:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@account_1).extend(UpdateProjectRepresenter)
      @project.name = "#{@project.name}_new"
      Project.find(@project.id).should_not eq(nil)
      delete "/#{@project.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should delete the project" do
      expect{Project.find(@project.id)}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  describe "POST /:id/members" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @account_2 = FactoryGirl.create(:account, :login=>"standard_subscriber_2", :email=>"standard_2@example.com")
      @member = FactoryGirl.build(:member, :account=>@account_2, :role=>Member::MEMBER).extend(UpdateMemberRepresenter)
      post "/#{@project.id.to_s}/members", @member.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the member properly" do
      @project.reload
      @project.members.length.should eq(1)
      @project.members.last.account.id.to_s.should eq(@account_2.id.to_s)
    end
  end

  describe "DELETE /:id/members/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @account_2 = FactoryGirl.create(:account, :login=>"standard_subscriber_2", :email=>"standard_2@example.com")
      @member = FactoryGirl.build(:member, :account=>@account_2, :project=>@project)
      @member.save!
      delete "/#{@project.id.to_s}/members/#{@member.id.to_s}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the member properly" do
      @project.reload
      @project.members.length.should eq(0)
    end
  end

  describe "POST /:id/archive" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      post "/#{@project.id.to_s}/archive"
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should mark the project as inactive" do
      @project.reload
      @project.archived?.should eq(true)
    end
  end

  describe "POST /:id/archive" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @project.archive!
      post "/#{@project.id.to_s}/reactivate"
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should mark the project as inactive" do
      @project.reload
      @project.active?.should eq(true)
    end
  end

  describe "POST /:id/freeze_version" do
    before :each do
      @owner = FactoryGirl.create(:account, :login=>"owner_1", :email=>"owner_1@example.com")
      @version = FactoryGirl.build(:version, :description=>"Test").extend(VersionRepresenter)
      @project_version = FactoryGirl.create(:project_version)
      post "/#{@project_version.project.id.to_s}/#{@project_version.version}/freeze_version", @version.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid JSON payload" do
      new_project = Project.new.extend(ProjectRepresenter)
      new_project.from_json(last_response.body)
      new_project.versions.length.should eq(2)
      new_project.versions.last.number.should eq(@version.number)
      new_project.versions.last.description.should eq(@version.description)
    end

    it "should return a failure response code if the number is lower to the last version number" do
      @next_version = FactoryGirl.build(:version, :number=>"0.999.1").extend(VersionRepresenter)
      post "/#{@project_version.project.id.to_s}/#{@project_version.version}/freeze_version", @next_version.to_json
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a failure response code if the number is equal to the last version number" do
      @next_version = FactoryGirl.build(:version).extend(VersionRepresenter)
      post "/#{@project_version.project.id.to_s}/#{@project_version.version}/freeze_version", @next_version.to_json
      last_response.status.should eq(BAD_REQUEST)
    end
  end

  describe "POST /:project_id/versions/:version/promote" do
    before :each do
      @version = "0.1.0"
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @project_version = FactoryGirl.create(:project_version, :project=>@project, :version=>@version)
      @environment = FactoryGirl.build(:environment).extend(UpdateEnvironmentRepresenter)
      puts "/#{@project.id.to_s}/versions/#{@version}/promote", @environment.to_json

      post "/#{@project.id.to_s}/versions/#{@version}/promote", @environment.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the environment properly" do
      @project_version.reload
      @project_version.environments.length.should eq(2)
      @project_version.environments.last.name.should eq(@environment.name)
    end
  end

  describe "GET /:project_id/versions/:version.json" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = FactoryGirl.create(:project_version, :project=>@project, :version=>@version)
      get "/#{@project.id.to_s}/versions/#{@version}.json"
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload" do
      project_version = ProjectVersion.new.extend(ProjectVersionRepresenter)
      project_version.from_json(last_response.body)
      project_version.id.should eq(@project_version.id)
    end
  end

  pending "POST /:project_id/:version/elements" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = FactoryGirl.create(:project_version, :project=>@project, :version=>@version)
      @element = FactoryGirl.build(:element)
      @element.properties = { 'prop1'=>'value1', 'prop2'=>'value2'}.to_json
      json = @element.extend(ElementRepresenter).to_json
      post "/#{@project.id.to_s}/#{@project_version.id.to_s}/elements", json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the element properly" do
      @project_version.reload
      @project_version.elements.length.should eq(1)
      @project_version.elements.first.name.should eq(@element.name)
      JSON.parse(@project_version.elements.first.properties).length.should eq(2)
    end
  end

  pending "POST /:project_id/elements/import" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @project_version = @project.current_version
      @elements = FactoryGirl.build_list(:element, 15, :properties=>{ }.to_json)
      all = Struct.new(:elements).new
      all.elements = @elements
      json = all.extend(ElementsRepresenter).to_json
      post "/#{@project.id.to_s}/elements/import", json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the element properly" do
      @project_version.reload
      @project_version.elements.length.should eq(@elements.length)
    end

    it "should return a valid JSON payload" do
      import_results = ImportResults.new.extend(ImportResultsRepresenter)
      import_results.from_json(last_response.body)
      import_results.results.length.should eq(@elements.length)
    end
  end

  pending "PUT /:project_id/elements/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @element = FactoryGirl.build(:element, :project_version=>@project_version)
      @element.properties = { 'prop1'=>'value1', 'prop2'=>'value2'}.to_json
      @element.save!
      @project_version.elements.length.should eq(1)
      @element.name = "Updated element"
      json = @element.extend(ElementRepresenter).to_json
      put "/#{@project.id.to_s}/elements/#{@element.id}", json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the element properly" do
      @project_version.reload
      @project_version.elements.length.should eq(1)
      @project_version.elements.first.name.should eq("Updated element")
      JSON.parse(@project_version.elements.first.properties).length.should eq(2)
    end
  end

  pending "DELETE /:project_id/elements/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @element = FactoryGirl.build(:element, :project_version=>@project_version)
      @element.properties = { 'prop1'=>'value1', 'prop2'=>'value2'}.to_json
      @element.save!
      @project_version.elements.length.should eq(1)
      delete "/#{@project.id.to_s}/elements/#{@element.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the element properly" do
      @project_version.reload
      @project_version.elements.length.should eq(0)
    end
  end

  pending "POST /:project_id/nodes" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @element = FactoryGirl.build(:element)
      @node = FactoryGirl.build(:node)
      @node.properties = { 'prop1'=>'value1', 'prop2'=>'value2'}.to_json
      json = @node.extend(NodeRepresenter).to_json
      post "/#{@project.id.to_s}/nodes", json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the node properly" do
      @project_version.reload
      @project_version.nodes.length.should eq(1)
      @project_version.nodes.first.name.should eq(@node.name)
      JSON.parse(@project_version.nodes.first.properties).length.should eq(2)
    end
  end

  pending "POST /:project_id/nodes/import" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @project_version = @project.current_version
      @nodes = FactoryGirl.build_list(:node, 15, :properties=>{ }.to_json)
      all = Struct.new(:nodes).new
      all.nodes = @nodes
      json = all.extend(NodesRepresenter).to_json
      post "/#{@project.id.to_s}/nodes/import", json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the element properly" do
      @project_version.reload
      @project_version.nodes.length.should eq(@nodes.length)
    end

    it "should return a valid JSON payload" do
      import_results = ImportResults.new.extend(ImportResultsRepresenter)
      import_results.from_json(last_response.body)
      import_results.results.length.should eq(@nodes.length)
    end
  end

  pending "PUT /:project_id/nodes/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @node = FactoryGirl.build(:node, :project_version=>@project_version)
      @node.properties = { 'prop1'=>'value1', 'prop2'=>'value2'}.to_json
      @node.save!
      @project_version.nodes.length.should eq(1)
      @node.name = "Updated node"
      json = @node.extend(NodeRepresenter).to_json
      put "/#{@project.id.to_s}/nodes/#{@node.id}", json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the node properly" do
      @project_version.reload
      @project_version.nodes.length.should eq(1)
      @project_version.nodes.first.name.should eq("Updated node")
      JSON.parse(@project_version.nodes.first.properties).length.should eq(2)
    end
  end

  pending "DELETE /:project_id/nodes/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @node = FactoryGirl.build(:node, :project_version=>@project_version)
      @node.properties = { 'prop1'=>'value1', 'prop2'=>'value2'}.to_json
      @node.save!
      @project_version.nodes.length.should eq(1)
      delete "/#{@project.id.to_s}/nodes/#{@node.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the node properly" do
      @project_version.reload
      @project_version.nodes.length.should eq(0)
    end
  end

  pending "POST /:project_id/nodes/link" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @source_node = FactoryGirl.build(:node, :name=>"The Source", :project_version=>@project_version, :properties=>{ })
      @source_node.save!
      @target_node = FactoryGirl.build(:node, :name=>"The Target",  :project_version=>@project_version, :properties=>{ })
      @target_node.save!
      @project_version.nodes.length.should eq(2)
      json = { "node_link" => { "source_id"=>@source_node.id.to_s, "target_id"=>@target_node.id.to_s }}.to_json
      post "/#{@project.id.to_s}/nodes/link", json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the node link properly" do
      @project_version.reload
      node = @project_version.find_node(@source_node.id)
      node.should_not eq(nil)
      node.node_links.length.should eq(1)
      node_link = node.node_links[0]
      node_link.source_id.should eq(@source_node.id.to_s)
      node_link.target_id.should eq(@target_node.id.to_s)
    end

    it "should return the source node JSON payload" do
      node = Node.new.extend(NodeRepresenter)
      node.from_json(last_response.body)
      node.node_links.length.should eq(1)
      node_link = node.node_links[0]
      node_link.source_id.should eq(@source_node.id.to_s)
      node_link.target_id.should eq(@target_node.id.to_s)
    end
  end

  pending "POST /:project_id/variants" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @variant = FactoryGirl.build(:variant)
      @variant.rules = { 'prop1'=>'value1', 'prop2'=>'value2'}
      json = @variant.extend(VariantRepresenter).to_json
      post "/#{@project.id.to_s}/variants", json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @project_version.reload
      @project_version.variants.length.should eq(1)
      @project_version.variants.first.rule_type.should eq(@variant.rule_type)
      @project_version.variants.first.rules.length.should eq(2)
    end
  end

  pending "PUT /:project_id/variants/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @variant = FactoryGirl.build(:variant, :variantable=>@project_version)
      @variant.rules = { 'prop1'=>'value1', 'prop2'=>'value2'}
      @variant.save!
      @project_version.variants.length.should eq(1)
      @variant.rule_type = "Updated type"
      json = @variant.extend(VariantRepresenter).to_json
      put "/#{@project.id.to_s}/variants/#{@variant.id}", json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @project_version.reload
      @project_version.variants.length.should eq(1)
      @project_version.variants.first.rule_type.should eq("Updated type")
      @project_version.variants.first.rules.length.should eq(2)
    end
  end

  pending "DELETE /:project_id/variants/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @variant = FactoryGirl.build(:variant, :variantable=>@project_version)
      @variant.rules = { 'prop1'=>'value1', 'prop2'=>'value2'}
      @variant.save!
      @project_version.variants.length.should eq(1)
      delete "/#{@project.id.to_s}/variants/#{@variant.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @project_version.reload
      @project_version.variants.length.should eq(0)
    end
  end

  pending "POST /:project_id/embedded_projects" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @project_version = @project.current_version
      @project_2 = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner, :project_type=>Project::EMBEDDED)
      @embedded_project = FactoryGirl.build(:embedded_project, :embedded_project=>@project_2)
      json = @embedded_project.extend(UpdateEmbeddedProjectRepresenter).to_json
      post "/#{@project.id.to_s}/embedded_projects", json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @project_version.reload
      @project_version.embedded_projects.length.should eq(1)
      @project_version.embedded_projects.first.embedded_project_id.to_s.should eq(@project_2.id.to_s)
    end
  end

  pending "DELETE /:project_id/embedded_projects/:embedded_project_id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @project_version = @project.current_version
      @project_2 = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner, :project_type=>Project::EMBEDDED)
      @embedded_project = FactoryGirl.create(:embedded_project, :embedded_project=>@project_2, :project_version=>@project_version)
      delete "/#{@project.id.to_s}/embedded_projects/#{@embedded_project.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @project_version.reload
      @project_version.embedded_projects.length.should eq(0)
    end
  end

  pending "POST /:project_id/embedded_projects/:embedded_project_id/variants" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @project_version = @project.current_version
      @project_2 = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner, :project_type=>Project::EMBEDDED)
      @embedded_project = FactoryGirl.create(:embedded_project, :embedded_project=>@project_2, :project_version=>@project_version)
      @variant = FactoryGirl.build(:variant)
      @variant.rules = { 'prop1'=>'value1', 'prop2'=>'value2'}
      json = @variant.extend(VariantRepresenter).to_json
      post "/#{@project.id.to_s}/embedded_projects/#{@embedded_project.id}/variants", json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @embedded_project.reload
      @embedded_project.variants.length.should eq(1)
      @embedded_project.variants.first.rule_type.should eq(@variant.rule_type)
      @embedded_project.variants.first.rules.length.should eq(2)
    end
  end

  pending "PUT /:project_id/embedded_projects/:embedded_project_id/variants/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @project_2 = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner, :project_type=>Project::EMBEDDED)
      @embedded_project = FactoryGirl.create(:embedded_project, :embedded_project=>@project_2, :project_version=>@project_version)
      @variant = FactoryGirl.build(:variant, :variantable=>@embedded_project)
      @variant.rules = { 'prop1'=>'value1', 'prop2'=>'value2'}
      @variant.save!
      @embedded_project.variants.length.should eq(1)
      @variant.rule_type = "Updated type"
      json = @variant.extend(VariantRepresenter).to_json
      put "/#{@project.id.to_s}/embedded_projects/#{@embedded_project.id}/variants/#{@variant.id}", json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @embedded_project.reload
      @embedded_project.variants.length.should eq(1)
      @embedded_project.variants.first.rule_type.should eq("Updated type")
      @embedded_project.variants.first.rules.length.should eq(2)
    end
  end

  pending "DELETE /:project_id/embedded_projects/:embedded_project_id/variants/:id" do
    before :each do
      @project = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner)
      @version = '1.0.1'
      @project_version = @project.current_version
      @project_2 = FactoryGirl.create(:project, :cloud_credential_id=>@cloud_credential.id.to_s, :owner=>@owner, :project_type=>Project::EMBEDDED)
      @embedded_project = FactoryGirl.create(:embedded_project, :embedded_project=>@project_2, :project_version=>@project_version)
      @variant = FactoryGirl.build(:variant, :variantable=>@embedded_project)
      @variant.rules = { 'prop1'=>'value1', 'prop2'=>'value2'}
      @variant.save!
      @embedded_project.variants.length.should eq(1)
      delete "/#{@project.id.to_s}/embedded_projects/#{@embedded_project.id}/variants/#{@variant.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the variant properly" do
      @embedded_project.reload
      @embedded_project.variants.length.should eq(0)
    end
  end

end
