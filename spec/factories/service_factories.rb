FactoryGirl.define do
  factory :country, :class => Country do |a|
    a.code 'United States'
    a.name 'United States'
  end

  factory :account, :class => Account do |a|
    a.login 'test'
    a.email 'test@test.com'
    # let each spec set it if needed - this will reduce the calls to bcrypt and speed up tests that don't need a password to be set
    # a.password 'test12345'
    a.association :country, :factory=>:country
  end

  factory :stack, :class => Stack do |a|
    a.name 'Test stack'
    #a.public true
    # a.resource_groups ["group1", "group2", "group 3"]
  end

#  factory :create_stack, :class=> CreateStack do |a|
#    a.name "New Stack"
#    a.description "My new sStack"
#  end

#  factory :template, :class => Template do |a|
#    a.name 'Test template'
#    a.import_source 'test'
#    a.raw_json '{"description":"This is a test template"}'
#  end

  factory :query, :class => Query do |a|
    a.total 504
    a.page 10
    a.offset 500
  end

  factory :category, :class => Category do |a|
    a.name "My Category"
  end

  factory :subscriber, :class => Subscriber do |a|
    a.role 'admin'
    a.association :account, :factory=>:account, :login=>"admin_subscriber", :email=>"admin@example.com"
  end

  factory :subscription, :class => Subscription do |a|
    a.product 'test'
    # a.billing_level 'test_level'
    # a.billing_customer_id 'test_customer'
    # a.billing_subscription_id 'test_subscription_id'
  end

  factory :org, :class => Org do |a|
    a.name 'Test Org'
  end

  factory :cloud_service, :class => CloudService do |a|
    a.service_type 'S3'
    a.path '/'
  end

  factory :cloud, :class => Cloud do |a|
    a.name 'My Public Cloud'
    a.cloud_provider 'AWS'
    a.public true
  end

  factory :cloud_account, :class => CloudAccount do |a|
    a.name 'My Cloud Account'
    a.topstack_enabled true
    a.topstack_id 'cloud_zone'
  end

  factory :cloud_mapping, :class => CloudMapping do |a|
    a.name 'My Mapping'
  end

  factory :cloud_credential, :class => CloudCredential do |a|
    a.name 'My Cloud Account'
  end

  factory :project, :class => Project do |a|
    a.name 'My Project'
    a.description 'A test project'
    a.region 'us-east-1'
  end

  factory :member, :class => Member do |a|
    a.role Member::OWNER
  end

  factory :version, :class => Version do |a|
    a.number '1.0.0'
  end

  factory :environment, :class => Environment do |a|
    a.name 'stage'
  end

  factory :project_version, :class => ProjectVersion do |a|
    a.version '1.0.0'
    project
  end

  factory :element, :class => Element do |a|
    a.name 'Element 1'
    a.group_name 'Resources'
    a.element_type 'AWS::AutoScaling::AutoScalingGroup'
  end

  factory :node, :class => Node do |a|
    a.name 'Node 1'
    a.x '10'
    a.y '20.5'
    a.view 'design'
    a.element_id '50213cc2e5ef35119400073e'
  end

  factory :node_link, :class => NodeLink do |a|
  end

  factory :provisioned_version, :class => ProvisionedVersion do |a|
    a.stack_name 'Demo'
    a.environment 'Production'
    a.version '1.0.0'
  end

  factory :provisioned_instance, :class => ProvisionedInstance do |a|
    a.instance_type 'AWS::EC2'
    a.resource_id 'resource_123'
    a.instance_id 'instance_xyz'
    a.properties Hash.new
  end

  factory :variant, :class => Variant do |a|
    a.environment 'Production'
    a.rule_type 'Node'
    a.rules Hash.new
  end

  factory :embedded_project, :class => EmbeddedProject do |a|
  end
  
  #factory :news_event, :class => NewsEvent do |a|
  #  a.description 'Transcend Launches'
  #  a.url 'https://www.transcendcomputing.com'
  #  a.source 'TranscendComputing'
  #  a.posted Time.now
  #end

  factory :price, :class => Price do |a|
    a.name 'm1.small'
    a.type 'compute'
    a.effective_price 0.66
    a.effective_date Time.now
  end

  factory :qitem, :class =>QueueItem do |a|
    a.action "MockInstance"
    a.data "MockStack"
    a.create Time.now
  end

end

