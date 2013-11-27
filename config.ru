#\ -s puma
# -*- coding: utf-8 -*-
# gems
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'fog'

if ENV['RACK_ENV'] == 'production'
  # production config / requires
else
  # development or testing only
  use Rack::ShowExceptions
end

# require the dependencies
require File.join(File.dirname(__FILE__), 'app', 'init')
require 'app/api_base'
require 'app/stack_api_app'
require 'app/offering_api_app'
require 'app/portfolio_api_app'
require 'app/identity_api_app'
require 'app/org_api_app'
require 'app/policy_api_app'
require 'app/cloud_account_api_app'
require 'app/cloud_api_app'
require 'app/project_api_app'
require 'app/provisioning_api_app'
require 'app/report_api_app'
require 'app/root_app'
require 'app/resource_api_base'
require 'app/assembly_api_app'
require 'app/aws/aws_compute_app'
require 'app/aws/aws_autoscale_app'
require 'app/aws/aws_block_storage_app'
require 'app/aws/aws_object_storage_app'
require 'app/aws/aws_monitor_app'
require 'app/aws/aws_notification_app'
require 'app/aws/aws_dns_app'
require 'app/aws/aws_rds_app'
require 'app/aws/aws_load_balancer_app'
require 'app/aws/aws_cache_app'
require 'app/aws/aws_beanstalk_app'
require 'app/aws/aws_iam_app'
require 'app/aws/aws_queue_app'
require 'app/aws/aws_simpledb_app'
require 'app/aws/aws_cf_app'
require 'app/google/google_compute_app'
require 'app/google/google_object_storage_app'
require 'app/openstack/openstack_compute_app'
require 'app/openstack/openstack_block_storage_app'
require 'app/openstack/openstack_object_storage_app'
require 'app/openstack/openstack_identity_app'
require 'app/openstack/openstack_network_app'
require 'app/topstack/topstack_autoscale_app'
require 'app/topstack/topstack_load_balancer_app'
require 'app/topstack/topstack_monitor_app'
require 'app/topstack/topstack_rds_app'
require 'app/topstack/topstack_queue_app'
require 'app/topstack/topstack_cache_app'
require 'app/topstack/topstack_dns_app'
require 'app/orchestration/config_managers_api_app'
require 'app/orchestration/chef_api_app'
require 'app/orchestration/puppet_api_app'
require 'app/orchestration/salt_api_app'
require 'app/orchestration/ansible_api_app'
require 'app/packed_images/packed_images_app'

# By default, Ruby buffers its output to stdout. To take advantage of
# Heroku's realtime logging, you will need to disable this buffering
# to have log messages sent straight to Heroku's logging
# infrastructure
# http://devcenter.heroku.com/articles/ruby#logging
$stdout.sync = true

# Sinatra now has logging - disable for tests
configure(:test) { disable :logging }
=begin
register Sinatra::CrossOrigin
configure do 
  set :cross_origin, true
  set :allow_origin, "*"
  set :allow_methods, [:get, :post, :options, :put, :delete]
  set :allow_credentials, true
  set :allow_headers, "X-HTTP-Method-Override"
  set :max_age, "1728000"
end
=end

require 'rack-methodoverride-with-params'
use Rack::MethodOverrideWithParams
set :method_override, :true

# Following are Swagger directives, for REST API documentation.
##~ sapi = source2swagger.namespace("CloudMux")
##~ sapi.swaggerVersion = "1.1"
##~ sapi.apiVersion = "1.0"

#
# API Documentation and static files (stylesheets, etc)
#
map "/" do
  run RootApp
end

#
# Identity Accounts API (internal)
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/identity.{format}", :format => "json"
##~ a.description = "Manage system accounts"
map "/identity/v1/accounts" do
  run IdentityApiApp
end

#
# Identity Orgs API (internal)
#
map "/identity/v1/orgs" do
  run OrgApiApp
end

#
# Identity Policies API (internal)
#
map "/identity/v1/policies" do
  run PolicyApiApp
end

#
# Clouds API (internal)
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/clouds.{format}", :format => "json"
##~ a.description = "Manage defined clouds"
map "/stackstudio/v1/clouds" do
  run CloudApiApp
end

map "/api/v1/clouds" do
  run CloudApiApp
end

#
# Cloud Accounts API (internal)
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/cloud_accounts.{format}", :format => "json"
##~ a.description = "Manage defined clouds"
map "/stackstudio/v1/cloud_accounts" do
  run CloudAccountApiApp
end

map "/api/v1/cloud_accounts" do
  run CloudAccountApiApp
end

#
# Stacks API (internal)
#
map "/stackstudio/v1/stacks" do
  run StackApiApp
end

#
# Offerings API (internal)
#
map "/stackstudio/v1/offerings" do
  run OfferingApiApp
end

#
# Portfolios API (internal)
#
map "/stackstudio/v1/portfolios" do
  run PortfolioApiApp
end

#
# Projects API (internal)
#
map "/stackstudio/v1/projects" do
  run ProjectApiApp
end

#
# Provisioning API (internal)
#
map "/stackstudio/v1/provisioning" do
  run ProvisioningApiApp
end

#
# Reports API (internal)
#
map "/stackstudio/v1/report" do
  run ReportApiApp
end

#
# Chef Management API
#
map "/stackstudio/v1/orchestration/chef" do
  run ChefApiApp
end

#
# Puppet Management API
#
map "/stackstudio/v1/orchestration/puppet" do
  run PuppetApiApp
end

#
# Salt Management API
#
map "/stackstudio/v1/orchestration/salt" do
  run SaltApiApp
end

#
# Ansible Management API
#
map "/stackstudio/v1/orchestration/ansible" do
  run AnsibleApiApp
end

#
# Assemblies API (internal)
#
map "/stackstudio/v1/assemblies" do
  run AssemblyApiApp
end

#
# AWS Compute API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_compute.{format}", :format => "json"
##~ a.description = "AWS Cloud Compute API"
map "/stackstudio/v1/cloud_management/aws/compute" do
  run AwsComputeApp
end

map "/api/v1/cloud_management/aws/compute" do
  run AwsComputeApp
end

#
# AWS Autoscale API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_autoscale.{format}", :format => "json"
##~ a.description = "AWS AutoScale API"
map "/stackstudio/v1/cloud_management/aws/autoscale" do
  run AwsAutoscaleApp
end

#
# AWS Block Storage API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_block_storage.{format}", :format => "json"
##~ a.description = "AWS Block Storage API"
map "/stackstudio/v1/cloud_management/aws/block_storage" do
  run AwsBlockStorageApp
end

#
# AWS Object Storage API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_object_storage.{format}", :format => "json"
##~ a.description = "AWS Object Storage API"
map "/stackstudio/v1/cloud_management/aws/object_storage" do
  run AwsObjectStorageApp
end

#
# AWS Monitor API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_monitor.{format}", :format => "json"
##~ a.description = "AWS monitor API"
map "/stackstudio/v1/cloud_management/aws/monitor" do
  run AwsMonitorApp
end

#
# AWS Notification API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_notification.{format}", :format => "json"
##~ a.description = "AWS Notification API"
map "/stackstudio/v1/cloud_management/aws/notification" do
  run AwsNotificationApp
end

#
# AWS DNS API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_dns.{format}", :format => "json"
##~ a.description = "AWS DNS API"
map "/stackstudio/v1/cloud_management/aws/dns" do
  run AwsDnsApp
end

#
# AWS RDS API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_rds.{format}", :format => "json"
##~ a.description = "AWS RDS API"
map "/stackstudio/v1/cloud_management/aws/rds" do
  run AwsRdsApp
end

#
# AWS Load Balancer API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_load_balancer.{format}", :format => "json"
##~ a.description = "AWS Load Balancer API"
map "/stackstudio/v1/cloud_management/aws/load_balancer" do
  run AwsLoadBalancerApp
end

#
# AWS Cache API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_cache.{format}", :format => "json"
##~ a.description = "AWS Cache API"
map "/stackstudio/v1/cloud_management/aws/cache" do
  run AwsCacheApp
end

#
# AWS Beanstalk API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_beanstalk.{format}", :format => "json"
##~ a.description = "AWS Beanstalk API"
map "/stackstudio/v1/cloud_management/aws/beanstalk" do
  run AwsBeanstalkApp
end

#
# AWS IAM API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_iam.{format}", :format => "json"
##~ a.description = "AWS IAM API"
map "/stackstudio/v1/cloud_management/aws/iam" do
  run AwsIamApp
end

#
# AWS Queue API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_queue.{format}", :format => "json"
##~ a.description = "AWS Queue API"
map "/stackstudio/v1/cloud_management/aws/queue" do
  run AwsQueueApp
end

#
# AWS SimpleDB API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/aws_simple_db.{format}", :format => "json"
##~ a.description = "AWS Simple DB API"
map "/stackstudio/v1/cloud_management/aws/simple_db" do
  run AwsSimpleDBApp
end

map "/stackstudio/v1/cloud_management/aws/cloud_formation" do
  run AwsCloudFormationApp
end

#
# Openstack Compute API
#
map "/stackstudio/v1/cloud_management/openstack/compute" do
  run OpenstackComputeApp
end

##~ a = sapi.apis.add
## 
##~ a.set :path => "/openstack_compute.{format}", :format => "json"
##~ a.description = "OpenStack Cloud Compute API"
map "/api/v1/cloud_management/openstack/compute" do
  run OpenstackComputeApp
end

#
# Openstack Block Storage API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/openstack_block_storage.{format}", :format => "json"
##~ a.description = "OpenStack Block Storage API"
map "/stackstudio/v1/cloud_management/openstack/block_storage" do
  run OpenstackBlockStorageApp
end

#
# Openstack Object Storage API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/openstack_object_storage.{format}", :format => "json"
##~ a.description = "OpenStack Object Storage API"
map "/stackstudio/v1/cloud_management/openstack/object_storage" do
  run OpenstackObjectStorageApp
end

#
# Openstack Identity API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/openstack_identity.{format}", :format => "json"
##~ a.description = "OpenStack Identity API"
map "/stackstudio/v1/cloud_management/openstack/identity" do
  run OpenstackIdentityApp
end

#
# Openstack Network API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/openstack_network.{format}", :format => "json"
##~ a.description = "OpenStack Network API"
map "/stackstudio/v1/cloud_management/openstack/network" do
  run OpenstackNetworkApp
end

#
# TopStack LoadBalancer API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/topstack_load_balancer.{format}", :format => "json"
##~ a.description = "TopStack Load Balancer API"
map "/stackstudio/v1/cloud_management/topstack/load_balancer" do
  run TopStackLoadBalancerApp
end

#
# TopStack AutoScale API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/topstack_autoscale.{format}", :format => "json"
##~ a.description = "TopStack AutoScale API"
map "/stackstudio/v1/cloud_management/topstack/autoscale" do
  run TopStackAutoscaleApp
end

#
# TopStack Monitor API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/topstack_monitor.{format}", :format => "json"
##~ a.description = "TopStack Monitor API"
map "/stackstudio/v1/cloud_management/topstack/monitor" do
  run TopStackMonitorApp
end

#
# TopStack RDS API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/topstack_rds.{format}", :format => "json"
##~ a.description = "TopStack RDS API"
map "/stackstudio/v1/cloud_management/topstack/rds" do
  run TopStackRdsApp
end

#
# TopStack Queue API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/topstack_queue.{format}", :format => "json"
##~ a.description = "TopStack Queue API"
map "/stackstudio/v1/cloud_management/topstack/queue" do
  run TopStackQueueApp
end

#
# TopStack Cache API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/topstack_cache.{format}", :format => "json"
##~ a.description = "TopStack Cache API"
map "/stackstudio/v1/cloud_management/topstack/cache" do
  run TopStackCacheApp
end

#
# TopStack DNS API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/topstack_dns.{format}", :format => "json"
##~ a.description = "TopStack DNS API"
map "/stackstudio/v1/cloud_management/topstack/dns" do
  run TopStackDnsApp
end

#
# Google Compute API
#
map "/stackstudio/v1/cloud_management/google/compute" do
  run GoogleComputeApp
end

#
# Google Cloud Storage API
#
map "/stackstudio/v1/cloud_management/google/object_storage" do
  run GoogleObjectStorageApp
end

#
#	Configuration Managers API
#
map "/stackstudio/v1/orchestration/managers" do
  run ConfigManagerApiApp
end

#
#	Packed Images API
#
map "/stackstudio/v1/packed_images" do
  run PackedImagesApiApp
end

# Scheduling for Ansible
#require 'rufus-scheduler'
#
#scheduler = Rufus::Scheduler.new
#
#Thread.new do
#  scheduler.every '10s' do
#    puts "HELLO THERE"
#  end
#  scheduler.join
#end

