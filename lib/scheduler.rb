# Scheduling for CloudMux
require 'sinatra'
require 'rufus-scheduler'
require 'fog'
require 'net/http'
require File.join(File.dirname(__FILE__),'ansible','rest_client')

scheduler = Rufus::Scheduler.new

# Ansible Work
def runQueue()
  queue = QueueItem.where(:create.lt => Time.now)
   .where(:complete=> {'$not' =>{'$lt' => Time.now}})
  queue.each do |qitem|
# [FIXME] right now only processes an ansible queue
    queue_ansible qitem
  end
end

# runs on startup
Thread.new do
  scheduler.every '10s' do
#    runQueue
  end
  scheduler.join
end

# Continuous Integration Update
scheduler.every '1h' do
    system("rake ci:update_status")
end





