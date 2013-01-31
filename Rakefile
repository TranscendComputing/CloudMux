require 'rubygems'

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

