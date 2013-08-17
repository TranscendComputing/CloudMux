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

# Import supported clouds
aws = Cloud.find(:first, :conditions=>{ :cloud_provider=>'AWS'})
openstack = Cloud.find(:first, :conditions=>{ :cloud_provider=>'OpenStack'})
eucalyptus = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Eucalyptus'})
hp = Cloud.find(:first, :conditions=>{ :cloud_provider=>'HP'})
rackspace = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Rackspace'})
joyent = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Joyent'})
cloudstack = Cloud.find(:first, :conditions=>{ :cloud_provider=>'CloudStack'})
transcend = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Transcend'})
google = Cloud.find(:first, :conditions=>{ :cloud_provider=>'Google'})

if aws.nil?
	"Installing Amazon Cloud"
	aws = Cloud.create!(:name => "Amazon Web Services", :cloud_provider => "AWS", :permalink => "amazon")
end

aws_account = CloudAccount.find(:first, :conditions => { :cloud_id => aws.id })
if aws_account.nil?
  aws_account = CloudAccount.create(:name => "Amazon")
  aws_account.org_id = admin.org_id
  aws_account.cloud_id = aws.id
  aws_account.save
end

# Import AWS default cloud mappings
if aws_account.cloud_mappings.count == 0
  puts "Bulk importing AWS cloud Mappings"
  importer = AwsCfMappingImporter.new
  importer.import(aws_account)
  importer = AwsDefaultImageMappingImporter.new
  importer.import(aws_account)
end

puts "Updating AWS prices"
aws_account.prices = []
importer = PricesImporter.new
importer.import(aws_account)

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

openstack_account = CloudAccount.find(:first, :conditions => { :cloud_id => openstack.id })
if openstack_account.nil?
  openstack_account = CloudAccount.create(:name => "Openstack")
  openstack_account.org_id = admin.org_id
  openstack_account.cloud_id = openstack.id
  openstack_account.save
end

puts "Updating OpenStack prices"
openstack_account.prices = []
importer = PricesImporter.new
importer.import(openstack_account)

unless openstack_account.nil?
	importer = TopstackServiceImporter.new
	importer.import(openstack_account)
end


## Setup eucalyptus cloud
if eucalyptus.nil?
  puts "Installing Eucalyptus Cloud"
	eucalyptus = Cloud.create!(:name => "Eucalyptus", :cloud_provider => "Eucalyptus", :permalink => "eucalyptus")
end

eucalyptus_account = CloudAccount.find(:first, :conditions => { :cloud_id => eucalyptus.id })
if eucalyptus_account.nil?
  eucalyptus_account = CloudAccount.create(:name => "Eucalyptus")
  eucalyptus_account.org_id = admin.org_id
  eucalyptus_account.cloud_id = eucalyptus.id
  eucalyptus_account.save
end

puts "Updating Eucalyptus pricing"
eucalyptus_account.prices = []
importer = PricesImporter.new
importer.import(eucalyptus_account)

unless eucalyptus_account.nil?
	importer = TopstackServiceImporter.new
	importer.import(eucalyptus_account)
end


## Setup HP cloud
if hp.nil?
  puts "Installing HP Cloud"
	hp = Cloud.create!(:name => "HP", :cloud_provider => "HP", :permalink => "hp")
end

hp_account = CloudAccount.find(:first, :conditions => { :cloud_id => hp.id })
if hp_account.nil?
  hp_account = CloudAccount.create(:name => "HP")
  hp_account.org_id = admin.org_id
  hp_account.cloud_id = hp.id
  hp_account.save
end

unless hp_account.nil?
	importer = TopstackServiceImporter.new
	importer.import(hp_account)
end

puts "Updating HP prices"
hp_account.prices = []
importer = PricesImporter.new
importer.import(hp_account)

## Setup rackspace cloud
if rackspace.nil?
  puts "Installing Rackspace Cloud"
	rackspace = Cloud.create!(:name => "Rackspace", :cloud_provider => "Rackspace", :permalink => "rackspace")
end

rackspace_account = CloudAccount.find(:first, :conditions => { :cloud_id => rackspace.id })
if rackspace_account.nil?
  rackspace_account = CloudAccount.create(:name => "Rackspace")
  rackspace_account.org_id = admin.org_id
  rackspace_account.cloud_id = rackspace.id
  rackspace_account.save
end

puts "Updating Rackspace prices"
rackspace_account.prices = []
importer = PricesImporter.new
importer.import(rackspace_account)


## Setup joyent cloud
if joyent.nil?
  puts "Installing Joyent Cloud"
	joyent = Cloud.create!(:name => "Joyent", :cloud_provider => "Joyent", :permalink => "joyent")
end

joyent_account = CloudAccount.find(:first, :conditions => { :cloud_id => joyent.id })
if joyent_account.nil?
  joyent_account = CloudAccount.create(:name => "Joyent")
  joyent_account.org_id = admin.org_id
  joyent_account.cloud_id = joyent.id
  joyent_account.save
end

"Updating Joyent prices"
joyent_account.prices = []
importer = PricesImporter.new
importer.import(joyent_account)

## Setup cloudstack cloud
if cloudstack.nil?
  puts "Installing Cloudstack Cloud"
	cloudstack = Cloud.create!(:name => "CloudStack", :cloud_provider => "CloudStack", :permalink => "cloudstack")
end

cloudstack_account = CloudAccount.find(:first, :conditions => { :cloud_id => cloudstack.id })
if cloudstack_account.nil?
  cloudstack_account = CloudAccount.create(:name => "CloudStack")
  cloudstack_account.org_id = admin.org_id
  cloudstack_account.cloud_id = cloudstack.id
  cloudstack_account.save
end

puts "Updating CloudStack prices"
cloudstack_account.prices = []
importer = PricesImporter.new
importer.import(cloudstack_account)

## Setup google cloud
if google.nil?
  puts "Installing Google Cloud"
	google = Cloud.create!(:name => "Google", :cloud_provider => "Google", :permalink => "google")
end

google_account = CloudAccount.find(:first, :conditions => { :cloud_id => google.id })
if google_account.nil?
  google_account = CloudAccount.create(:name => "Google")
  google_account.org_id = admin.org_id
  google_account.cloud_id = google.id
  google_account.save
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


# simple check for a known AWS template, to ensure we don't fill the database with duplicates if we've already run this process
if Template.find(:first, :conditions=>{ :import_source=>"https://s3.amazonaws.com/cloudformation-templates-us-east-1/Joomla!_Single_Instance.template"}).nil?
  puts "Bulk importing AWS templates"
  importer = AwsTemplateImporter.new
  importer.import(admin)
end
