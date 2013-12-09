# Scheduling for Ansible
require 'sinatra'
require 'rufus-scheduler'
require 'fog'
require 'net/http'
require File.join(File.dirname(__FILE__),'ansible','rest_client.rb')

scheduler = Rufus::Scheduler.new


# [FIXME] right now only processes an ansible queue
def runQueue()
  # ansible creds
  # [FIXME] Hardcoded value for development
  # [XXX] Stackstudio giving wrong value of '529dc24030166205da000007'  
  cloud_acc = CloudAccount.find('529dc24030166205da000006');
  config = cloud_acc.config_managers.select{
    |c| c['type'] == 'ansible'}[0]
  if config
    url = config.protocol + "://" + config.host + ":" + config.port
    ansible = Ansible::Client.new(url, 
      config.auth_properties['ansible_user'], 
      config.auth_properties['ansible_pass'])
  end

  queue = QueueItem.where(:create.lt => Time.now)
    .where(:complete=> {'$not' =>{'$lt' => Time.now}})
  q = queue.first
  stack_name = q.data
  cloud_cred = Account.find_cloud_credential q.cred_id
  @cf = Fog::AWS::CloudFormation.new({
    :aws_access_key_id => cloud_cred.access_key, 
    :aws_secret_access_key => cloud_cred.secret_key})
  @ec =  Fog::Compute::AWS.new({
    :aws_access_key_id => cloud_cred.access_key, 
    :aws_secret_access_key => cloud_cred.secret_key})
  resp = @cf.describe_stack_resources({'StackName'=>stack_name})
  resources = resp.body["StackResources"]

  # run the queue
  queue.each do |qitem|
    complete = false
    if (qitem.action)
      instance_name,jobs = qitem.action.split(':')
      jobs = jobs.split(' ')
      hosts = {}
      resources.each do |r|
        if r['LogicalResourceId'] == instance_name and r['ResourceStatus'] == "CREATE_COMPLETE" and r['ResourceType'] == "AWS::EC2::Instance"
          instance_id = r['PhysicalResourceId']
          if instance_id
            instance = @ec.describe_instances({'instance-id'=>instance_id}).body
            public_ip = instance['reservationSet'].first['instancesSet'].first['ipAddress']
            # we have an ip now, register it on ansible 
            hosts[public_ip] = hosts[public_ip] ? hosts[public_ip] : ansible.post_hosts(public_ip, instance_name + " EC2 Instance") 
      
            if hosts[public_ip]
              complete = ansible.post_job_templates_run(jobs, public_ip) 
              if not complete
                qitem.errors[Time.now] = "Ansible Job %s failed to run on %s %s:%s" % [stack_name, jobs, instance_name,public_ip]
                qitem.save!
              end
            else 
              qitem.errors[Time.now] = "Failed to register host with Ansible %s %s:%s" % [stack_name, jobs, instance_name,public_ip]
              qitem.save!
            end
          end
        end
      end
    end
    if complete
      qitem.complete = Time.now
      qitem.save!
    end
  end
end

# runs on startup
Thread.new do
  scheduler.every '10s' do
    #runQueue
  end
  scheduler.join
end


