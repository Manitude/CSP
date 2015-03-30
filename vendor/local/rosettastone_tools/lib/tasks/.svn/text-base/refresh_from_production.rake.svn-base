# Copyright:: Copyright (c) 2006 Rosetta Stone
# License:: All rights reserved.

desc "Copy a specified database to your local computer. Defaults to production."
task :refresh_db => :environment do
  include SayWithTime
  begin
  connection_spec = ENV['connection'] || 'production-slave'
  do_not_gzip = (ENV['gzip'] == 'false')
  production_slave_params = RosettaStone::CommandLineMysql.get_parameters(connection_spec)
  local_db_params = RosettaStone::CommandLineMysql.get_parameters(RAILS_ENV)

  # we set this class up so we can get the list of tables on the production slave
  class ProductionSlave < ActiveRecord::Base
    establish_connection (ENV['connection'] || 'production-slave')
  end
  tables_on_production = ProductionSlave.connection.tables
  tables_in_local_db = ActiveRecord::Base.connection.tables

  # check and delete/warn if there are local tables that don't exist on the slave
  (tables_in_local_db - tables_on_production).each do |local_table|
    if ENV['drop_local_tables']
      say_with_time("dropping local table '#{local_table}'") do 
        ActiveRecord::Base.connection.drop_table(local_table)
      end
    else
      puts "Note: the table '#{local_table}' exists in your local #{RAILS_ENV} database but not on '#{connection_spec}'.  Run with 'drop_local_tables=true' to automatically drop it when refreshing."
    end
  end

  ignore_views = ENV['ignore_views'] ? ENV['ignore_views'].split(',') : []
  
  if ENV['only_tables']
    ignore_tables = tables_on_production - ENV['only_tables'].split(',')
  elsif ENV['ignore_tables']
    ignore_tables = ENV['ignore_tables'].split(',')
  else
    ignore_tables = []
  end
  # mysqldump honors views in this statement
  ignore_table_string = (ignore_tables | ignore_views).collect {|table| "--ignore-table=#{ActiveRecord::Base.configurations[connection_spec]['database']}.#{table}"}.join(" ")

  # this shouldn't be done for views
  ignore_tables.each do |table|
    if ActiveRecord::Base.connection.tables.include?(table)
      say_with_time("truncating data from table '#{table}'") do 
        ActiveRecord::Base.connection.execute("truncate table #{table}")
      end
    end
  end

  file_extension_addendum = do_not_gzip ? '' : '.gz'
  cat_program = do_not_gzip ? 'cat' : 'gzcat'
  pipe_to_gzip = do_not_gzip ? '' : '| gzip'

  temp_name = File.join("/tmp", "#{ActiveRecord::Base.configurations[connection_spec]['database']}_dump_#{Time.now.strftime('%Y-%m-%d')}.sql#{file_extension_addendum}")
  command = "mysqldump #{production_slave_params} #{ignore_table_string} --lock-tables=false --compress #{pipe_to_gzip} > #{temp_name} && (#{cat_program} #{temp_name} | mysql #{local_db_params}) && rm #{temp_name}"

  say_with_time("executing #{command.gsub(/-p[^ ]* /, '-p ')}") do 
    `#{command}`
  end
  rescue Exception => e
    raise "Failed!  Do you have the '#{connection_spec}' stanza in your config/database.yml?  Exception was: #{e.inspect}"
  end
end

desc "Copy the entire production database to your local computer"
task :refresh_from_production => :refresh_db

namespace :db do
  task :intertwingle do
    puts "Intertwingling database: production..."
    rand(100).times do
      print(".")
      $stdout.flush
      sleep(rand)
    end
    print("\n")
    puts("Intertwingled.")
  end
end
