# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))
require 'license_server_interface'
require 'oracle_mimic_time'

class LicenseServerInterfaceTest < Test::Unit::TestCase

  def setup
    @license = mock("license")
    @ls = stub("license_server", :license => @license)

    @lsi = LicenseServerInterface.new
    @lsi.stubs(:license_server).returns(@ls)
    def @ls.multicall(&block)
      instance_eval(&block)
    end
  end

  def test_authenticate_should_return_true
    license = 'valid'
    password = 'valid'
    @license.expects(:authenticate).with(:license => license, :password => password).returns(true)
    assert_equal(true, @lsi.authenticate(license, password))
  end

  def test_authenticate_should_return_false
    license = 'invalid'
    password = 'invalid'
    @license.expects(:authenticate).with(:license => license, :password => password).returns(false)
    assert_equal(false, @lsi.authenticate(license, password))
  end

  def test_product_rights_for_existant_license_should_be_awesome
    @lsi.stubs(:license_exists?).returns(false)
    assert @lsi.product_rights('nonexistantlicense').nil?
  end

  def test_product_rights_for_nonexistant_license_should_not_be_awesome
    license = 'existant'
    return_hash = 'whatever'
    @lsi.stubs(:license_exists?).returns(true)
    @license.expects(:product_rights).with(:license => license).returns(return_hash)
    assert_equal(@lsi.product_rights(license), return_hash)
  end

  def test_create_osub_with_no_product_rights_and_license_exists
    @lsi.stubs(:license_exists?).returns(true)
    @license.expects(:change_password)
    @license.expects(:add).never
    @lsi.create_osub_with_no_product_rights("license_name", "license_password")
  end

  def test_create_osub_with_no_product_rights_and_license_doesnt_exist
    @lsi.stubs(:license_exists?).returns(false)
    @license.expects(:change_password).never
    @license.expects(:add)
    @lsi.create_osub_with_no_product_rights("license_name", "license_password")
  end

  def test_license_exists_should_return_true_when_license_exists
    good_license = "good"
    @license.expects(:exists).with(:license => good_license).returns(true)
    assert @lsi.license_exists?(good_license)
  end

  def test_license_exists_should_return_false_when_license_does_not_exist
    bad_license = "bad"
    @license.expects(:exists).with(:license => bad_license).returns(false)
    assert !@lsi.license_exists?(bad_license)
  end

  def test_create_osub_with_license_exist
    @lsi.stubs(:license_exists?).returns(true)
    @license.expects(:change_password)
    @license.expects(:add).never

    # empty array of items means we're not testing the actual adding of product rights
    @lsi.create_osub("license_name", "license_password", [])
  end

  def test_create_osub_with_license_doesnt_exist
    @lsi.stubs(:license_exists?).returns(false)
    @license.expects(:change_password).never
    @license.expects(:add)

    # empty array of items means we're not testing the actual adding of product rights
    @lsi.create_osub("license_name", "license_password", [])
  end

  def test_create_osub_adding_product_right
    @lsi.stubs(:license_exists?).returns(false)
    @license.stubs(:add)
    osub1 = mock("osub 3 month", :language_code => "ARA", :app_version  => "3", :duration_code => "3")
    osub2 = mock("osub 9 month", :language_code => "ARA", :app_version  => "3", :duration_code => "9")
    items = [osub1, osub2]
    @license.expects(:add_or_extend_product_right).times(items.size)

    @lsi.create_osub("license_name", "license_password", items)
  end

  def test_reset_password
    license_name = "foobar"
    password = "barfoo"
    @license.expects(:change_password).with(:license => license_name, :password => password)
    @lsi.reset_password(license_name, password)
  end

end
