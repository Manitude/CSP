require 'yaml'
require 'socket'

module RosettaStone
  class InstanceDetection
    include Singleton
    attr_reader :known_instances_configuration

    def initialize
      @known_instances_configuration = load_known_instances
      build_convenience_methods
    end

    def instance_name
      known_instances.each do |instance_name,hosts|
        return instance_name if instance_is?(instance_name)
      end

      if known_instances_configuration[:fallthrough]
        return "[#{hostname}] (could be #{known_instances_configuration[:fallthrough]})"
      else
        return "[#{hostname}]"
      end
    end

    def instance_is?(instance_name)
      known_instances[instance_name].any?{|known| known.is_a?(String) ? hostname == known : hostname.match(known)}
    rescue NoMethodError
      raise ArgumentError, "No instance called '#{instance_name}' has been defined." if known_instances[instance_name].nil?
    end

    def hostname
      Socket.gethostname
    end

    def unknown?
      known_instances.each do |instance_name,hosts|
        return false if instance_is?(instance_name)
      end

      return true
    end

    def self.method_missing(method_name, *args, &block)
      instance.send(method_name, *args, &block)
    rescue NoMethodError => e
      if method_name.to_s =~ /(.*)\?$/
        raise RuntimeError, "No instance called '#{$1}' has been defined."
      else
        raise e
      end
    end

  private

    def load_known_instances
      known_instances_file_paths.each do |file_path|
        if File.exist?(file_path)
          config = YAML.load_file(file_path).with_indifferent_access
          return config
        end
      end

      raise RuntimeError, "No suitable known_instances.yml file could be found."
    end

    def known_instances
      known_instances_configuration.except(:fallthrough)
    end

    def known_instances_file_paths
      [
        File.join(Rails.root, 'config', 'known_instances.yml'),
        File.join(File.dirname(__FILE__), '..', 'known_instances.yml'),
      ]
    end

    def build_convenience_methods
      known_instances.each do |instance_name,hosts|
        singleton_class.send(:define_method, "#{instance_name}?") { instance_is?(instance_name) }
      end
    end

  end
end
