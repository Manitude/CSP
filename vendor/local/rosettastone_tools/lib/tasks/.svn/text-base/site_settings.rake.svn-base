namespace :site_settings do
  desc 'compare your site_settings.yml with site_settings.yml.sample to see what you are missing'
  task :compare => :environment do
    sample_data = YAML::load_file(File.join(Rails.root, 'config', 'site_settings.yml.sample'))
    your_data = YAML::load_file(File.join(Rails.root, 'config', 'site_settings.yml'))
    all_real_keys = sample_data.keys - ['key_used_for_testing_that_should_be_in_sample_but_not_in_real_site_settings_file']
    keys_only_in_sample_file = all_real_keys - your_data.keys
    
    puts "============Here are the settings in your file that are different from the sample file:"
    all_real_keys.sort.each do |key|
      if your_data[key] && (sample_data[key] != your_data[key])
        puts "for #{key}: yours is '#{your_data[key]}' and sample is '#{sample_data[key]}'"
      end
    end
    
    if keys_only_in_sample_file.any?
      puts "============Here are the settings in the sample file that are not in your file:"
      keys_only_in_sample_file.each do |key|
        puts "#{key}: #{sample_data[key]}"
      end
    end
    keys_only_in_your_file = your_data.keys - sample_data.keys
    if keys_only_in_your_file.any?
      puts "============Here are the settings in your file that are not in the sample file:"
      keys_only_in_your_file.each do |key|
        puts "#{key}: #{your_data[key]}"
      end
    end
    
    if keys_only_in_sample_file.empty? && keys_only_in_your_file.empty?
      puts "\nLooks like you are all up to date\n\n"
    end
  end
end