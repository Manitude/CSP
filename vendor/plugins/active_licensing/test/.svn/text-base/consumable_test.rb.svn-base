# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::ConsumableTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_details
    req = {:guid => '5e2ca55f-f76c-4e21-9c4a-66941e14575f'}

    ApiCommunicator.any_instance.expects(:api_call).with('consumable', 'details', req).returns(sample_consumable_details_response)

    consumable = @ls.consumable.details(req)
    assert_equal '5e2ca55f-f76c-4e21-9c4a-66941e14575f', consumable['guid']
    assert_equal false, consumable['consumed']
    assert_equal Time.at(1443097233), consumable['expires_at']
  end

  def test_change_expires_at
    req = {:guid => '5e2ca55f-f76c-4e21-9c4a-66941e14575f', :expires_at => '1350529200'}

    ApiCommunicator.any_instance.expects(:api_call).with('consumable', 'change_expires_at', req).returns(sample_consumable_details_response(:expires_at => 1350529200))

    consumable = @ls.consumable.change_expires_at(req)
    assert_equal '5e2ca55f-f76c-4e21-9c4a-66941e14575f', consumable['guid']
    assert_equal false, consumable['consumed']
    assert_equal Time.at(1350529200), consumable['expires_at']
  end

  def test_add
    req = {:activation_id => '2744a79543769436df658b465f6d3055eb9a07832ae1b076/AMP',
      :pooler_type => 'ProductRight', :pooler_guid => '888b86dd-6937-40ca-8ba8-67cf6bc7f9c7',
      :expires_at => 1443097233, :remaining_rollover_count => nil}
    res = <<-MEH
<?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<message type="success">Consumable added</message>
<consumable>
  <guid>5e2ca55f-f76c-4e21-9c4a-66941e14575f</guid>
</consumable>
</response>
    MEH

    ApiCommunicator.any_instance.expects(:api_call).with('consumable', 'add', req).returns(res)
    added = @ls.consumable.add(req)
    assert_equal '5e2ca55f-f76c-4e21-9c4a-66941e14575f', added['guid']
  end

  def test_add_with_count_more_than_one_returns_array
    req = {:activation_id => '2744a79543769436df658b465f6d3055eb9a07832ae1b076/AMP',
      :pooler_type => 'ProductRight', :pooler_guid => '888b86dd-6937-40ca-8ba8-67cf6bc7f9c7',
      :expires_at => 1443097233, :remaining_rollover_count => nil, :count => 2}
    res = <<-MEH
<?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<message type="success">Consumables added</message>
<consumables>
  <consumable>
    <guid>00d41e1a-29a0-44e1-8bf7-f0d87e051486</guid>
  </consumable>
  <consumable>
    <guid>96683d22-bbf8-498e-bfbd-17806d9859fd</guid>
  </consumable>
</consumables>
</response>
    MEH

    ApiCommunicator.any_instance.expects(:api_call).with('consumable', 'add', req).returns(res)
    added = @ls.consumable.add(req)
    assert_equal 2, added.size
    assert_equal '96683d22-bbf8-498e-bfbd-17806d9859fd', added[1]['guid']
  end

private

  def sample_consumable_details_response(options = {})
    options[:expires_at] ||= 1443097233
    %Q[
<?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<consumable>
  <guid>5e2ca55f-f76c-4e21-9c4a-66941e14575f</guid>
  <pooler>
    <guid>888b86dd-6937-40ca-8ba8-67cf6bc7f9c7</guid>
    <type>ProductRight</type>
  </pooler>
  <created_at>1348595523</created_at>
  <activation_id>2744a79543769436df658b465f6d3055eb9a07832ae1b076/AMP</activation_id>
  <starts_at></starts_at>
  <expires_at>#{options[:expires_at]}</expires_at>
  <remaining_rollover_count></remaining_rollover_count>
  <consumed>false</consumed>
  <consumed_at></consumed_at>
  <usable>true</usable>
</consumable>
</response>
    ].strip
  end
end
