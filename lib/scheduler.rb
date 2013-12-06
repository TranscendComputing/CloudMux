# Scheduling for Ansible
require 'sinatra'
require 'rufus-scheduler'
require 'fog'
require 'net/http'
require File.join(File.dirname(__FILE__),'ansible','rest_client.rb')

scheduler = Rufus::Scheduler.new


def runQueue()
  cloud_acc = CloudAccount.find('529dc24030166205da000006');
  config = cloud_acc.config_managers.select{
    |c| c['type'] == 'ansible'}[0]
  if config
    url = config.protocol + "://" + config.host + ":" + config.port
    ansible = Ansible::Client.new(url, 
      config.auth_properties['ansible_user'], 
      config.auth_properties['ansible_pass'])
  end
  # run fresh queue items 
  queue = QueueItem.where(:create.lt => Time.now)
    .where(:complete=> {'$not' =>{'$lt' => Time.now}})
  queue.each do |qitem|
    if (qitem.action)
      # get our aws creds
      print qitem
      cloud_cred = Account.find_cloud_credential(qitem.cred_id)

      # now for our ansible creds
      #cloud_acc = CloudAccount.find(qitem.account_id);
      @cf = Fog::AWS::CloudFormation.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
      response = @cf.describe_stack_resources({'StackName'=>qitem.data}).body["StackResources"]
      if response[0]['ResourceStatus'] == "CREATE_COMPLETE"
        host,jobs = qitem.action.split(':')
        success = ansible.post_job_templates_run(jobs, host) 
        if (success)
          qitem.complete = Time.now
        end
      end
    end
  end
end

# runs on startup
Thread.new do
  scheduler.every '10s' do
    runQueue
  end
  scheduler.join
end


