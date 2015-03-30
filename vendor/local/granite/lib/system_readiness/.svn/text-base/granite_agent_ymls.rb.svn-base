# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

class SystemReadiness::GraniteAgentYmls < SystemReadiness::Base
  class << self
    def verify
      default_config_path = Framework.root.join("config/granite_agents.defaults.yml")
      overridden_config_path = Framework.root.join("config/granite_agents.yml")
      return true, '' unless File.exists?(overridden_config_path)
      default_config = YAML::load_file(default_config_path)
      overridden_config = YAML::load_file(overridden_config_path)

      default_config.each_pair do |key, value|
        if overridden_config.has_key?(key)
          if value.is_a?(Hash)
            missing_keys = default_config[key].keys - overridden_config[key].keys
            unlisted_keys = overridden_config[key].keys - default_config[key].keys
            if missing_keys.length > 0
              return false, "The following keys are listed in the granite_agents.defaults.yml config file, but aren't listed in the granite_agents.yml file.  You should at least add these agents to the granite_agents.yml file, even if their value is 0.  Missing agents: #{missing_keys.join(",")}"
            end
            if unlisted_keys.length > 0
              return false, "The following keys are listed in the granite_agents.yml config file, but aren't listed in the granite_agents.default.yml file.  You should probably remove these from the granite_agents.yml file.  Unlisted agents: #{unlisted_keys.join(",")}"
            end
          end
        end
      end
      return true, ''
    end
  end
end
