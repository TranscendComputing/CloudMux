# Scheduling for Ansible
require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new

def queueAnsibleStack(name, value)
  qitem = QueueItem.new.extend(QueueItemRepresenter)
  # qitem.caller = # get caller's id
  qitem.action = name # name of stack
  qitem.data = value # list of ansible jobs
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


