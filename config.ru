# -*- coding: utf-8 -*-
# gems
require 'sinatra'
require 'fog'

# require the dependencies
require File.join(File.dirname(__FILE__), 'app', 'init')
require 'app/api_base'
require 'app/template_api_app'
require 'app/account_api_app'
require 'app/stack_api_app'
require 'app/identity_api_app'
require 'app/org_api_app'
require 'app/category_api_app'
require 'app/cloud_account_api_app'
require 'app/cloud_api_app'
require 'app/project_api_app'
require 'app/provisioning_api_app'
require 'app/report_api_app'
require 'app/news_event_api_app'
require 'app/root_app'
require 'app/resource_api_base'
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
require 'app/aws/aws_iam_app'
require 'app/aws/aws_queue_app'
require 'app/aws/aws_simpledb_app'
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
# Templates API
#
map "/stackplace/v1/templates" do
  run TemplateApiApp
end

#
# Stacks API
#
map "/stackplace/v1/stacks" do
  run StackApiApp
end

#
# Accounts API (public)
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/accounts.{format}", :format => "json"
##~ a.description = "Manage system accounts"
map "/stackplace/v1/accounts" do
  run AccountApiApp
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
# Categories API (internal)
#
map "/stackplace/v1/categories" do
  run CategoryApiApp
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
# News Events API (internal)
#
map "/stackstudio/v1/news_events" do
  run NewsEventApiApp
end

#
# API Documentation and static files (stylesheets, etc)
#
map "/" do
  run RootApp
end

#
# AWS Compute API
#
##~ a = sapi.apis.add
## 
##~ a.set :path => "/compute_aws.{format}", :format => "json"
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
map "/stackstudio/v1/cloud_management/aws/autoscale" do
  run AwsAutoscaleApp
end

#
# AWS Block Storage API
#
map "/stackstudio/v1/cloud_management/aws/block_storage" do
  run AwsBlockStorageApp
end

#
# AWS Object Storage API
#
map "/stackstudio/v1/cloud_management/aws/object_storage" do
  run AwsObjectStorageApp
end

#
# AWS Monitor API
#
map "/stackstudio/v1/cloud_management/aws/monitor" do
  run AwsMonitorApp
end

#
# AWS Notification API
#
map "/stackstudio/v1/cloud_management/aws/notification" do
  run AwsNotificationApp
end

#
# AWS DNS API
#
map "/stackstudio/v1/cloud_management/aws/dns" do
  run AwsDnsApp
end

#
# AWS RDS API
#
map "/stackstudio/v1/cloud_management/aws/rds" do
  run AwsRdsApp
end

#
# AWS Load Balancer API
#
map "/stackstudio/v1/cloud_management/aws/load_balancer" do
  run AwsLoadBalancerApp
end

#
# AWS Cache API
#
map "/stackstudio/v1/cloud_management/aws/cache" do
  run AwsCacheApp
end

#
# AWS IAM API
#
map "/stackstudio/v1/cloud_management/aws/iam" do
  run AwsIamApp
end

#
# AWS Queue API
#
map "/stackstudio/v1/cloud_management/aws/queue" do
  run AwsQueueApp
end

#
# AWS SimpleDB API
#
map "/stackstudio/v1/cloud_management/aws/simple_db" do
  run AwsSimpleDBApp
end

#
# Openstack Compute API
#
map "/stackstudio/v1/cloud_management/openstack/compute" do
  run OpenstackComputeApp
end

##~ a = sapi.apis.add
## 
##~ a.set :path => "/compute_openstack.{format}", :format => "json"
##~ a.description = "OpenStack Cloud Compute API"
map "/api/v1/cloud_management/openstack/compute" do
  run OpenstackComputeApp
end

#
# Openstack Block Storage API
#
map "/stackstudio/v1/cloud_management/openstack/block_storage" do
  run OpenstackBlockStorageApp
end

#
# Openstack Block Storage API
#
map "/stackstudio/v1/cloud_management/openstack/object_storage" do
  run OpenstackObjectStorageApp
end

#
# Openstack Identity API
#
map "/stackstudio/v1/cloud_management/openstack/identity" do
  run OpenstackIdentityApp
end

#
# Openstack Network API
#
map "/stackstudio/v1/cloud_management/openstack/network" do
  run OpenstackNetworkApp
end

#
# TopStack LoadBalancer API
#
map "/stackstudio/v1/cloud_management/topstack/load_balancer" do
  run TopStackLoadBalancerApp
end

#
# TopStack AutoScale API
#
map "/stackstudio/v1/cloud_management/topstack/autoscale" do
  run TopStackAutoscaleApp
end

#
# TopStack Monitor API
#
map "/stackstudio/v1/cloud_management/topstack/monitor" do
  run TopStackMonitorApp
end

#
# TopStack RDS API
#
map "/stackstudio/v1/cloud_management/topstack/rds" do
  run TopStackRdsApp
end

#
# TopStack Queue API
#
map "/stackstudio/v1/cloud_management/topstack/queue" do
  run TopStackQueueApp
end