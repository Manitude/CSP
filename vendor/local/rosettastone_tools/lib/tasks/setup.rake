# Copyright:: Copyright (c) 2006 Rosetta Stone
# License:: All rights reserved.
#
# custom rake task for setting up a rails environment
# note setup:app_specific, which is meant to be defined in RAILS_ROOT/lib/tasks if necessary

namespace :setup do

  desc "Run setup:db, followed immediately by db:fixtures:load, db:test:prepare and possibly annotate_models. Explode!"
  task :explode => :db do
    next unless defined?(ActiveRecord)
    RosettaStone::Setup.migrate_db('test') # otherwise there won't be any tables, and db:fixtures:load will fail
    Rake::Task['db:fixtures:load'].invoke 
    puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} db:test:prepare` # separate command because making it a dependent task messes up app launcher/ollcs for unknown reasons

    # conditionally taking out annotate_models for now since in this context it breaks with validation_reflection plugin.. it can be run separately with no problem though.  thanks for your understanding.
    if Rake::Task.task_defined?('annotate_models')
      puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} annotate_models`
    end
  end

  # this task depends on having an entry in your database configs (dblogin.yml is a good place) for "migration"
  # it creates your databases, grants the proper permissions based on your database configs, and gets you up to date
  # by running rake db:migrate
  desc "Create app db and grant the proper permissions based on the configs in database.yml"
  task :db => :environment do
    next unless defined?(ActiveRecord)

    rails_environments =
      if ENV['only']
        [ENV['only']]
      else  # find them all
        root = defined?(RAILS_ROOT) ? RAILS_ROOT : Rails.root
        Dir.glob("#{root}/config/environments/*.rb").map {|file_name| File.basename(file_name).sub(/\.rb$/, "")}
      end

    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['migration'])

    for db in rails_environments do
      RosettaStone::Setup.explode_db(db, 'migration')
    end

    environment_to_migrate = ENV['only'] ? ENV['only'] : 'development'
    puts "---\nrunning all migrations for #{environment_to_migrate} environment...\n"
    RosettaStone::Setup.migrate_db(environment_to_migrate)

    if Rake::Task.task_defined?('setup:app_specific')
      puts "---\nrunning app specific setup...\n"
      puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} setup:app_specific`
    end

    puts "---\ndb setup complete.\n---"
  end

  desc "Runs rake setup:db and loads data from fixtures."
  task :instantiate => ['setup:db', 'db:fixtures:load']

  desc "Copy all sample files into place (without the .sample extension)."
  task :sample_files do
    sample_files = Dir.glob("config/*.yml.sample")
    raise "There were no sample files under config. Please ensure that you run this task from Rails.root (I don't want to require the rails environment)." if sample_files.empty?
    sample_files.each do |sample_file|
      real_file = sample_file.sub('.sample', '')
      puts "copying #{sample_file} to #{real_file}"
      FileUtils.cp(sample_file, sample_file.sub('.sample', ''))
    end
  end

  desc "One thing that really hoses a rails instance is the lack of a required config file. this will notify if you are hosed in this way."
  task :check_config do
    sample_files = Dir.glob("config/*.yml.sample")
    raise "There were no sample files under config. Please ensure that you run this task from Rails.root (I don't want to require the rails environment)." if sample_files.empty?
    sample_files.each do |sample_file|
      real_file = sample_file.sub('.sample', '')
      next if real_file.include?('ssl.yml') || File.exists?(real_file) # ssl.yml is not required
      puts "MISSING CONFIG FILE: #{real_file}"
    end
  end

  desc "Do some of the setup one might want to do when initially installing a rails app for development"
  task :all => [:sample_files, :explode, :rabbit]

  task :rabbit => :environment do
    if File.exists?(File.join(Framework.root.to_s, 'vendor', 'plugins', 'lagomorphic')) || File.exists?(File.join(Framework.root.to_s, 'vendor', 'gems', 'lagomorphic'))
      Rake::Task['rabbit:setup'].invoke
    end
  end

  desc "Serve pancakes"
  task :pancakes do
    puts "\nYou receive a hot stack of 3 delicious pancakes with butter."
    puts <<-PANCAKES

     _._.___======__.__.__._
    /                       \\
    \\_______________________/
    /                       \\
    \\_______________________/
    /                       \\
,   \\_______________________/   ,
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+

    PANCAKES

  end
end # namespace :setup

# alias the old task for backward compatibility:
task :setup_db => "setup:db"
