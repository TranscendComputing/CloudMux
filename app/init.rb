require File.join(File.dirname(__FILE__), '..', 'lib', 'service')

# Setup the database connections
Mongoid.load!('app/config/mongoid.yml')
