# test env
require 'rspec'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rack/test'
require 'sinatra'

# gems
require 'mongoid'
require 'fog'
require 'database_cleaner'

# Contsant for root application directories
TOP_DIR = File.join(File.dirname(__FILE__), '..')
APP_DIR = File.expand_path(File.join(TOP_DIR,'app'))
LIB_DIR = File.expand_path(File.join(TOP_DIR,'lib'))

# require the dependencies
require File.join(LIB_DIR, 'core')
require File.join(LIB_DIR, 'cfdoc')
require File.join(LIB_DIR, 'service')
require File.join(APP_DIR, 'api_base')
require File.join(APP_DIR, 'resource_api_base')

# load mongo config
Mongoid.load!('app/config/mongoid.yml')

# set the mongoid debugging output to something sane for tests
Mongoid.logger.level = Mongoid.logger.class::ERROR

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

# In general, mock fog operations during testing.
Fog.mock!

# Sinatra test setup
set :environment, :test

# Database cleanup
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# Constants
JSON_CONTENT = "application/json;charset=utf-8"
HTML_CONTENT = "text/html;charset=utf-8"

# Database cleanup
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# Tell Factory Girl to load the factory definitions, now that we've required everything (unless they have already been loaded)
FactoryGirl.factory_by_name('account') rescue FactoryGirl.find_definitions

# Skips validation of locale in order to avoid deprecation message.
I18n.enforce_available_locales = false
