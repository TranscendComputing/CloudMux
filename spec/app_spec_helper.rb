# test env
require 'rspec'
require 'spec_helper'
require 'rack/test'
require 'sinatra'

# gems
require 'mongoid'
require 'fog'
require 'database_cleaner'

# require the dependencies
require File.join(File.dirname(__FILE__), '..', 'lib', 'core')
require File.join(File.dirname(__FILE__), '..', 'lib', 'cfdoc')
require File.join(File.dirname(__FILE__), '..', 'lib', 'service')
require File.join(File.dirname(__FILE__), '..', 'app', 'api_base')

# load mongo config
Mongoid.load!('app/config/mongoid.yml')

# set the mongoid debugging output to something sane for tests
Mongoid.logger.level = Mongoid.logger.class::ERROR

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

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
