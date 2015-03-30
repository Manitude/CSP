# Copyright:: Copyright (c) 2006 Rosetta Stone
# License:: All rights reserved.

# Rake task to connect to the current app's database.
# mama_l> rake mysql
# mama_l> rake mysql production-slave
# mama_l> RAILS_ENV=test rake mysql
# ...connects you to the command line mysql client using the development database. set RAILS_ENV or pass a configuration name to override.
# FIXME: this is buggy since now "rake mysql RAILS_ENV=production" doesn't work
desc "Command-line access to mysql"
task :mysql => :environment do
  require 'rosetta_stone/command_line_mysql'
  configuration = ARGV[1] || (defined?(RAILS_ENV) ? RAILS_ENV : ::Rails.env)
  command = "mysql " + RosettaStone::CommandLineMysql.get_parameters(configuration)
  puts command.gsub(/-p[^ ]* /, '-p ')
  puts
  exec command
end
