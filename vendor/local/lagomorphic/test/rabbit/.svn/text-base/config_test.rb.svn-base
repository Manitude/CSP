require File.expand_path('../test_helper', File.dirname(__FILE__))

class Rabbit::ConfigTest < ActiveSupport::TestCase

  def setup
    reload_rabbit_config!
  end

  def teardown
    reload_rabbit_config! # just being safe.
  end

  test 'defaults' do
    reload_with_yaml_data({'test_1' => {}})
    assert_not_nil(config = Rabbit::Config['test_1'])
    Rabbit::Config.default_values.keys.each do |key|
      assert_not_nil(config.send(key))
    end
  end

  test 'indifferent access of all configurations' do
    reload_with_yaml_data({'test_2' => {}})
    assert_not_nil(Rabbit::Config['test_2'])
    assert_not_nil(Rabbit::Config[:test_2])
  end

  test 'accessing nonexistent configuration' do
    assert_nil(Rabbit::Config['this_will_never_exist'])
  end

  test 'overridden defaults' do
    reload_with_yaml_data({'test_3' => {'user' => 'overridden'}})
    assert_equal('overridden', Rabbit::Config['test_3'].user)
  end

  test 'default configuration' do
    assert_not_nil(Rabbit::Config.default_configuration)
  end

  test 'loading several configurations' do
    data = {'test_4' => {}, 'test_5' => {}}
    reload_with_yaml_data(data)
    data.keys.each do |key|
      assert_not_nil(Rabbit::Config[key])
    end
  end

  test 'default vhost name' do
    reload_with_yaml_data('test_6' => {})
    assert_equal("/#{Rabbit::Config.default_app_name}_test", Rabbit::Config['test_6'].vhost)
  end

  test 'stanza name' do
    reload_with_yaml_data('test_6' => {})
    assert_equal('test_6', Rabbit::Config['test_6'].name)
  end

  test 'configuration_hash without remap' do
    assert config_hash = Rabbit::Config.default_configuration.configuration_hash
    assert config_hash.is_a?(Hash)
    assert_true config_hash.all? { |k,v| k.is_a?(Symbol )}
    assert_not_nil(config_hash[:password])
    assert_nil(config_hash[:pass])
  end

  test 'configuration_hash with remap' do
    assert config_hash = Rabbit::Config.default_configuration.configuration_hash(true)
    assert config_hash.is_a?(Hash)
    assert_true config_hash.all? { |k,v| k.is_a?(Symbol )}
    assert_not_nil(config_hash[:pass])
    assert_nil(config_hash[:password])
  end

  test 'get with nil' do
    assert_equal(Rabbit::Config.default_configuration, Rabbit::Config.get)
    assert_equal(Rabbit::Config.default_configuration, Rabbit::Config.get(nil))
  end

  test 'get with Rabbit::Config object' do
    assert_equal(Rabbit::Config.default_configuration, Rabbit::Config.get(Rabbit::Config.default_configuration))
  end

  test 'get with connection name' do
    assert name = Rabbit::Config.default_configuration.name
    assert_equal(Rabbit::Config.default_configuration, Rabbit::Config.get(name))
  end
end