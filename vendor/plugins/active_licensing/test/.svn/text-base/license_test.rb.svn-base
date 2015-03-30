# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::LicenseTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_license_returns_array_of_product_right_hashes_if_product_rights_are_returned_in_xml
    xml = %Q[
    <response license_server_version="1.0">
    <product_rights>
      <product_right product_identifier="AEN" product_version="2" product_family="application">
        <active>true</active>
        <usable>true</usable>
        <ends_at>#{t = Time.now.to_i}</ends_at>
      </product_right>
    </product_rights>
    </response>]

    opts = {:license => "some_license"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'product_rights', opts).at_least(1).returns(xml)

    assert_equal [{"product_version"=>"2", "usable"=>true, "product_identifier"=>"AEN", "product_family" => "application", "ends_at"=> Time.at(t), "active"=>true, "content_ranges"=>["all"]}], @ls.license.product_rights(opts)
  end

  def test_license_returns_array_of_content_ranges_if_content_ranges_are_returned_in_xml
    xml = %Q[
    <response license_server_version="1.0">
    <product_rights>
      <product_right product_identifier="AEN" product_version="2" product_family="application">
        <active>true</active>
        <usable>true</usable>
        <ends_at>#{t = Time.now.to_i}</ends_at>
        <content_ranges coalesced="true">
          <content_range>
            <min_unit>1</min_unit>
            <max_unit>4</max_unit>
          </content_range>
          <content_range>
            <min_unit>5</min_unit>
            <max_unit>9</max_unit>
          </content_range>
        </content_ranges>
      </product_right>
    </product_rights>
    </response>]

    opts = {:license => "some_license"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'product_rights', opts).at_least(1).returns(xml)

    assert_equal [{"max_unit"=>"4", "min_unit"=>"1"}, {"max_unit"=>"9", "min_unit"=>"5"}], @ls.license.product_rights(opts).first['content_ranges']
  end


  def test_license_returns_empty_array_of_product_right_hashes_if_product_rights_are_not_returned_in_xml
    xml = %Q[
    <response license_server_version="1.0">
    <product_rights>
    </product_rights>
    </response>]

    opts = {:license => "some_license"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'product_rights', opts).at_least(1).returns(xml)

    assert_equal [], @ls.license.product_rights(opts)
  end

  # note, this looks like it's the same as the test above but apparently it's parsed differently
  # this one hits the "rescue []" instead of the "|| []"
  def test_license_returns_empty_array_of_product_right_hashes_if_product_rights_are_empty
    xml = %Q[
    <response license_server_version="1.0">
    <product_rights></product_rights>
    </response>]

    opts = {:license => "some_license"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'product_rights', opts).at_least(1).returns(xml)

    assert_equal [], @ls.license.product_rights(opts)
  end

  def test_license_returns_empty_array_if_product_rights_node_contains_no_children
    xml = %q[<response license_server_version="1.0"><product_rights></product_rights></response>]

    opts = {:license => "some_license"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'product_rights', opts).at_least(1).returns(xml)

    assert_equal [], @ls.license.product_rights(opts)
  end

  def test_license_raises_exception_when_appropriate_even_if_custom_handler_defined
    xml = %q[<response license_server_version="1.0"><exception type="license_not_found">An error occurred during processing this request.</exception></response>]

    opts = {:license => "some_non_existent_license"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'product_rights', opts).at_least(1).returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::LicenseNotFound) { @ls.license.product_rights(opts) }
  end

  def test_product_rights_with_authentication
    xml = %Q[
      <response license_server_version="1.0">
      <authentication>true</authentication>
      <in_authentication_lockout>false</in_authentication_lockout>
      <license>
        <identifier>osub_license</identifier>
        <guid>dc10c20d-65ea-4dc1-96b4-0e17ee29a2e0</guid>
        <test>false</test>
        <demo>false</demo>
        <active>true</active>
        <usable>true</usable>
        <created_at>1318441390</created_at>
        <creation_account_identifier>OSUBs</creation_account_identifier>
        <creation_account_guid>626a32d1-c56b-40cb-9c3d-1b2805296156</creation_account_guid>
      </license>
      <product_rights>
      <product_right product_version="2" product_family="application" product_identifier="ENG">
        <usable>true</usable>
        <created_at>1318441390</created_at>
        <activation_id></activation_id>
        <guid>14a880aa-7702-44a7-b8ef-64f052801ba1</guid>
        <starts_at>1318441390</starts_at>
        <ends_at>1318614190</ends_at>
        <unextended_ends_at>1318614190</unextended_ends_at>
        <license>
          <identifier>osub_license</identifier>
          <guid>dc10c20d-65ea-4dc1-96b4-0e17ee29a2e0</guid>
        </license>
      <content_ranges coalesced="false">
        <content_range>
          <min_unit>1</min_unit>
          <max_unit>4</max_unit>
          <guid></guid>
          <activation_id></activation_id>
        </content_range>
      </content_ranges>
      </product_right>
      <product_right product_version="2" product_family="application" product_identifier="ESP">
        <usable>true</usable>
        <created_at>1318441390</created_at>
        <activation_id></activation_id>
        <guid>14a880aa-7702-44a7-b8ef-64f052801ba2</guid>
        <starts_at>1318441390</starts_at>
        <ends_at>1318614190</ends_at>
        <unextended_ends_at>1318614190</unextended_ends_at>
        <license>
          <identifier>osub_license</identifier>
          <guid>dc10c20d-65ea-4dc1-96b4-0e17ee29a2e0</guid>
        </license>
      <content_ranges coalesced="false">
        <content_range>
          <min_unit>5</min_unit>
          <max_unit>8</max_unit>
          <guid></guid>
          <activation_id></activation_id>
        </content_range>
      </content_ranges>
      </product_right>
      </product_rights>
      </response>
      ]
      opts = {:license => "some_license"}
      ApiCommunicator.any_instance.expects(:api_post).with('license', 'product_rights_with_authentication', opts).at_least(1).returns(xml)
      prwa = @ls.license.product_rights_with_authentication(opts)
      eng_right = prwa['product_rights'].detect{|a| a['product_identifier'] == "ENG" }
      esp_right = prwa['product_rights'].detect{|a| a['product_identifier'] == "ESP" }
      assert_equal '1', eng_right['content_ranges'].first["min_unit"]
      assert_equal '4', eng_right['content_ranges'].first["max_unit"]

      assert_equal '5', esp_right['content_ranges'].first["min_unit"]
      assert_equal '8', esp_right['content_ranges'].first["max_unit"]
  end

  def test_details
    xml = %Q[<response license_server_version="1.0">
      <license>
        <identifier>ms</identifier>
        <test>false</test>
        <active>true</active>
        <usable>true</usable>
        <created_at>1039558683</created_at>
        <creation_account_identifier>OSUBs</creation_account_identifier>
      </license>
    </response>]

    opts = {:license => "ms"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'details', opts).at_least(1).returns(xml)

    details = @ls.license.details(opts)
    assert_equal({"usable"=> true, "creation_account_identifier"=>"OSUBs", "test"=> false, "identifier"=>"ms", "created_at"=> Time.at(1039558683), "active"=> true}, details)
  end

  def test_details_with_weird_response_tells_us_about_the_weirdness_when_it_raises
    xml = %Q[<response license_server_version="1.0">
      <something_weird>
        <license>
          <identifier>ms</identifier>
          <test>false</test>
          <active>true</active>
          <usable>true</usable>
          <created_at>1039558683</created_at>
          <creation_account_identifier>OSUBs</creation_account_identifier>
        </license>
      </something_weird>
    </response>]

    opts = {:license => "ms"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'details', opts).at_least(1).returns(xml)

    assert_raise_with_message(RuntimeError, /Error parsing response from ls_api.details/) do
      details = @ls.license.details(opts)
    end
  end

  def test_case_insensitive_details
    opts = {:identifier => "zkt-d_1551_ENG-LA-3M_01242007_0311"}
    xml = %q[<response license_server_version="1.0">
      <licenses>
        <license>
          <usable>true</usable>
          <test>false</test>
          <identifier>zkt-d_1551_ENG-LA-3M_01242007_0311</identifier>
          <created_at>1169604552</created_at>
          <active>true</active>
        </license>
      </licenses>
    </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'case_insensitive_details', opts).at_least(1).returns(xml)

    assert_equal [{"usable"=>true, "test"=>false, "identifier"=>"zkt-d_1551_ENG-LA-3M_01242007_0311", "created_at"=> Time.at(1169604552), "active"=> true }], @ls.license.case_insensitive_details(opts)
  end

  def test_api_category
    assert_equal "license", @ls.license.send(:api_category)
  end

  def test_authenticate_with_with_no_options_raises_parameters_exception
    opts = {}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'authenticate_with', opts).never

    assert_raises(RosettaStone::ActiveLicensing::ParametersException) { @ls.license.authenticate_with(opts) }
  end


  def test_authenticate_with_success_when_provided_auth_token
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate_with_token', {:token => faux_token}).once.returns(successful_authentication_response)
    assert @ls.license.authenticate_with({:token => faux_token})["authentication"]
  end

  def test_authenticate_with_failure_when_provided_with_broken_token
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate_with_token', {:token => faux_token}).once.returns(broken_token_response)
    assert_raises(RosettaStone::ActiveLicensing::BrokenTokenException) { @ls.license.authenticate_with({:token => faux_token})["authentication"] }
  end

  def test_authenticate_with_uses_auth_token_when_provided_with_lots_of_options
    opts = {:guid => 'fake-guid', :password => 'pass', :token => faux_token, :originating_ip_address => '123.456.789.012'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate_with_token', {:token => faux_token, :originating_ip_address => '123.456.789.012'}).once.returns(successful_authentication_response)

    assert @ls.license.authenticate_with(opts)["authentication"]
  end

  def test_authenticate_with_success_when_provided_with_guid_and_password
    opts = {:guid => 'fake-guid', :password => 'pass', :originating_ip_address => '127.0.0.1'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate', opts).once.returns(successful_authentication_response)

    assert_equal(true, @ls.license.authenticate_with(opts)["authentication"])
  end

  def test_authenticate_with_success_when_provided_with_license_name_and_password
    opts = {:license => 'ms', :password => 'pass', :originating_ip_address => '66.23.15.255'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate', opts).once.returns(successful_authentication_response)

    assert_equal(true, @ls.license.authenticate_with(opts)["authentication"])
  end

  def test_authenticate_with_with_blank_password_does_not_raise_exception
    opts = {:license => 'ms', :password => '', :originating_ip_address => '127.0.0.1'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate', opts).once.returns(successful_authentication_response)

    assert_equal(true, @ls.license.authenticate_with(opts)["authentication"])
  end

  def test_authenticate_with_prioritizes_guid_over_license
    opts = {:license => 'ms', :guid => 'fake-guid', :password => 'pass'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate', {:guid => 'fake-guid', :password => 'pass'}).once.returns(successful_authentication_response)

    assert_equal(true, @ls.license.authenticate_with(opts)["authentication"])
  end

  def test_authenticate_with_success_when_provided_only_password
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate_with_token', {:token => faux_token}).once.returns(successful_authentication_response)

    assert @ls.license.authenticate_with({:password => faux_token})["authentication"]
  end

  def test_authenticate_success
    opts = {:license => 'ms', :password => 'pass'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate', opts).once.returns(successful_authentication_response)

    assert_equal(true, @ls.license.authenticate(opts)["authentication"])
  end

  def test_authenticate_failure
    opts = {:license => 'ms', :password => 'pass'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate', opts).once.returns(failed_authentication_response)

    assert_equal(false, @ls.license.authenticate(opts)["authentication"])
  end

  def test_authenticate_with_token_success
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate_with_token', {:token => faux_token}).once.returns(successful_authentication_response)

    assert @ls.license.authenticate_with_token({:token => faux_token})["authentication"]
  end

  def test_authenticate_with_token_failure
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate_with_token', {:token => faux_token}).once.returns(failed_authentication_response)

    assert_equal(false, @ls.license.authenticate_with_token({:token => faux_token})["authentication"])
  end

  def test_authenticate_with_token_bad_token
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'authenticate_with_token', {:token => faux_token}).once.returns(broken_token_response)

    assert_raises(RosettaStone::ActiveLicensing::BrokenTokenException) { @ls.license.authenticate_with_token({:token => faux_token})["authentication"] }
  end

  def test_get_token
    xml = %Q[<response license_server_version="1.0">59</response>]
    opts = {:guid => 'some-fake-guid'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'get_token', opts).once.returns(xml)

    response = @ls.license.get_token(opts)
    assert_equal('59', response['token'])
    assert_equal('59', response[:token])
  end

    def test_get_token_with_whitespace_padding_in_the_response
    xml = %Q[
      <response license_server_version="1.0">
        59
      </response>
    ]
    opts = {:guid => 'some-fake-guid'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'get_token', opts).once.returns(xml)

    response = @ls.license.get_token(opts)
    assert_equal('59', response['token'])
  end

  def test_get_token_with_blank_token_data_in_response
    xml = %Q[<response license_server_version="1.0"></response>]
    opts = {:guid => 'some-fake-guid'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'get_token', opts).once.returns(xml)

    response = @ls.license.get_token(opts)
    assert_equal('', response['token'])
  end

  def test_get_token_for_license_that_does_not_exist_fails
    xml = %Q[<response license_server_version="1.0">
    <exception type="license_not_found">An error occurred while processing this request</exception>
    </response>]
    opts = {:guid => 'some-fake-guid'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'get_token', opts).once.returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::LicenseNotFound) { @ls.license.get_token(opts) }
  end

  def test_get_token_for_license_identifier_fails
    xml = %Q[<response license_server_version="1.0">
    <exception type="parameters_exception">Missing required parameters.</exception>
    <required_parameters>
      <parameter>guid</parameter>
    </required_parameters>
    </response>
    ]
    opts = {:license => 'ms'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'get_token', opts).once.returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::ParametersException) { @ls.license.get_token(opts) }
  end

  def test_exists
    xml = %Q[<response license_server_version="1.0">
    <exists>true</exists>
    </response>]
    opts = {:license => 'ms'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'exists', opts).once.returns(xml)

    assert @ls.license.exists(opts)
  end

  def test_start_session
    xml = %Q[<response license_server_version="1.0">
    <session_key>98bd5f74b49370dff94e8f94b56b35075058ce3d</session_key>
    </response>]
    opts = {:license => 'ms'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'start_session', opts).once.returns(xml)

    assert_equal '98bd5f74b49370dff94e8f94b56b35075058ce3d', @ls.license.start_session(opts)
  end

  def test_session_exists
    xml = %Q[<response license_server_version="1.0">
    <exists>true</exists>
    </response>]
    opts = {:session_key => '98bd5f74b49370dff94e8f94b56b35075058ce3d'}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'session_exists', opts).once.returns(xml)

    assert @ls.license.session_exists(opts)
  end

  def test_previous_identifiers_with_no_previous_identifiers
    xml = %Q[<response license_server_version="1.0">
      <license identifier="original_identifier@hotmail.com"></license>
    </response>]

    opts = {:identifier => "lauraworkdent@hotmail.com"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'previous_identifiers', opts).once.returns(xml)

    previous_identifiers = @ls.license.previous_identifiers(opts)
    assert_equal({:previous_identifier=> [], :identifier=>"original_identifier@hotmail.com"}, previous_identifiers)
  end

  def test_previous_identifiers_with_one_previous_identifiers
    xml = %Q[<response license_server_version="1.0">
      <license identifier="original_identifier@hotmail.com">
        <previous_identifier>previous_identifier@hotmail.com</previous_identifier>
      </license>
    </response>]

    opts = {:identifier => "lauraworkdent@hotmail.com"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'previous_identifiers', opts).once.returns(xml)

    previous_identifiers = @ls.license.previous_identifiers(opts)
    assert_equal({:previous_identifier=> ["previous_identifier@hotmail.com"], :identifier=>"original_identifier@hotmail.com"}, previous_identifiers)
  end

  def test_previous_identifiers_with_two_previous_identifiers
    xml = %Q[<response license_server_version="1.0">
      <license identifier="original_identifier@hotmail.com">
        <previous_identifier>previous_identifier@hotmail.com</previous_identifier>
        <previous_identifier>previousto_previous_identifier@hotmail.com</previous_identifier>
      </license>
    </response>]

    opts = {:identifier => "lauraworkdent@hotmail.com"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'previous_identifiers', opts).once.returns(xml)

    previous_identifiers = @ls.license.previous_identifiers(opts)
    assert_equal({:previous_identifier=> ["previous_identifier@hotmail.com", "previousto_previous_identifier@hotmail.com"], :identifier=>"original_identifier@hotmail.com"}, previous_identifiers)
  end

  def test_allocations
    xml = allocations_response

    opts = {:guid => "5a44741f-49d2-4944-a6ab-3cedb44c1264"}
    ApiCommunicator.any_instance.expects(:api_call).with('license', 'allocations', opts).once.returns(xml)

    allocations = @ls.license.allocations(opts)
    assert_equal 3, allocations.size
    assert_true RosettaStone::UUIDHelper.looks_like_guid?(allocations[0][:product_pool][:guid])
  end

  def test_change_password_uses_an_http_post
    params = {:guid => 'whatever', :password => 'new_password'}
    ApiCommunicator.any_instance.expects(:api_post).with('license', 'change_password', params).once.returns(%Q[
      <response license_server_version="1.0">
        <message type="success">License updated: (password change)</message>
      </response>
    ].strip)

    assert_true @ls.license.change_password(params)
  end

private
  def successful_authentication_response
    %Q[<response license_server_version="1.0">
      <authentication>true</authentication>
      <license_identifier>osub_license</license_identifier>
      <guid>6ad437e8-f267-491a-90ff-2848c18355b6</guid>
      <active>true</active>
      </response>]
  end

  def failed_authentication_response
    %Q[<response license_server_version="1.0">
        <authentication>false</authentication>
        <license_identifier></license_identifier>
        <guid></guid>
        </response>]
  end

  def broken_token_response
    %Q[<response license_server_version="1.0">
         <exception type="broken_token_exception">An error occurred while processing this request</exception>
       </response>]
  end

  def faux_token
    %Q[1213]
  end

  def allocations_response
    %Q[<response license_server_version="1.0">
<allocations type="array">
  <allocation>
    <guid>2cca9cf8-3f35-424c-a71e-d2e00246c8b5</guid>
    <product_pool>
      <guid>1dbc9985-158d-4a94-933e-08be3f030db8</guid>
    </product_pool>
    <license>
      <guid>5a44741f-49d2-4944-a6ab-3cedb44c1264</guid>
      <identifier>adjust_ends_at</identifier>
    </license>
    <product_configuration>
      <access_ends_at type="integer">1402424575</access_ends_at>
      <languages type="array">
        <language>FRA</language>
      </languages>
    </product_configuration>
  </allocation>
  <allocation>
    <guid>b1b40da8-767f-414f-9cf3-0770e93de86a</guid>
    <product_pool>
      <guid>88f7aaec-3b7f-4388-afe8-ef2f6f5869be</guid>
    </product_pool>
    <license>
      <guid>5a44741f-49d2-4944-a6ab-3cedb44c1264</guid>
      <identifier>adjust_ends_at</identifier>
    </license>
    <product_configuration>
      <duration>6m</duration>
      <languages type="array">
        <language>ITA</language>
      </languages>
    </product_configuration>
  </allocation>
  <allocation>
    <guid>0f73a636-00c1-4b04-a455-4428ff1a5398</guid>
    <product_pool>
      <guid>1dbc9985-158d-4a94-933e-08be3f030db8</guid>
    </product_pool>
    <license>
      <guid>5a44741f-49d2-4944-a6ab-3cedb44c1264</guid>
      <identifier>adjust_ends_at</identifier>
    </license>
    <product_configuration>
      <access_ends_at type="integer">1402424575</access_ends_at>
      <languages type="array">
        <language>ENG</language>
      </languages>
    </product_configuration>
  </allocation>
</allocations>
</response>]
  end
end
