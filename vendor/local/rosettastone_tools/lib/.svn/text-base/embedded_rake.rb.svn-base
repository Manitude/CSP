# -*- encoding : utf-8 -*-
module RosettaStone
  module EmbeddedRake
    def self.find_rails_root(expected = %w{ app config db lib public script vendor }, directory = Dir.pwd)
      entries = Dir["#{directory}/*"].entries.collect { |entry| File.basename(entry) }
      if (expected - entries).empty?
        directory
      elsif directory == '/'
        nil
      else
        find_rails_root(expected, File.expand_path(directory + '/..'))
      end
    end

    # hack to try to keep most rake tasks silent on stdout when invoked from cron to suppress cron's email delivery
    def self.appears_to_be_invoked_from_cron?
      (ENV['SHELL'] == '/bin/sh')
    end

    def self.run
      rails_root = find_rails_root
      rake_path = File.join(rails_root, 'vendor', 'rake', 'lib')
      if rails_root && File.directory?(rake_path)
        puts "Using rake found in #{rake_path}" unless appears_to_be_invoked_from_cron?
        $LOAD_PATH.insert(0, rake_path)
        require 'rake'
      else
        puts "Using rake installed via RubyGems" unless appears_to_be_invoked_from_cron?
        require 'rubygems'
        gem 'rake'
      end
      Rake.application.run
    end
  end
end
