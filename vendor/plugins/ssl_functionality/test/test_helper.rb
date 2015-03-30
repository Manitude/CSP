ENV['RAILS_ENV'] = 'test'
require File.dirname(__FILE__) + '/../../../../config/environment.rb' unless defined?(RAILS_ROOT)
# for integration tests:
require 'action_controller/integration' if defined?(ActionController)

class Test::Unit::TestCase

  def fake_settings!(options = {})
    clear_cached_settings!
    class_list.each do |class_to_stub|    
      class_to_stub.stubs(:settings).returns(fake_settings(options))
    end
  end
  alias_method :no_settings!, :fake_settings!

  def fake_settings(options = {})
    return nil if options.empty?
    return default_settings.merge(options)
  end

  def default_settings!
    fake_settings!(default_settings)
  end

  def default_settings
    {
      :enable_ssl => true,
      :http_port => 3000,
      :https_port => 3443,
    }
  end

  # this devil
  def clear_cached_settings!
    class_list.each do |class_to_clear|
      %w(instance_supports_ssl http_port https_port).each do |class_variable|
        class_to_clear.instance_variable_set("@#{class_variable}", nil)
      end
    end
  end

  def class_list
    [RosettaStone::SslFunctionality, RosettaStone::ForceSsl, RosettaStone::ForceNonSsl]
  end
end