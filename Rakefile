require 'rubygems'

task :default => ["db:seed", :spec, "analyzer:all"]

task :environment do
  require File.join(File.dirname(__FILE__), 'app', 'init')
end

namespace :db do
  desc "Seed the database"
  task :seed => [:environment] do
    require 'seed/seed'
  end

  desc "Create indexes"
  task :create_indexes => [:environment] do
    files = Dir.glob(File.dirname(__FILE__) + '/lib/service/model/*.rb')
    files.each do |file|
      classname = File.basename(file).gsub('.rb','').camelize
      clazz = Kernel.const_get(classname)
      if clazz.respond_to?(:create_indexes)
        puts "Creating indexes for #{classname}"
        clazz.create_indexes
      end
    end
  end

  desc "Truncate categories - USE WITH CAUTION"
  task :truncate_categories => [:environment] do
    Category.collection.drop
  end

  desc "Truncate stacks - USE WITH CAUTION"
  task :truncate_stacks => [:environment] do
    Stack.collection.drop
    Template.collection.drop
  end

  desc "Truncate clouds - USE WITH CAUTION"
  task :truncate_clouds => [:environment] do
    Cloud.collection.drop
  end

  desc "Truncate cloud mappings"
  task :truncate_mappings => [:environment] do
  	Cloud.all.each do |c|
  		c.cloud_mappings = []
  	end
  end

  desc "Truncate cloud prices"
  task :truncate_prices => [:environment] do
	Cloud.all.each do |c|
		c.prices = []
	end
  end

  desc "Truncate projects - USE WITH CAUTION"
  task :truncate_projects => [:environment] do
    Project.collection.drop
  end


end

begin
  require 'rspec/core/rake_task'

  # Put spec opts in a file named .rspec in root
  desc "Run all specs"
  RSpec::Core::RakeTask.new(:spec)

  desc "Run only core specs"
  RSpec::Core::RakeTask.new("spec:core") do |t|
    t.pattern = "./spec/core/**/*_spec.rb"
  end

  desc "Run only cfdoc specs"
  RSpec::Core::RakeTask.new("spec:cfdoc") do |t|
    t.pattern = "./spec/cfdoc/**/*_spec.rb"
  end

  desc "Run only service specs"
  RSpec::Core::RakeTask.new("spec:service") do |t|
    t.pattern = "./spec/service/**/*_spec.rb"
  end

  desc "Run only Sinatra specs"
  RSpec::Core::RakeTask.new("spec:app") do |t|
    t.pattern = "./spec/app/**/*_spec.rb"
  end
rescue LoadError
  # not in dev/test env - skip installing these tasks
end

namespace :admin do
  desc "Clear all stacks and templates. CAUTION!"
  task :clear_stacks => [:environment] do
    Mongoid.database['stacks'].remove
    Mongoid.database['templates'].remove
  end

  desc "Clear all categories. CAUTION!"
  task :clear_categories => [:environment] do
    Mongoid.database['categories'].remove
  end
end

namespace :update do
	require File.join(File.dirname(__FILE__), 'lib', 'service')
	Mongoid.load!('app/config/mongoid.yml')
	desc "Move all CURRENT project versions to 0.1.0"
	task :move_current_versions do
		Project.find(:all).each do |project|
			initial_version = project.versions.find(:all, :conditions=>{:number=>"0.1.0"}).first
			if initial_version.nil?
				new_version =  Version.new
				new_version.number = "0.1.0"
				new_version.description = "Initial version"
				new_version.versionable = project
				new_version.save!

				project_version = project.current_version
				unless project_version.nil?
					project_version.version = "0.1.0"
					project_version.save!
				end
			end
		end
	end

  desc "Update cloud account and add cloud credentials model"
  task :cloud_account_models => [:environment] do
    Mongoid.load!('app/config/mongoid.yml')
    require 'mongo'
    include Mongo
    if ENV['RACK_ENV'] == "development"
      cli = MongoClient.new("localhost", 27017)
      db = cli.db("stack_place_development")
    else
      cli = MongoClient.new
      db = cli.db("transcend_db")
    end
    Org.find(:all).each do |org|
      Cloud.find(:all).each do |cloud|
        cloud_account = CloudAccount.where(:cloud_id => cloud.id, :org_id => org.id).first
        if cloud_account.nil?
          cloud_account = CloudAccount.new(:name => cloud.name)
          cloud_account.org = org
          cloud_account.cloud = cloud
          db_cloud = db["clouds"].find("_id" => cloud.id).to_a[0]
          cloud_services = db_cloud["cloud_services"]
          unless cloud_services.nil?
            cloud_services.each do |service|
              new_service = CloudService.new
              new_service.service_type = service["type"]
              new_service.path = service["path"]
              new_service.host = service["host"]
              new_service.port = service["port"]
              new_service.enabled = service["enabled"]
              cloud_account.cloud_services << new_service
            end
          end
          cloud_mappings = db_cloud["cloud_mappings"]
          unless cloud_mappings.nil?
            cloud_mappings.each do |mapping|
              new_mapping = CloudMapping.new
              new_mapping.name = mapping["name"]
              new_mapping.mapping_type = mapping["mapping_type"]
              new_mapping.properties = mapping["properties"]
              new_mapping.mapping_entries = mapping["mapping_entries"]
              cloud_account.cloud_mappings << new_mapping
            end
          end
          prices = db_cloud["prices"]
          unless prices.nil?
            prices.each do |price|
              new_price = Price.new
              new_price.name = price["name"]
              new_price.type = price["type"]
              new_price.effective_price = price["effective_price"]
              new_price.effective_date = price["effective_date"]
              new_price.properties = price["properties"]
              new_price.entries = price["entries"]
              cloud_account.prices << new_price
            end
          end
          puts "Creating cloud account for org: #{org.name}, cloud: #{cloud.name}"
          cloud_account.save
        end
        org.accounts.each do |account|
            db_account = db["accounts"].find("_id" => account.id).to_a[0]
            cloud_accounts = db_account["cloud_accounts"]
            unless cloud_accounts.nil?
              cloud_accounts.each do |ca|
                if account.cloud_credentials.where(:name => ca["name"]).first.nil?
                  if ca["cloud_id"] == cloud.id
                    new_credentials = CloudCredential.new
                    new_credentials.name = ca["name"]
                    new_credentials.description = ca["description"]
                    new_credentials.access_key = ca["access_key"]
                    new_credentials.secret_key = ca["secret_key"]
                    new_credentials.cloud_attributes = ca["cloud_attributes"]
                    new_credentials.stack_preferences = ca["stack_preferences"]
                    new_credentials.topstack_configured = ca["topstack_configured"]
                    account.add_cloud_credential!(cloud_account.id, new_credentials)
                  end
                end
              end
            end
          end
      end
    end
    cli.close
  end
end

namespace :update do
	desc "Give admin permissions to project owners"
	task :admin_permissions_to_owners do
		Project.find(:all).each do |project|
			project.members.select { |s| s.role.to_s == "owner" }.each do |member|
				if member.permissions.nil? || member.permissions.length == 0
					member.permissions = []
					environments = [Environment::DEV, Environment::TEST, Environment::STAGE, Environment::PROD]
					environments.each do |e|
						member.permissions << Permission.new(:name => Permission::VIEW, :environment => e)
						member.permissions << Permission.new(:name => Permission::EDIT, :environment => e)
						member.permissions << Permission.new(:name => Permission::PUBLISH, :environment => e)
						member.permissions << Permission.new(:name => Permission::PROMOTE, :environment => e)
						member.permissions << Permission.new(:name => Permission::CREATE_STACK, :environment => e)
						member.permissions << Permission.new(:name => Permission::UPDATE_STACK, :environment => e)
						member.permissions << Permission.new(:name => Permission::DELETE_STACK, :environment => e)
						member.permissions << Permission.new(:name => Permission::MONITOR, :environment => e)
					end
				end
			end
		end
	end
end

begin
  namespace :analyzer do
    desc "run all code analyzing tools (flog)"

    task :all => ["flog:total", "flay:flay"]

    namespace :flog do
      require 'flog_cli'
      desc "Analyze total code complexity with flog"
      task :total do
        threshold = 20
        flog = FlogCLI.new
        flog.flog %w(app lib)
        average = flog.average.round(1)
        total_score = flog.total_score
        puts "Average complexity: #{flog.average.round(1)}"
        puts "Total complexity: #{flog.total_score.round(1)}"
        flog.report
        fail "Average code complexity has exceeded max! (#{average} > #{threshold})" if average > threshold
      end
    end

    namespace :flay do
      require 'flay_task'
      #desc "Analyze code duplication with flay"
      FlayTask.new() do |t|
        t.verbose = true
        t.threshold = 21050
      end
    end
  end
rescue LoadError
    # not in dev/test env - skip installing these tasks
end
