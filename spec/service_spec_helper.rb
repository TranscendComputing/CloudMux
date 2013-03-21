# test env
require 'rspec'
require 'spec_helper'

# gems
require 'mongoid'
require 'database_cleaner'

# require the dependencies
require File.join(File.dirname(__FILE__), '..', 'app', 'init')

# set the mongoid debugging output to something sane for tests
Mongoid.logger.level = Mongoid.logger.class::ERROR

# Tell Factory Girl to load the factory definitions, now that we've required everything (unless they have already been loaded)
FactoryGirl.factory_by_name('account') rescue FactoryGirl.find_definitions
