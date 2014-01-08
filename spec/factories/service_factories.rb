FactoryGirl.define do
  factory :country, class: Country  do |a|
    a.code 'United States'
    a.name 'United States'
  end

  factory :account, class: Account  do |a|
    a.login 'test'
    a.email 'test@test.com'
    a.association :country, :factory=>:country
  end

  factory :stack, class: Stack  do |a|
    a.name 'Test stack'
  end

  factory :query, class: Query  do |a|
    a.total 504
    a.page 10
    a.offset 500
  end

  factory :category, class: Category  do |a|
    a.name 'My Category'
  end

  factory :subscriber, class: Subscriber  do |a|
    a.role 'admin'
    a.association :account, :factory=>:account, :login=>'admin_subscriber', :email=>'admin@example.com'
  end

  factory :subscription, class: Subscription  do |a|
    a.product 'test'
  end

  factory :org, class: Org  do |a|
    a.name 'Test Org'
  end

  factory :cloud_service, class: CloudService  do |a|
    a.service_type 'S3'
    a.path '/'
  end

  factory :cloud, class: Cloud  do |a|
    a.name 'My Public Cloud'
    a.cloud_provider 'AWS'
    a.public true
  end

  factory :cloud_account, class: CloudAccount  do |a|
    a.name 'My Cloud Account'
    a.topstack_enabled true
    a.topstack_id 'cloud_zone'

    factory :full_cloud_account do |fa|
      fa.cloud  { FactoryGirl.build(:cloud) }
      fa.org  { FactoryGirl.build(:org) }
    end
  end

  factory :cloud_mapping, class: CloudMapping  do |a|
    a.name 'My Mapping'
  end

  factory :cloud_credential, class: CloudCredential  do |a|
    a.name 'My Cloud Account'
  end

  factory :full_cloud_credential, class: CloudCredential  do
    name 'My Cloud Account'
    access_key 'not_secret'
    secret_key 'secret'
    cloud_account { FactoryGirl.create(:full_cloud_account) }
    account { FactoryGirl.create(:account) }

    factory :full_google_credential, class: CloudCredential  do
      cloud_attributes { {google_storage_access_key_id: 'xyz', google_storage_secret_access_key: 'pdq'} }
    end
  end

  factory :project, class: Project  do |a|
    a.name 'My Project'
    a.description 'A test project'
    a.region 'us-east-1'
  end

  factory :member, class: Member  do |a|
    a.role Member::OWNER
  end

  factory :version, class: Version  do |a|
    a.number '1.0.0'
  end

  factory :environment, class: Environment  do |a|
    a.name 'stage'
  end

  factory :project_version, class: ProjectVersion  do |a|
    a.version '1.0.0'
    project
  end

  factory :element, class: Element  do |a|
    a.name 'Element 1'
    a.group_name 'Resources'
    a.element_type 'AWS::AutoScaling::AutoScalingGroup'
  end

  factory :node, class: Node  do |a|
    a.name 'Node 1'
    a.x '10'
    a.y '20.5'
    a.view 'design'
    a.element_id '50213cc2e5ef35119400073e'
  end

  factory :node_link, class: NodeLink  do |a|
  end

  factory :provisioned_version, class: ProvisionedVersion  do |a|
    a.stack_name 'Demo'
    a.environment 'Production'
    a.version '1.0.0'
  end

  factory :provisioned_instance, class: ProvisionedInstance  do |a|
    a.instance_type 'AWS::EC2'
    a.resource_id 'resource_123'
    a.instance_id 'instance_xyz'
    a.properties Hash.new
  end

  factory :variant, class: Variant  do |a|
    a.environment 'Production'
    a.rule_type 'Node'
    a.rules Hash.new
  end

  factory :embedded_project, class: EmbeddedProject

  factory :price, class: Price  do |a|
    a.name 'm1.small'
    a.type 'compute'
    a.effective_price 0.66
    a.effective_date Time.now
  end

  factory :qitem, class: QueueItem do |a|
    a.action 'MockInstance'
    a.data 'MockStack'
    a.create Time.now
  end

  factory :git_repo, class: SourceControlRepository do
    name 'MockGitRepo'
    type 'git'
    url 'git@giturl.com:/GitRepo.git'
    username 'test'
    password 'test'
  end

  factory :jenkins_server, class: ContinuousIntegrationServer do
    name 'MockJenkinsServer'
    type 'jenkins'
    url 'http://mockjenkins.com:8080'
    username 'test'
    password 'test'
  end

  factory :config_manager, class: ConfigManager do |a|
    a.url 'http://configurl.localhost'
    a.name 'MockConfigManager'
    a.branch 'test'
  end

  factory :chef_config_manager, class: ConfigManager do
    url 'http://configurl.localhost'
    name 'MockChefConfigManager'
    branch 'test'
    type 'chef'
    continuous_integration_servers [ FactoryGirl.create(:jenkins_server) ]
    source_control_repositories [ FactoryGirl.create(:git_repo) ]
    auth_properties { {
      'client_name' => 'tester',
      'key' => 'secret_content'
      } }
  end


end

