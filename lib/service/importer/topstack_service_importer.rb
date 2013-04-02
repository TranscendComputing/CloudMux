class TopstackServiceImporter

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

####### Creates default CF Template Image Mappings ############ 
  def import(cloud_account)
    puts "Removing any outdated Topstack Services for #{cloud_account.name} cloud_account"
    
    current_topstack_services = []
	current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"AS"})
    current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"ELB"})
    current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"RDS"})
    current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"AWSEB"})
    current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"ELC"})
    current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"ACW"})
    current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"SQS"})
    current_topstack_services << cloud_account.cloud_services.find(:first, :conditions=>{:service_type=>"DNS"})
    
    current_topstack_services.each {|service| service.delete unless service.nil?}
    
    
    puts "Creating Topstack Services for #{cloud_account.name} cloud_account"
    
    if cloud_account.cloud_provider == "OpenStack" || cloud_account.cloud_provider == "HP"
        cloud_path = "uuid"
    else
        cloud_path = "ec2"
    end
    
    cloud_host = "localhost"
    
    services = []
	
	as_service = CloudService.new
    as_service.service_type = "AS"
    as_service.path = "/AutoScaleQuery"
    as_service.host = cloud_host
    as_service.port = "8080"
    as_service.protocol = "http"
    as_service.enabled = true
    services << as_service
    
    elb_service = CloudService.new
    elb_service.service_type = "ELB"
    elb_service.path = "/LoadBalancerQuery/#{cloud_path}"
    elb_service.host = cloud_host
    elb_service.port = "8080"
    elb_service.protocol = "http"
    elb_service.enabled = true
    services << elb_service
    
    rds_service = CloudService.new
    rds_service.service_type = "RDS"
    rds_service.path = "/RDSQuery/rdsquery"
    rds_service.host = cloud_host
    rds_service.port = "8080"
    rds_service.protocol = "http"
    rds_service.enabled = true
    services << rds_service
    
    beanstalk_service = CloudService.new
    beanstalk_service.service_type = "AWSEB"
    beanstalk_service.path = "/ElasticBeanStalkQuery"
    beanstalk_service.host = cloud_host
    beanstalk_service.port = "8080"
    beanstalk_service.protocol = "http"
    beanstalk_service.enabled = false
    services << beanstalk_service
    
    cache_service = CloudService.new
    cache_service.service_type = "ELC"
    cache_service.path = "/ElastiCacheQuery/#{cloud_path}"
    cache_service.host = cloud_host
    cache_service.port = "8080"
    cache_service.protocol = "http"
    cache_service.enabled = true
    services << cache_service
    
    monitor_service = CloudService.new
    monitor_service.service_type = "ACW"
    monitor_service.path = "/MonitorQuery/#{cloud_path}"
    monitor_service.host = cloud_host
    monitor_service.port = "8080"
    monitor_service.protocol = "http"
    monitor_service.enabled = true
    services << monitor_service
    
    queue_service = CloudService.new
    queue_service.service_type = "SQS"
    queue_service.path = "/SQSQuery"
    queue_service.host = cloud_host
    queue_service.port = "8080"
    queue_service.protocol = "http"
    queue_service.enabled = true
    services << queue_service
    
    dns_service = CloudService.new
    dns_service.service_type = "DNS"
    dns_service.path = "/DNS53Server"
    dns_service.host = cloud_host
    dns_service.port = "8080"
    dns_service.protocol = "http"
    dns_service.enabled = true
    services << dns_service
    


    services.each do |service|
        if service.enabled
            puts "Adding \"#{service.service_type}\" service to #{cloud_account.name} cloud services"
        end
        
        begin
            cloud_account.cloud_services << service
            cloud_account.save!
        rescue => e
            if service.enabled
                log " skipping - failed to save: #{e}\n#{e.backtrace.join("\n")}"
            end
        end
    end
  end
  
  def log(message)
    puts message unless ENV["RACK_ENV"] == "test"
  end
end
