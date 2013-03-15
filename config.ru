# -*- coding: utf-8 -*-
# gems
require 'sinatra'
require 'fog'
require 'ruby-debug'

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
require 'app/aws/aws_block_storage_app'
require 'app/aws/aws_object_storage_app'
require 'app/aws/aws_monitor_app'
require 'app/aws/aws_notification_app'
require 'app/openstack/openstack_compute_app'



# By default, Ruby buffers its output to stdout. To take advantage of
# Heroku's realtime logging, you will need to disable this buffering
# to have log messages sent straight to Heroku's logging
# infrastructure
# http://devcenter.heroku.com/articles/ruby#logging
$stdout.sync = true

# Sinatra now has logging - disable for tests
configure(:test) { disable :logging }

require 'rack-methodoverride-with-params'
use Rack::MethodOverrideWithParams
#use Rack::MethodOverride
set :method_override, :true

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
map "/stackplace/v1/accounts" do
  run AccountApiApp
end

#
# Identity Accounts API (internal)
#
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
map "/stackstudio/v1/clouds" do
  run CloudApiApp
end

#
# Cloud Accounts API (internal)
#
map "/stackstudio/v1/cloud_accounts" do
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
map "/stackstudio/v1/cloud_management/aws/compute" do
  run AwsComputeApp
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
# Openstack Compute API
#
map "/stackstudio/v1/cloud_management/openstack/compute" do
  run OpenstackComputeApp
end
