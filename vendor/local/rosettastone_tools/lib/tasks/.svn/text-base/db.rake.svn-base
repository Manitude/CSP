# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.
#
# Overrides/extensions for the 'db' Rake namespace

namespace :db do
  desc "Formatted display of AR connection stanzas in this app."
  task :configs => :environment do
    configs = ActiveRecord::Base.configurations

    details = configs.sort_by(&:first).map do |config|
      name, detail = *config
      { :name => name,
        :host => "#{detail['host']}:#{detail['port']}",
        :db => "#{detail['database']}",
        :db_sub => "(#{detail['adapter']},#{detail['encoding']})",
        :login => "#{detail['username']}/#{detail['password']}"
      }
    end
    details.unshift({ :name => "Config", :host => "Host:Port", :db => "Database", :db_sub => "", :login => "Username/Password" })
    name_length = details.map {|detail| detail[:name].length }.max
    host_length = details.map {|detail| detail[:host].length }.max
    db_length = details.map {|detail| detail[:db].length }.max
    db_sub_length = details.map {|detail| detail[:db_sub].length }.max
    login_length = details.map {|detail| detail[:login].length }.max
    details.each do |detail|
      fmt = "%-#{name_length}s  %-#{host_length}s  %-#{db_length}s  %-#{db_sub_length}s  %-#{login_length}s"
      puts fmt % [detail[:name], detail[:host], detail[:db], detail[:db_sub], detail[:login]]
    end
  end

  namespace :test do
    desc 'Delete all the tables in the test database'
    task :drop_all_tables => :environment do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      ActiveRecord::Base.connection.without_foreign_key_checks do |conn|
        # FIXME: this respond_to check is necessary because there is a dependency on https://svn.lan.flt/svn/WebDev/plugins/ActiveRecordExtensions/trunk,
        # which the viper_service does not include. See https://trac.lan.flt/Viper/ticket/2313.
        if conn.respond_to?(:full_tables)
          [:table, :view].each do |type|
            conn.full_tables(type).each do |table_name|
              conn.execute("DROP #{type} `#{table_name}`")
            end
          end
        else
          conn.tables.each { |table| conn.drop_table(table) }
        end
      end
    end
  end
end

# allow an app to define db:test:app_specific_prepare that will run after db:test:prepare.
if Rake::Task.task_defined?('db:test:prepare')
  Rake::Task['db:test:prepare'].enhance do
    app_specific_subtask = "db:test:app_specific_prepare"
    Rake::Task[app_specific_subtask].invoke if Rake::Task.task_defined?(app_specific_subtask)
  end
end