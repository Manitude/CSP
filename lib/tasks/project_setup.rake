def is_sample_file?(file)
  file.match(/sample/).present?
end

def defaults_file?(file)
  file.match(/defaults/).present?
end


def create_config_file(config_directory_path, sample_files, default_files)
  sample_files.each do |file|
    actual_file_name = file.gsub('.yml.sample', '.yml')
    actual_file_path = "#{config_directory_path}/#{actual_file_name}"
    copy_local_file(file, config_directory_path, actual_file_path, actual_file_name)
  end
  default_files.each do |file|
    actual_file_name = file.sub('.defaults.yml', '.yml')
    actual_file_path = "#{config_directory_path}/#{actual_file_name}"
    copy_local_file(file, config_directory_path, actual_file_path, actual_file_name)
  end
end

def copy_local_file(file, config_directory_path, actual_file_path, actual_file_name)
  unless File.exist?(actual_file_path)
    FileUtils::cp("#{config_directory_path}/#{file}", actual_file_path)
    puts "#{actual_file_name} has been copied"
  end
end


namespace :project do

  task :check_for_required_files do
    config_directory_path = "#{Rails.root}/config"
    config_directory = Dir.open(config_directory_path)
    sample_files = []
    default_files = []
    config_directory.each do |file|
      if is_sample_file?(file)
        sample_files << file
      elsif defaults_file?(file)
        default_files << file
      end
    end

    create_config_file(config_directory_path, sample_files, default_files)

  end

  task :check_invalid_users => :environment do
    accounts = Account.find(:all)
    accounts.each do |account|
      begin
        groups = RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.groups_for account.user_name
        if groups.size != 1
          puts "for user #{account.user_name}, there are #{groups.size} group(s) and he is #{account.type} in our system"
        else
          unless AdGroup.all_groups.keys.include? account.class.to_s.underscore
            puts "#{account.user_name} belongs to a different groups than what is in database."
          end
        end
      rescue
        puts "there is a problem for user #{account.user_name} and he is #{account.type} in our system"
      end
    end
  end

end
