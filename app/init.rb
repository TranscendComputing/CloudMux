require File.join(File.dirname(__FILE__), '..', 'lib', 'service')
require File.join(File.dirname(__FILE__), '..', 'lib', 'scheduler.rb')

# Setup the database connections
Mongoid.load!('app/config/mongoid.yml')
