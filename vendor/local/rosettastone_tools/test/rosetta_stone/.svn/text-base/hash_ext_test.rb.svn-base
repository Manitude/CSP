# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::HashExtensionsTest < Test::Unit::TestCase

  def test_map_to_hash_using_inversion
    example_hash = {'one' => 1, 'two' => 2}
    assert_equal(example_hash.invert, example_hash.map_to_hash {|k,v| {v => k}})
  end

  def test_deep_copy
    deep_hash = {'one' => {'two' => 2}}
    copy_hash = deep_hash.deep_copy
    assert_equal(deep_hash, copy_hash)
    deep_hash['one']['two'] = 3
    assert_not_equal(deep_hash, copy_hash)
    assert_equal(2, copy_hash['one']['two'])
  end

  def test_deep_freeze
    h = {:one => {:two => 2}}.deep_freeze

    assert_raises(expected_error_on_modifying_frozen_hash) do
      h[:two] = 2
    end

    assert_raises(expected_error_on_modifying_frozen_hash) do
      h[:one][:x] = 0
    end
  end

  def test_harvest_values
    assert_equal [1,2,3,6], {'a' => 1, :a => 2, 'oh' => {'a' => 3, 'b' => 4, 'ohk' => {'h' => 5, :a => 6}, 'j' => {'k' => 9 } }}.harvest_values(:a).sort
    assert_equal [], {'a' => 1, :a => 2, 'oh' => {'a' => 3, 'b' => 4, 'ohk' => {'h' => 5, :a => 6} }}.harvest_values(:booka)
  end

  def test_deep_flatten
    assert_equal({"1.3.4"=>"B", "1.2"=>"A"}, {"1"=>{"2"=>"A", "3"=>{"4"=>"B"}}}.deep_flatten('.'))
    assert_equal({"one.three.four"=>"B", "one.two"=>"A"}, {:one => {:two =>"A", :three => {:four => "B"}}}.deep_flatten('.'))
  end

  def test_filter_parameters
    ssp = example_server_side_params.filter_parameters(:session_id, :meeee)
    assert_equal("[FILTERED]", ssp['server_side_parameters']['session_info']['launch_params']['session_id'])
    assert_equal("[FILTERED]", ssp['server_side_parameters']['fake_arr'].first['catch']['meeee'])
  end

  def test_filter_parameters_treats_keys_case_insensitively
    ssp = {'FLTlicensePass' => 'hi'}.filter_parameters('fltlicensepass')
    assert_equal("[FILTERED]", ssp['FLTlicensePass'])
  end

  def test_hashes_respond_to_compact
    assert_true({}.respond_to?(:compact))
    assert_true({}.with_indifferent_access.respond_to?(:compact))
  end

  def test_compact
    assert_equal({}, {}.compact)
    assert_equal({}, {:one => nil}.compact)
    assert_equal({:one => true}, {:one => true, :two => nil, :three => nil}.compact)
  end

  def test_compact_retains_with_indifference
    results = {:one => true}.with_indifferent_access.compact
    assert_true(results.has_key?('one'))
  end

private
  def example_server_side_params
    {
      "server_side_parameters" => {
        "level_of_trust" => "internal_rails_app",
        "session_info" => {
          "launch_params" => {
            "application_exit_callback" => "rsm_helper.application_shutdown",
            "session_id" => "A7010608f2c97db776c5b7dc153a913e",
            "app_version" => "rsm",
            "data_service_url" => "http=>//viper-test-nonsal1.rosettastoneenterprise.com=>80/",
            "mcode_key" => "",
            "FLTBrand" => "rosettastone",
            "host_type" => "rs",
            "enterprise_license_identifier" => "CE=>=>viper-test-nonsal1"
          }
        },
        "client_now" => 1316033058561,
        "request_info" => {
          "remote_ip" => "127.0.0.1",
          "http_accept_language" => "en-us",
          "user_agent" => "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET4.0C; .NET CLR 2.0.50727; .NET4.0E)"
        },
        "received_at" => 1316033058561,
        "fake_arr" => [{"catch" => {"meeee" => "here"}}]
      }
    }
  end

  def expected_error_on_modifying_frozen_hash
    RUBY_VERSION.match(/^1\.9\./) ? RuntimeError : TypeError
  end

end
