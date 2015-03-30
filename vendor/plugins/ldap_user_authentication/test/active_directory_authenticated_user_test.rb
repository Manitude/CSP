require File.expand_path('test_helper', File.dirname(__FILE__))

class SampleUserImplementation < RosettaStone::ActiveDirectoryAuthenticatedUser
private
  def self.production_ad_group; '~RS Community Editors'; end
  def self.non_production_ad_group; '@RS Product Development'; end
end

class RosettaStone::ActiveDirectoryAuthenticatedUserTest < Test::Unit::TestCase
  # must have the following plugins in order plugin to run these tests:
  #  * ldap_user_authentication
  #  * what_instance_am_i
  def self.has_dependencies?
    !!defined?(RosettaStone::ProductionDetection) && !!defined?(RosettaStone::LDAPUserAuthentication)
  end

  if has_dependencies?
    def test_uses_security_group_when_on_production
      RosettaStone::ProductionDetection.expects(:could_be_on_production?).returns(true)
      assert group = SampleUserImplementation.send(:group_name)
      assert group.starts_with?('~')
    end

    def test_uses_distribution_list_when_not_on_production
      RosettaStone::ProductionDetection.expects(:could_be_on_production?).returns(false)
      assert group = SampleUserImplementation.send(:group_name)
      assert group.starts_with?('@')
    end

    def test_logs_successful_authentication
      SampleUserImplementation.stubs(:auto_authorized?).returns(false)
      RosettaStone::ProductionDetection.stubs(:could_be_on_production?).returns(false)
      RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.expects(:authenticate).once.returns(true)
      with_clean_log_file do
        assert_not_nil(SampleUserImplementation.authenticate('whatever', 'whatever'))
        assert_match('Successfully authenticated user', log_file_entries)
      end
    end

    def test_logs_failed_authentication
      SampleUserImplementation.stubs(:auto_authorized?).returns(false)
      RosettaStone::ProductionDetection.stubs(:could_be_on_production?).returns(false)
      RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.expects(:authenticate).once.returns(false)
      with_clean_log_file do
        assert_nil(SampleUserImplementation.authenticate('whatever', 'whatever'))
        assert_match('Failed to authenticate user', log_file_entries)
      end
    end

    def test_auto_authorize_value_is_cached
      Rails.expects(:test?).once.returns(true)
      # clear existing cache:
      SampleUserImplementation.instance_variable_set('@auto_authorized', nil)
      assert_true(SampleUserImplementation.send(:auto_authorized?))
      assert_true(SampleUserImplementation.instance_variable_get('@auto_authorized'))
      # try again and ensure that we don't ask Rails.test? again
      assert_true(SampleUserImplementation.send(:auto_authorized?))
    end

    def test_logs_when_auto_authorized
      SampleUserImplementation.expects(:auto_authorized?).at_least_once.returns(true)
      RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.expects(:authenticate).never
      with_clean_log_file do
        assert_not_nil(SampleUserImplementation.authenticate('whatever', 'whatever'))
        assert_match('Auto-authorization enabled', log_file_entries)
      end
    end

    def test_default_non_production_ad_group_when_config_is_nil
      mock_config(nil)
      assert_equal( '@RS NonProduction Editor Access', RosettaStone::ActiveDirectoryAuthenticatedUser.send(:non_production_ad_group))
    end

    def test_default_non_production_ad_group_when_role_mappings_is_nil
      mock_config({})
      assert_equal( '@RS NonProduction Editor Access', RosettaStone::ActiveDirectoryAuthenticatedUser.send(:non_production_ad_group))
    end

    def test_default_non_production_ad_group_when_role_mappings_is_not_nil_with_no_mappings
      mock_config(:role_mappings => {:non_production => {}})
      assert_equal( '@RS NonProduction Editor Access', RosettaStone::ActiveDirectoryAuthenticatedUser.send(:non_production_ad_group))
    end

    def test_correct_non_production_ad_group_for_apps_that_explicitly_configure_it_in_the_yaml_file
      configuration = RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.fetch_configuration
      if configuration[:role_mappings]
        group_name_or_nil = read_group_name_from_yaml_role_mappings_config(configuration[:role_mappings])
        assert_equal(group_name_or_nil, RosettaStone::ActiveDirectoryAuthenticatedUser.send(:non_production_ad_group))
      end
    end

    def test_correct_production_ad_group
      mock_config(:role_mappings => {:production => {:basic_access => 'dummy_string'}})
      RosettaStone::ActiveDirectoryAuthenticatedUser.expects(:production_security?).at_least_once.returns(true)
      assert_equal( 'dummy_string', RosettaStone::ActiveDirectoryAuthenticatedUser.send(:production_ad_group))
    end

    def test_error_on_production_ad_group_with_no_config
      mock_config({})
      assert_raises(RosettaStone::ActiveDirectoryAuthenticatedUser::MissingConfigException) do
        RosettaStone::ActiveDirectoryAuthenticatedUser.send(:production_ad_group)
      end
    end

    def test_correct_production_ad_group_for_apps_that_explicitly_configure_it_in_the_yaml_file
      configuration = RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.fetch_configuration
      if configuration[:role_mappings]
        RosettaStone::ActiveDirectoryAuthenticatedUser.expects(:production_security?).at_least_once.returns(true)
        group_name_or_nil = read_group_name_from_yaml_role_mappings_config(configuration[:role_mappings], :production)
        assert_equal(group_name_or_nil, RosettaStone::ActiveDirectoryAuthenticatedUser.send(:production_ad_group))
      end
    end

    def test_is_in_group_happy_path
      mock_auto_authorized(false)
      configuration = RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.fetch_configuration
      if configuration[:role_mappings]
        group_name_or_nil = read_group_name_from_yaml_role_mappings_config(configuration[:role_mappings])
        user_entry = mock('user_entry')
        RosettaStone::LDAPUserAuthentication::User.expects(:find_by_identifier).returns(user_entry)
        RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.expects(:user_in_group?).with(user_entry, group_name_or_nil).returns(true)
        assert_true(RosettaStone::ActiveDirectoryAuthenticatedUser.is_in_group?("this username", :basic_access))
      end
    end

    def test_is_in_group_no_user_entry
      mock_auto_authorized(false)
      RosettaStone::LDAPUserAuthentication::User.expects(:find_by_identifier).returns(nil)
      assert_raises(RosettaStone::ActiveDirectoryAuthenticatedUser::UserEntryNotFoundException) do
        RosettaStone::ActiveDirectoryAuthenticatedUser.is_in_group?("this username", :basic_access)
      end
    end

    def test_is_in_group_no_group_identifier
      mock_config(:role_mappings => {:non_production => {:not_correct_key => 'dummy'}})
      mock_auto_authorized(false)
      user_entry = mock('user_entry')
      RosettaStone::LDAPUserAuthentication::User.expects(:find_by_identifier).returns(user_entry)
      assert_raises(RosettaStone::ActiveDirectoryAuthenticatedUser::GroupIdentifierNotFoundException) do
        RosettaStone::ActiveDirectoryAuthenticatedUser.is_in_group?("this username", :basic_access)
      end
    end

    def test_is_in_group_when_auto_authorized
      mock_auto_authorized(true)
      assert_true(RosettaStone::ActiveDirectoryAuthenticatedUser.is_in_group?('super_admin', :super_admin))
      assert_false(RosettaStone::ActiveDirectoryAuthenticatedUser.is_in_group?('regular_joe', :super_admin))
    end

    def mock_config(config)
      RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.expects(:fetch_configuration).at_least_once.returns(config)
    end

    def mock_auto_authorized(auto_authorized = true)
      RosettaStone::ActiveDirectoryAuthenticatedUser.stubs(:auto_authorized?).returns(auto_authorized)
    end

  else
    def test_truth_to_make_rails_shut_up_about_having_no_tests
      assert_true(true)
    end
  end
  
  def read_group_name_from_yaml_role_mappings_config(role_mappings_config, instance_stanza = :non_production)
    useful_config = role_mappings_config[instance_stanza]
    assert_true useful_config.has_key?(:basic_access)
    useful_config[:basic_access]
  end
end
