require 'fileutils'

namespace :audit_log do
  # Installs any migrations needed for the audit_log plugin to work properly. Do not modify or rename the
  # migration files that it creates.
  task :install_migrations => :environment do
    app_migration_directory, plugin_migration_directory = "#{RAILS_ROOT}/db/migrate/", "#{plugin_root}/migrations/"
    app_migration_files = find_migrations(app_migration_directory)
    plugin_migration_files = find_migrations(plugin_migration_directory)
    migrations_to_install = get_migrations_to_install(app_migration_files, plugin_migration_files)
    last_app_migration_number = (app_migration_files.blank?) ? 0 : app_migration_files.last[:number].to_i
    install_migrations(migrations_to_install, plugin_migration_directory, app_migration_directory, last_app_migration_number)
  end
  
  def install_migrations(migrations_to_install, from_dir, to_dir, last_migration_number)
    next_migration_number = (last_migration_number.to_i + 1)
    migrations_to_install.each do |name_and_number|
      migration_destination_name = "%03d_%s.rb" % [next_migration_number, name_and_number[:name]]
      migration_original_name = "#{name_and_number[:number]}_#{name_and_number[:name]}.rb"
      migration_destination_path = Pathname.new("#{to_dir}/#{migration_destination_name}").cleanpath.to_s
      migration_original_path = Pathname.new("#{from_dir}/#{migration_original_name}").cleanpath.to_s
      puts "Copying #{migration_original_path} to #{migration_destination_path}"
      FileUtils.cp(migration_original_path, migration_destination_path)
      next_migration_number += 1
    end
  end
  
  def find_migrations(path)
    migration_files = Dir["#{path}/*.rb"].collect do |filename|
      basename = File.basename(filename)
      (basename =~ /^\d{3}_[^\.]*\.rb$/) ? basename : nil
    end.compact.sort.collect {|filename| md = filename.match(/^(\d{3})_([^\.]*)\.rb$/); {:number => md[1], :name => md[2]} }
  end
  
  def plugin_root
    File.dirname(__FILE__) + "/../../"
  end
  
  def get_migrations_to_install(app_migrations, plugin_migrations)
    migrations_to_install = plugin_migrations.inject({}) do |migration_hash,name_and_number|
      migration_hash[name_and_number[:name]] = name_and_number[:number]
      migration_hash
    end

    plugin_migrations.each do |migration_name_and_number|
      app_already_has_migration = app_migrations.detect { |app_migration| app_migration[:name] == migration_name_and_number[:name] }
      migrations_to_install.delete(migration_name_and_number[:name]) if app_already_has_migration
    end
    migrations_to_install.collect {|name,number| {:name => name, :number => number} }.sort_by {|name_and_number| name_and_number[:number].to_i }
  end
  
end
