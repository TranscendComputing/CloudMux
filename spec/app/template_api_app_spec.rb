require 'app_spec_helper'
include HttpStatusCodes

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'template_api_app')

describe "TemplateApiApp" do
  def app
    TemplateApiApp
  end

  describe "POST /" do
    before :each do
      response = import_template
      @template.from_json(response)
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return the proper content type if data is missing" do
      import_template(nil)
     last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      import_template(nil)
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      import_template(nil)
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end

    it "should return a valid template payload" do
      @template.name.should eq(@import_template.name)
    end
  end

  describe "GET /:id.json" do
    before :each do
      @template = Template.create!(:name=>"Test Template", :raw_json=>"{\"name\":\"value\"}")
      get "/#{@template.id}.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return 404 if not found" do
      get "/#{@template.id}notfound.json"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "GET /:id.html" do
    before :each do
      create_template(file("spec/cfdoc_fixtures/careers_formation.json"))
      get "/#{@template.id}.html"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(HTML_CONTENT)
    end

    it "should return 404 if not found" do
      get "/#{@template.id}notfound.html"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "GET /:id/raw" do
    before :each do
      create_template(file("spec/cfdoc_fixtures/careers_formation.json"))
      get "/#{@template.id}/raw"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end
  end

end


def create_template(json="{}")
  @template = Template.new
  @template.name = "Test Template"
  @template.raw_json = json
  @template.save!
end

def import_template(name="Test Template", json="{}")
  @import_template = ImportTemplate.new
  @import_template.name = name
  @import_template.import_source = "Test"
  @import_template.json = json
  @import_template.extend(ImportTemplateRepresenter)
  post "/", @import_template.to_json
  @template = Template.new.extend(TemplateRepresenter)
  last_response.body
end
