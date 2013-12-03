# Scheduling for Ansible
require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new

def queueStack(result)
  # add item
end

def runQueue()
  # run fresh queue items 
  a = 1+1
end

# runs on startup
Thread.new do
  scheduler.every '10s' do
    runQueue
  end
  scheduler.join
end


