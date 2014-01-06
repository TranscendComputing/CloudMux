require File.join(File.dirname(__FILE__), '..', 'lib', 'service')
require File.join(File.dirname(__FILE__), '..', 'lib', 'scheduler.rb')
require File.join(File.dirname(__FILE__), '..', 'config_ldap')

# Setup the database connections
Mongoid.load!('app/config/mongoid.yml')
