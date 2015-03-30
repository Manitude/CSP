# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::BaseTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_base_is_a_singleton
    ls2 = RosettaStone::ActiveLicensing::Base.instance
    assert_equal ls2.object_id, @ls.object_id
  end

  def test_with_credentials_sets_credentials_on_communicators
    new_user, new_pass = 'word', 'up'
    original_credentials = @ls.api_communicator.credentials
    assert_not_equal new_user, original_credentials[:username]
    assert_not_equal new_pass, original_credentials[:password]

    # Should change the credentials to the new ones
    @ls.api_communicator.expects(:set_credentials).with(new_user, new_pass)
    @ls.multicall_communicator.expects(:set_credentials).with(new_user, new_pass)

    @ls.with_credentials(new_user, new_pass) do
      # Should set the credentials back afterwards
      @ls.api_communicator.expects(:set_credentials).with(original_credentials[:username], original_credentials[:password])
      @ls.multicall_communicator.expects(:set_credentials).with(original_credentials[:username], original_credentials[:password])
    end
  end

  def test_new_cannot_be_called_on_base
    assert_raises(NoMethodError) { RosettaStone::ActiveLicensing::Base.new }
  end

  def test_base_returns_a_license_when_license_is_called
    assert_kind_of(RosettaStone::ActiveLicensing::License, @ls.license)
  end

  def test_base_returns_a_creation_account_when_creation_account_is_called
    assert_kind_of(RosettaStone::ActiveLicensing::CreationAccount, @ls.creation_account)
  end

  def test_base_raises_a_no_method_error_when_something_wack_is_called
    assert_raises(NoMethodError) { @ls.something_wack }
  end

  def test_base_has_an_api_communicator
    assert_kind_of(ApiCommunicator, @ls.api_communicator)
  end

  def test_base_caches_its_request_and_response_handlers
    lic = @ls.license
    assert_equal lic, @ls.license
  end

  def test_base_loads_its_settings_from_a_yaml_file
    dev_host = YAML::load(File.read(File.join(Framework.root, 'config', 'active_licensing.yml')))['development']['host']
    assert_equal dev_host, @ls.settings['development']['host']
  end
end
