# -*- encoding : utf-8 -*-

class SystemReadiness::SyntaxOfYamlFiles < SystemReadiness::Base
  class << self
    def verify
      begin
        Dir.glob(File.join(Framework.root, 'config', '*.yml')).each do |yaml_file|
          @current_file = yaml_file
          if File.exist?(yaml_file)
            YAML::load(ERB.new(File.read(yaml_file)).result)
          else
            # the defaults for known_instances (in the plugin) are quite good. cap will generate the symlink, and if it links to nothing (and uses the defaults), it's great.
            next if yaml_file.include?('known_instances.yml')
            puts "warning\t\t#{yaml_file} appears to be a symlink to a nonexistent destination?"
          end
        end
        return true, nil
      rescue Exception => exception
        return false, "Failed parsing #{@current_file}: #{exception}"
      end
    end
  end
end
