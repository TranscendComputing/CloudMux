require File.join(File.dirname(__FILE__), '..', 'lib', 'service')
require File.join(File.dirname(__FILE__), '..', 'lib', 'scheduler.rb')

# Setup the database connections
configure do
  Mongoid.load!('app/config/mongoid.yml')
end

configure [:development, :test] do
  Mongoid.logger = Logger.new($stdout)
end
