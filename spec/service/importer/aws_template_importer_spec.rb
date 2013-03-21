require 'service_spec_helper'
require 'lib/service/importer/aws_template_importer'

describe AwsTemplateImporter do
  before :all do
    @account = FactoryGirl.create(:account)
  end

  before :each do
    @importer = AwsTemplateImporter.new
    @importer.stub(:fetch_page).and_return(file('spec/service_fixtures/aws_cf_templates.html'))

    @samples = FactoryGirl.create(:category, :name=>"Sample Code")
    @applications = FactoryGirl.create(:category, :name=>"Application")
    @platforms = FactoryGirl.create(:category, :name=>"Platform")
  end

  describe "#name_from_url" do
    it "should keep WordPress" do
      url = "https://s3.amazonaws.com/cloudformation-templates-us-east-1/WordPress_Single_Instance.template"
      @importer.name_from_url(url).should eq("WordPress Single Instance")
    end

    it "should not split words that look like class names to prevent incorrect capitalization or splitting things like WordPress" do
      url = "https://s3.amazonaws.com/cloudformation-templates-us-east-1/EC2ChooseAMI.template"
      @importer.name_from_url(url).should eq("EC2ChooseAMI")
    end
  end

  describe "#import" do
    it "should parse the HTML without error" do
      @importer.stub(:import_stack).and_return(true) # don't save to the db
      @importer.import(@account)
    end
  end
end
