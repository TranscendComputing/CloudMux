require 'csv'

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

## Setup aws cloud
aws = Cloud.where(cloud_provider:'AWS').first
if aws.nil?
	puts "Installing Amazon Cloud"
	aws = Cloud.create!(:name => "Amazon Web Services", :cloud_provider => "AWS", :permalink => "amazon")
end

## Setup openstack cloud
openstack = Cloud.where(cloud_provider:'OpenStack').first
if openstack.nil?
  puts "Installing OpenStack Cloud"
	openstack = Cloud.create!(:name => "OpenStack", :cloud_provider => "OpenStack", :permalink => "openstack")
end

## Setup google cloud
google = Cloud.where(cloud_provider:'Google').first
if google.nil?
  puts "Installing Google Cloud"
	google = Cloud.create!(:name => "Google", :cloud_provider => "Google", :permalink => "google")
end

vcloud = Cloud.where(cloud_provider: 'VCloud').first
if vcloud.nil?
  puts "Installing VMware"
  vcloud = Cloud.create!(:name => "VMware", :cloud_provider => "VCloud", :permalink => "vcloud")
end
