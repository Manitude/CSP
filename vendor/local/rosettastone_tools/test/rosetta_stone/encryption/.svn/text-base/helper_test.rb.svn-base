# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::Encryption::HelperTest < Test::Unit::TestCase
  include RosettaStone::Encryption

  def setup
    mocha_setup # ensure mocha is ready, even for rspec apps
    mock_key_base_directory!
  end

  def teardown
    Helper.clear_key_file_cache!
    mocha_teardown # ensure mocha is cleaned up, even for rspec apps
  end

  [:public, :private].each do |key_type|
    define_test "getting default #{key_type} key in the common case" do
      assert_equal(actual_key_contents(key_type), Helper.send("#{key_type}_key"))
    end

    define_test "key caching for #{key_type} key" do
      expected_key = actual_key_contents(key_type)
      assert_equal(expected_key, Helper.send("#{key_type}_key"))
      File.expects(:read).never
      assert_equal(expected_key, Helper.send("#{key_type}_key"))
    end

    define_test "key caching for #{key_type} key normalizes symbols to strings" do
      expected_key = actual_key_contents(key_type)
      Helper.send("#{key_type}_key", :subdir_with_overrides)
      File.expects(:read).never
      Helper.send("#{key_type}_key", 'subdir_with_overrides') # should be cached, won't re-read the file
    end

    define_test "specifying subdirectory that does not exist falls back to config root directory for #{key_type} key" do
      assert key = Helper.send("#{key_type}_key", :does_not_exist)
      assert_equal(actual_key_contents(key_type), key)
    end

    define_test "fallback to .sample files in subdir for #{key_type}" do
      assert key = Helper.send("#{key_type}_key", :subdir_with_samples_only)
      assert_equal("subdir_with_samples_only_#{key_type}", key)
    end

    define_test "override files in subdir for #{key_type}" do
      assert key = Helper.send("#{key_type}_key", :subdir_with_overrides)
      assert_equal("subdir_with_overrides_overridden_#{key_type}", key)
    end

    define_test "what happens when there are no pem files anywhere in the config base directory for #{key_type}" do
      mock_key_base_directory!('this_surely_does_not_exist')
      assert_raises(RuntimeError) do
        Helper.send("#{key_type}_key")
      end
    end

  end

private

  def actual_key_contents(key_type = :private)
    # config_base_directory is mocked!
    File.read(File.join(Helper.config_base_directory, "rsa_encryption_#{key_type}_key.pem"))
  end
end
