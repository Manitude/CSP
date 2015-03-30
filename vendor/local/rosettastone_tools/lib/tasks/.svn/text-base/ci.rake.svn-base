# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.
# 
# This set of tasks allows for CI to set up an initial environment to test in

require 'fileutils'
require 'pathname'
require File.dirname(__FILE__) + '/../rosetta_stone/platform_independent_rake'

# Old versions of Rails (< 2.3? 2.0 for sure) break without this (For cattr_accessor)
require 'active_support'

module RosettaStone
  class CI
    cattr_accessor :failure_received
    class << self
      def copy_sample_to_real(final_name, suffix = 'sample')
        sample_location = Pathname.new(final_name).cleanpath
        final_location = Pathname.new(final_name.gsub(/.#{suffix}$/, '')).cleanpath
        #Don't copy the file over if the file is already there, since there's a possibility that
        #it already has special configuration
        unless config_files_to_ignore.include?(sample_location.to_s) && File.exists?(final_location)
          puts "Copying #{sample_location} to #{final_location}"
          FileUtils.cp(sample_location, final_location)
        end
      end
      def config_files_to_ignore
        %w(dblogin.yml.sample).map{|file| "#{rails_root}/config/#{file}"}
      end
      def sample_files_to_copy
        Dir.glob("#{rails_root}/config/*.yml.sample")
      end
      def ci_specific_files_to_copy
        Dir.glob("#{rails_root}/config/*.yml.ci")
      end
      def rails_root
        Rails::VERSION::MAJOR < 3 ? RAILS_ROOT : Rails.root
      end
    end
  end # CI
end # RosettaStone

namespace :ci do

  desc 'Performs all tasks necessary to run the CI suite, including running the tests themselves'
  task :run do
    Object.const_set('CI_RUN', true)
    #Forcing all rake tasks to return true, so that the tests keep going regardless of earlier
    #failures.  Hudson should pick up the failures based on the test results file.
    module FileUtils
      def rake_system(*cmd)
        failure_returned = !Rake::AltSystem.system(*cmd)
        puts "FAILURE RECEIVED" if failure_returned
        RosettaStone::CI.failure_received = failure_returned || RosettaStone::CI.failure_received
        true
      end
      private :rake_system
    end
    Rake::Task['ci:setup'].invoke
    # force to test environment:
    Object.const_set('RAILS_ENV', 'test')
    test_task = 'test'
    test_task = 'test:all' if Rake::Task.task_defined?('test:all'.to_sym)
    #Basically if CI wants to only run "test:units" then it would set the TESTING_ONLY env var to be 'units'
    if ENV["TESTING_ONLY"]
      test_task = "test:#{ENV["TESTING_ONLY"]}"
    end
    Rake::Task[test_task].invoke
    raise "There was a failure -- check the log!" if RosettaStone::CI.failure_received
  end
  
  task :setup do
    # run these in default (probably development) environment:
    Rake::Task['ci:prepare'].invoke
    Rake::Task['log:clear'].invoke
    Rake::Task['ci:migrate_db'].invoke
  end

  task :migrate_db => :environment do
    Rake::Task['db:migrate'].invoke if defined?(ActiveRecord) # this task is defined even if ActiveRecord is not loaded :(
    if Rake::Task.task_defined?('db:migrate:mongo')
      ENV['HUUS_ENV'] = 'test'
      ENV['FORCE'] = '1'
      Rake::Task['db:migrate:mongo'].invoke 
    end
  end

  task :copy_sample_configs do
    RosettaStone::CI.sample_files_to_copy.each {|config_file| RosettaStone::CI.copy_sample_to_real(config_file)}
    RosettaStone::CI.ci_specific_files_to_copy.each {|config_file| RosettaStone::CI.copy_sample_to_real(config_file, 'ci')}
  end

  task :prepare do
    ci_setup_dir = Rails::VERSION::MAJOR < 3 ? File.join(RAILS_ROOT,'ci_setup') : Rails.root.join('ci_setup')
    hostname_setup_record = File.join(ci_setup_dir, `hostname`.chomp)
    #Copy sample yml files over
    Rake::Task['ci:copy_sample_configs'].invoke

    #We want this setup to happen once-per-ci-box
    unless (File.exists?(hostname_setup_record))
      Dir.mkdir(ci_setup_dir) unless File.exists?(ci_setup_dir)
      #Create the database(s)
      puts "Setting up databases"
      puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} setup:db`
      #Setup rabbit (if it's there)
      begin
        puts "Setting up rabbit"
        puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} rabbit:setup`
        puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} rabbit:setup configuration=test`
      rescue => e
        puts "Rabbit not set up.  Assuming that this app doesn't need rabbit. #{e.to_s}"
      end
      #have to do this to get the system_readiness to pass the first time around
      puts "Setting up test database initially"
      puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} db:test:prepare`
      File.new(hostname_setup_record,'w')
    end
  end

end
