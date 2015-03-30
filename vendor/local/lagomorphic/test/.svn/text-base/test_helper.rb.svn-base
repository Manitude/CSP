ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../../../config/environment', File.dirname(__FILE__)) unless defined?(RAILS_ROOT)

class ActiveSupport::TestCase
  # note: some test helper methods that are intended to be used by tests outside of this plugin
  # are included from ../lib/rabbit/test_unit_ext.rb

  def with_test_user
    global_item_prefix = (App.name rescue rand(1000)).to_s + '_lagomorphic_test_'
    user, password, vhost = "#{global_item_prefix}user", "test", "#{global_item_prefix}vhost"
    Rabbit::Helpers.add_vhost!(vhost)
    Rabbit::Helpers.add_user!(user, password)
    yield user, vhost
  ensure
    Rabbit::Helpers.delete_user!(user)
    Rabbit::Helpers.delete_vhost!(vhost)
  end

  def reload_with_yaml_data(yaml_data)
    YAML.expects(:load_file).returns(yaml_data).at_least_once # mocha.  hilarious.  good call peter.
    reload_rabbit_config!
  end

  def reload_rabbit_config!
    load(File.join(File.dirname(__FILE__), '..', 'lib', 'rabbit', 'config.rb')) # ruby.  hilarious.  good call rob.
  end

end