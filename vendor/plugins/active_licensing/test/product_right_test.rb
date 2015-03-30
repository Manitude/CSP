# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::ProductRightTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_extensions
    activation_id = '44X7KX-EC4MB-M2XAY-7H8A9-YYYJFJM'
    claim_by    = 1393664371
    extended_at = 1299056400

    req  = {:guid => 'c3faf8e6-2a41-446c-a042-f23cd8f192c6'}
    resp = <<-BLAH
<?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<extensions>
  <extension guid="811c0586-a9f4-4fe4-b98a-4b3479c42d46">
    <created_at>1299056374</created_at>
    <extended_at>#{extended_at}</extended_at>
    <duration>1m</duration>
    <claim_by>#{claim_by}</claim_by>
    <activation_id>#{activation_id}</activation_id>
  </extension>
  <extension guid="2a5ae15a-672b-4d12-815d-357f73176568">
    <created_at>1299056374</created_at>
    <extended_at></extended_at>
    <duration>1m</duration>
    <claim_by>#{claim_by}</claim_by>
    <activation_id>#{activation_id}</activation_id>
  </extension>
  <extension guid="c40b5a0f-bdb3-4c7c-b0bb-5988adc7c8c1">
    <created_at>1299056374</created_at>
    <extended_at></extended_at>
    <duration>1m</duration>
    <claim_by>#{claim_by}</claim_by>
    <activation_id>#{activation_id}</activation_id>
  </extension>
</extensions>
</response>
    BLAH

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'extensions', req).returns(resp)

    extensions = @ls.product_right.extensions(req)
    assert_equal 3, extensions.size
    extensions.each do |extn|
      assert extn['guid']
      assert_equal Time.at(extended_at), extn['extended_at'] if extn['extended_at']
      assert_equal Time.at(claim_by), extn['claim_by']
      assert_equal activation_id, extn['activation_id']
      assert_equal '1m', extn['duration']
    end
  end

  def test_nothing
    assert true
  end

  def test_update_product_identifier_with_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = <<-BLAH
  <?xml version="1.0" encoding="UTF-8"?>
  <response license_server_version="1.0">
  <product_right product_identifier="#{req[:new_product_identifier]}" product_version="3" product_family="application">
    <usable>true</usable>
    <created_at>1337176516</created_at>
    <activation_id></activation_id>
    <guid>#{req[:guid]}</guid>
    <starts_at>1337176516</starts_at>
    <ends_at>1369144516</ends_at>
    <unextended_ends_at>1369144516</unextended_ends_at>
    <license>
      <identifier>test_osub_license</identifier>
      <guid>201b156a-09df-455d-8e68-dd9dd8266985</guid>
    </license>
  <content_ranges coalesced="false">
    <content_range>
      <min_unit>1</min_unit>
      <max_unit>12</max_unit>
      <guid></guid>
      <activation_id></activation_id>
      <created_at>0</created_at>
      <updated_at>0</updated_at>
    </content_range>
  </content_ranges>
  </product_right>
  </response>
    BLAH

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    changed_product_right =  @ls.product_right.update_product_identifier(req)
    assert_equal 1, changed_product_right.size
    changed_product_right.each do |changed_product_right_obj|
      assert_equal req[:guid], changed_product_right_obj["guid"]
      assert_equal req[:new_product_identifier], changed_product_right_obj["product_identifier"]
    end
  end

  def test_update_product_identifier_with_no_content_range_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = <<-BLAH
  <?xml version="1.0" encoding="UTF-8"?>
  <response license_server_version="1.0">
  <product_right product_identifier="#{req[:new_product_identifier]}" product_version="3" product_family="application">
    <usable>true</usable>
    <created_at>1337176516</created_at>
    <activation_id></activation_id>
    <guid>#{req[:guid]}</guid>
    <starts_at>1337176516</starts_at>
    <ends_at>1369144516</ends_at>
    <unextended_ends_at>1369144516</unextended_ends_at>
    <license>
      <identifier>test_osub_license</identifier>
      <guid>201b156a-09df-455d-8e68-dd9dd8266985</guid>
    </license>
  </product_right>
  </response>
    BLAH

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    changed_product_right =  @ls.product_right.update_product_identifier(req)
    assert_equal 1, changed_product_right.size
    changed_product_right.each do |changed_product_right_obj|
      assert_equal req[:guid], changed_product_right_obj["guid"]
      assert_equal req[:new_product_identifier], changed_product_right_obj["product_identifier"]
    end
  end

  def test_update_product_identifier_with_invalid_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = %Q[
    <response license_server_version="1.0">
    <product_rights></product_rights>
    </response>]

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    changed_product_right =  @ls.product_right.update_product_identifier(req)
    assert_equal [], changed_product_right
  end

  def test_update_product_identifier_with_product_right_not_found_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = %Q[  <?xml version="1.0" encoding="UTF-8"?>
                    <response license_server_version="1.0">
                    <exception type="product_right_not_found">An error occurred while processing this request: Api::ProductRightNotFound</exception>
                    </response> ]

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    assert_raise RosettaStone::ActiveLicensing::ProductRightNotFound do
      @ls.product_right.update_product_identifier(req)
    end
  end

  def test_update_product_identifier_with_product_not_found_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = %Q[  <?xml version="1.0" encoding="UTF-8"?>
                    <response license_server_version="1.0">
                    <exception type="product_not_found">An error occurred while processing this request: Api::ProductNotFound</exception>
                    </response>
    ]

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    assert_raise RosettaStone::ActiveLicensing::ProductNotFound do
      @ls.product_right.update_product_identifier(req)
    end
  end

  def test_update_product_identifier_with_preexisting_product_right_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = %Q[  <?xml version="1.0" encoding="UTF-8"?>
                    <response license_server_version="1.0">
                    <exception type="preexisting_product_right">An error occurred while processing this request: Api::PreexistingProductRight</exception>
                    </response> ]

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    assert_raise RosettaStone::ActiveLicensing::PreexistingProductRight do
      @ls.product_right.update_product_identifier(req)
    end
  end

  def test_update_product_identifier_with_available_product_not_found_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = %Q[  <?xml version="1.0" encoding="UTF-8"?>
                    <response license_server_version="1.0">
                    <exception type="available_product_not_found">An error occurred while processing this request: Api::AvailableProductNotFound</exception>
                    </response> ]

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    assert_raise RosettaStone::ActiveLicensing::AvailableProductNotFound do
      @ls.product_right.update_product_identifier(req)
    end
  end

  def test_update_product_identifier_with_unexpected_content_ranges_for_product_identifier_update_response

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = %Q[  <?xml version="1.0" encoding="UTF-8"?>
                    <response license_server_version="1.0">
                    <exception type="unexpected_content_ranges_for_product_identifier_update">An error occurred while processing this request: Api::UnexpectedContentRangesForProductIdentifierUpdate</exception>
                    </response> ]

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    assert_raise RosettaStone::ActiveLicensing::UnexpectedContentRangesForProductIdentifierUpdate do
      @ls.product_right.update_product_identifier(req)
    end
  end

  def test_update_product_identifier_when_not_online_subscription

    req = {:guid => "07849994-c40d-41f0-a5d6-7d194b4d15aa", :new_product_identifier => "EBR"}
    response = %Q[  <?xml version="1.0" encoding="UTF-8"?>
                    <response license_server_version="1.0">
                    <exception type="product_right_is_not_online_subscription">An error occurred while processing this request: Api::ProductRightIsNotOnlineSubscription</exception>
                    </response> ]

    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'update_product_identifier', req).returns(response)
    assert_raise RosettaStone::ActiveLicensing::ProductRightIsNotOnlineSubscription do
      @ls.product_right.update_product_identifier(req)
    end
  end

  def test_consumables_response
    req = {:product_right_guid => "888b86dd-6937-40ca-8ba8-67cf6bc7f9c7"}
    res = %Q[<?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<consumables>
<consumable>
  <guid>a5a03a74-0438-46db-a534-3304b3dfaa29</guid>
  <pooler>
    <guid>888b86dd-6937-40ca-8ba8-67cf6bc7f9c7</guid>
    <type>ProductRight</type>
  </pooler>
  <created_at>1348588917</created_at>
  <activation_id>87b9518d-58cf-4215-a28e-092ba1dbc3ff</activation_id>
  <starts_at></starts_at>
  <expires_at></expires_at>
  <remaining_rollover_count>3</remaining_rollover_count>
  <consumed>false</consumed>
  <consumed_at></consumed_at>
  <usable>true</usable>
</consumable>
<consumable>
  <guid>21b6500b-54f9-4a15-bc74-cdcbc10cf5fb</guid>
  <pooler>
    <guid>888b86dd-6937-40ca-8ba8-67cf6bc7f9c7</guid>
    <type>ProductRight</type>
  </pooler>
  <created_at>1348588917</created_at>
  <activation_id>87b9518d-58cf-4215-a28e-092ba1dbc3ff</activation_id>
  <starts_at></starts_at>
  <expires_at></expires_at>
  <remaining_rollover_count></remaining_rollover_count>
  <consumed>false</consumed>
  <consumed_at></consumed_at>
  <usable>true</usable>
</consumable>
<consumable>
  <guid>0c1377ff-fc62-4d35-9310-48b776b3bc71</guid>
  <pooler>
    <guid>888b86dd-6937-40ca-8ba8-67cf6bc7f9c7</guid>
    <type>ProductRight</type>
  </pooler>
  <created_at>1348588917</created_at>
  <activation_id>87b9518d-58cf-4215-a28e-092ba1dbc3ff</activation_id>
  <starts_at></starts_at>
  <expires_at></expires_at>
  <remaining_rollover_count></remaining_rollover_count>
  <consumed>false</consumed>
  <consumed_at></consumed_at>
  <usable>true</usable>
</consumable>
</consumables>
</response>]
    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'consumables', req).returns(res)
    consumables =  @ls.product_right.consumables(req)
    assert_equal 3, consumables.size
    assert_equal '888b86dd-6937-40ca-8ba8-67cf6bc7f9c7', consumables.first['pooler']['guid']
    assert_equal false, consumables.last['consumed']
  end

  def test_projected_consumables_parse_response_properly
    req = {:guid => "ce7cbb59-8c1a-4299-b5bc-e6cb25338428", :product => 'RUS', :version => '3', :family => "eschool_one_on_one_sessions"}
    response = %Q[
    <?xml version="1.0" encoding="UTF-8"?>
    <response license_server_version="1.0">
    <consumables>
      <consumable>
        <guid>a864972e-559c-4953-b01b-2d1302b524ed</guid>
        <starts_at>1345439234</starts_at>
        <expires_at>1345655234</expires_at>
      </consumable>
      <consumable>
        <guid>21b6500b-54f9-4a15-bc74-cdcbc10cf5fb</guid>
        <starts_at>1345439234</starts_at>
        <expires_at>1345655234</expires_at>
      </consumable>
      <consumable>
        <guid>fdc7992c-09bc-4063-ab3f-34af23e71515</guid>
        <starts_at>1345439234</starts_at>
        <expires_at>1345655234</expires_at>
      </consumable>
    </consumables>
    </response>
      ]
    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'projected_consumables', req).returns(response)
    consumables =  @ls.product_right.projected_consumables(req)
    consumables.each do |con|
      assert_equal 1345439234, con['starts_at'].to_i
      assert_equal 1345655234, con['expires_at'].to_i
    end
  end

  def test_projected_consumables_with_product_not_found_raises_properly
    req = {:guid => "ce7cbb59-8c1a-4299-b5bc-e6cb25338428", :product => 'RUS', :version => '3', :family => "nothing_valid"}
    response = %Q[
       <?xml version="1.0" encoding="UTF-8"?>
       <response license_server_version="1.0">
       <exception type="product_not_found">An error occurred while processing this request: Api::ProductNotFound</exception>
       </response>
       ]
    ApiCommunicator.any_instance.expects(:api_call).with('product_right', 'projected_consumables', req).returns(response)
    assert_raise RosettaStone::ActiveLicensing::ProductNotFound do
      consumables =  @ls.product_right.projected_consumables(req)
    end
  end

end
