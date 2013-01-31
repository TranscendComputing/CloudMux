require 'csv'
require 'lib/service/importer/aws_template_importer'
require 'lib/service/importer/aws_cf_mapping_importer'
require 'lib/service/importer/prices_importer'
require 'lib/service/importer/aws_default_image_mapping_importer'
require 'lib/service/importer/topstack_service_importer'

# disable heavy Mongo output even in dev mode
Mongoid.logger.level = Mongoid.logger.class::ERROR

# Import Countries
if Country.count == 0
  puts "Bulk importing: countries.csv"
  countries = []
  CSV.foreach("seed/countries.csv", :headers=>true) do |row|
    countries << row.to_hash
  end
  Country.collection.insert(countries)
end

# Import initial News Events
if NewsEvent.count == 0
  puts "Importing news events.  Be sure to update"
  NewsEvent.create!(:description => "Transcend Launches", :url => "https://www.transcendcomputing.com", :source => "TranscendComputing", :posted => Time.now)
end

# Import supported clouds
aws = Cloud.find(:first, :conditions=>{ :cloud_provider=>'AWS'})
openstack = Cloud.find(:first, :conditions=>{ :cloud_provider=>'OpenStack'})
eucalyptus = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Eucalyptus'})
hp = Cloud.find(:first, :conditions=>{ :cloud_provider=>'HP'})
rackspace = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Rackspace'})
joyent = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Joyent'})
cloudstack = Cloud.find(:first, :conditions=>{ :cloud_provider=>'CloudStack'})
transcend = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Transcend'})

if aws.nil?
	puts "Installing Amazon Cloud"
	aws = Cloud.create!(:name => "Amazon Web Services", :cloud_provider => "AWS", :permalink => "amazon")
end

# Import AWS default cloud mappings
if aws.cloud_mappings.count == 0
  puts "Bulk importing AWS cloud Mappings"
  importer = AwsCfMappingImporter.new
  importer.import(aws)
  importer = AwsDefaultImageMappingImporter.new
  importer.import(aws)
end

if aws.prices.count == 0
	importer = PricesImporter.new
	importer.import(aws)
end

## Create transcend "placeholder" cloud.  Used to detect if services have been setup yet.
if transcend.nil?
	puts "Installing Initial Cloud"
	transcend = Cloud.create!(:name => "Transcend", :cloud_provider => "Transcend", :permalink => "transcend")
end


## Setup openstack cloud
if openstack.nil?
	puts "Installing OpenStack Cloud"
	openstack = Cloud.create!(:name => "OpenStack", :cloud_provider => "OpenStack", :permalink => "openstack")
end

if openstack.prices.count == 0
	importer = PricesImporter.new
	importer.import(openstack)
end

unless openstack.nil? == 0
	importer = TopstackServiceImporter.new
	importer.import(openstack)
end


## Setup eucalyptus cloud
if eucalyptus.nil?
	puts "Installing Eucalyptus Cloud"
	eucalyptus = Cloud.create!(:name => "Eucalyptus", :cloud_provider => "Eucalyptus", :permalink => "eucalyptus")
end

if eucalyptus.prices.count == 0
	importer = PricesImporter.new
	importer.import(eucalyptus)
end

unless eucalyptus.nil?
	importer = TopstackServiceImporter.new
	importer.import(eucalyptus)
end


## Setup HP cloud
if hp.nil?
	puts "Installing HP Cloud"
	hp = Cloud.create!(:name => "HP", :cloud_provider => "HP", :permalink => "hp")
end

unless hp.nil?
	importer = TopstackServiceImporter.new
	importer.import(hp)
end

if hp.prices.count == 0
	importer = PricesImporter.new
	importer.import(hp)
end


## Setup rackspace cloud
if rackspace.nil?
	puts "Installing Rackspace Cloud"
	rackspace = Cloud.create!(:name => "Rackspace", :cloud_provider => "Rackspace", :permalink => "rackspace")
end

if rackspace.prices.count == 0
	importer = PricesImporter.new
	importer.import(rackspace)
end


## Setup joyent cloud
if joyent.nil?
	puts "Installing Joyent Cloud"
	joyent = Cloud.create!(:name => "Joyent", :cloud_provider => "Joyent", :permalink => "joyent")
end

if joyent.prices.count == 0
	importer = PricesImporter.new
	importer.import(joyent)
end


## Setup cloudstack cloud
if cloudstack.nil?
	puts "Installing Cloudstack Cloud"
	cloudstack = Cloud.create!(:name => "CloudStack", :cloud_provider => "CloudStack", :permalink => "cloudstack")
end

if cloudstack.prices.count == 0
	importer = PricesImporter.new
	importer.import(cloudstack)
end

# Install the default categories for stacks
if Category.count == 0
  puts "Bulk importing: categories.csv"
  categories = [
                {:name=>"Application", :permalink=>'application'},
                {:name=>"Platform", :permalink=>'platform'},
                {:name=>"Sample Code", :permalink=>'sample-code'}
               ]
  Category.collection.insert(categories)
end

# setup a system account for our imports as well as an admin account
admin = Account.find(:first, :conditions=>{ :login=>'admin'})

if admin.nil?
	puts "Installing admin account, login=admin"
	admin = Account.create!(:login=>'admin', :password=>'CHANGEME', :password_confirmation=>'CHANGEME', :email=>'support@transcendcomputing.com', :country=>Country.first)
	admin.permissions << Permission.new(:name => 'admin', :environment => 'transcend')
	org = Org.create!(:name => 'DefaultOrg')
	org.accounts << admin
	Group.create!(:name => "Development", :description => "default development group", :org => org)
	Group.create!(:name => "Test", :description => "default test group", :org => org)
	Group.create!(:name => "Stage", :description => "default stage group", :org => org)
	Group.create!(:name => "Production", :description => "default production group", :org => org)
end


# simple check for a known AWS template, to ensure we don't fill the database with duplicates if we've already run this process
if Template.find(:first, :conditions=>{ :import_source=>"https://s3.amazonaws.com/cloudformation-templates-us-east-1/Joomla!_Single_Instance.template"}).nil?
  puts "Bulk importing AWS templates"
  importer = AwsTemplateImporter.new
  importer.import(admin)
end
