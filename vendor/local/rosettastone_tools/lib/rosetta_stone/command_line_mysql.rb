# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

# class to help with spitting out mysql command line arguments, especially for rake tasks.
module RosettaStone
  class CommandLineMysql

    class << self

      def get_parameters(database_config_name)
        if !ActiveRecord::Base.configurations.has_key?(database_config_name)
          raise ArgumentError, "Invalid connection '#{database_config_name}' provided"
        end

        config_hash = ActiveRecord::Base.configurations[database_config_name]
        get_parameters_by_config_hash(config_hash)
      end

      # this is called at least in migration 55 in the License Server, and therefore shouldn't be made private
      def get_parameters_by_config_hash(config)
        config = config.with_indifferent_access
        params = " -h #{config['host']} -u#{config['username']} #{config["database"]}"
        params << " -p\"#{shell_escape(config['password'])}\"" if !config['password'].blank?
        params << " -P#{config['port']}" if config['port']
        params << " -S#{config['socket']}" if config['socket']
        config['encoding'] ||= 'utf8'
        params << " --default-character-set=#{config['encoding']}"
        params
      end

      def shell_escape(str)
        str ? str.gsub(/([\"\$\\])/, '\\\\\1') : ""
      end

    end

  end
end
