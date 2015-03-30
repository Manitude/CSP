# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

namespace :rabbit do

  desc "Setup rabbitmq vhost, user, and permissions from rabbit.yml for the specified configuration (or the default configuration if not specified)"
  task :setup => :environment do
    Rabbit::Helpers.setup!(ENV['configuration'])
  end

  desc "Blow away the user and vhost for the specified configuration (or the default configuration if not specified) from rabbit.yml.  Careful, this is unhesitatingly destructive!  Lagomorphic style!"
  task :remove_setup => :environment do
    Rabbit::Helpers.remove_setup!(ENV['configuration'])
  end

  desc "Blow away configuration and re-setup rabbit vhost, user, and permissions from rabbit.yml for all envs"
  task :explode => :environment do
    env_before = ENV['configuration']
    %w(test development production).each do |env|
       puts "setting up rabbitmq for #{env}..."
       ENV['configuration'] = env
       Rake::Task['rabbit:remove_setup'].execute
       Rake::Task['rabbit:setup'].execute
    end
    ENV['configuration'] = env_before
  end
end