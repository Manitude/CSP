# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::ExtensionTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_extension_details
    opts = {:guid => 'NECU-LPFS-TNDI-MXYT'}
    xml = %Q[<response license_server_version="1.0">
          <extension>
            <guid>ccb85e97-a451-43ac-94c1-b267022bd6ed</guid>
            <claim_by>1267737321</claim_by>
            <duration>30d</duration>
            <extendable_guid>abcdef89-a451-43ac-94c1-b267022bd6ed</extendable_guid>
            <extendable_type>ProductRight</extendable_type>
            <extended_at></extended_at>
            <created_at>1267737321</created_at>
            <activation_id>234567734567876555</activation_id>
          </extension>
        </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'details', opts).returns(xml)

    ext = @ls.extension.details(opts)
    assert_equal({"guid"=>"ccb85e97-a451-43ac-94c1-b267022bd6ed",
                  "extended_at"=> nil,
                  "claim_by"=>Time.at(1267737321),
                  "activation_id"=>"234567734567876555",
                  "duration"=>"30d",
                  "extendable_guid"=>"abcdef89-a451-43ac-94c1-b267022bd6ed",
                  "extendable_type"=>"ProductRight",
                  "created_at"=>Time.at(1267737321)}, ext)
  end

  def test_extension_detail_failure
    opts = {:guid => 'notgood'}
    xml = %Q[<response license_server_version="1.0">
                <exception type="extension_not_found_exception">An error occurred while processing this request</exception>
              </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'details', opts).returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::ExtensionNotFoundException) do
      ext = @ls.extension.details(opts)
    end
  end

  def test_extension_add_with_good_extendable_guid
    guid = 'eels'
    extendable_guid = 'extendable_eels'
    opts = {:extendable_guid => extendable_guid, :extendable_type => "ProductRight", :duration => '3m', :claim_by => 1.day.from_now.to_i }
    xml = %Q[<response license_server_version="1.0">
               <message type="success">Extension added</message>
                 <extension>
                   <guid>#{guid}</guid>
                 </extension>
             </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'add', opts).returns(xml)

    ext = @ls.extension.add(opts)
    assert_equal ext['guid'], guid
  end


  def test_extension_add_with_bad_parameters
    guid = 'eels'
    opts = {:booka_extendable_type => "ProductRight", :duration => '3m', :claim_by => 1.day.from_now.to_i }
    xml = %Q[<response license_server_version=\"1.0\">
      <exception type="parameters_exception">Missing required parameters.</exception>
      <required_parameters>
        <parameter>extendable_guid</parameter>
        <parameter>extendable_type</parameter>
        <parameter>duration</parameter>
        <parameter>claim_by</parameter>
      </required_parameters>
      </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'add', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ParametersException) do
      ext = @ls.extension.add(opts)
    end
  end

  def test_extension_add_with_bad_extendable_guid
    bad_guid = 'eels'
    opts = {:extendable_guid => bad_guid, :extendable_type => "ProductRight", :duration => '3m', :claim_by => 1.day.from_now.to_i }
    xml = %Q[<response license_server_version="1.0">
      <exception type="extendable_not_found_exception">An error occurred while processing this request</exception>
      </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'add', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ExtendableNotFoundException) do
      ext = @ls.extension.add(opts)
    end
  end

  def test_extension_remove_by_guid
    guid = 'eels'
    opts = {:guid => guid }
    xml = %Q[<response license_server_version="1.0">
       <message type="success">Extension removed</message>
       </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'remove_by_guid', opts).returns(xml)

    ext = @ls.extension.remove_by_guid(opts)
    assert_equal ext['message']['type'], 'success'
  end

  def test_extension_removed_by_invalid_guid
    opts = {:guid => "BOOKA"}
    xml = %Q[<response license_server_version="1.0">
        <exception type="extension_not_found_exception">An error occurred while processing this request</exception>
      </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'remove_by_guid', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ExtensionNotFoundException) do
      ext = @ls.extension.remove_by_guid(opts)
    end
  end

  def test_burned_between
    opts = {:burned_after => 1.day.ago, :burned_before => Time.now}
    xml = %Q[<?xml version="1.0" encoding="UTF-8"?>
    <response license_server_version="1.0">
    <extensions>
      <extension>somethinguniquerightreally</extension>
    </extensions>
    </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'burned_between', opts).returns(xml)
    ext = @ls.extension.burned_between(opts)
    assert_equal ext['extensions']['extension'], 'somethinguniquerightreally'
  end

  def test_burned_between_with_bad_parameters
    opts = {:nothing_good => 'can come of this'}
    xml = %Q[<?xml version="1.0" encoding="UTF-8"?>
    <response license_server_version="1.0">
    <exception type="parameters_exception">Missing required parameters.</exception>
    <required_parameters>
      <parameter>burned_after</parameter>
      <parameter>burned_before</parameter>
    </required_parameters>
    </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'burned_between', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ParametersException) do
      ext = @ls.extension.burned_between(opts)
    end
  end


  def test_burn_all_by_activation_id_without_extending
    opts = {:activation_id => "valid_activation_id"}
    xml = %Q[<?xml version="1.0" encoding="UTF-8"?>
    <response license_server_version="1.0">
    <extensions>
      <extension>somethinguniquerightreally</extension>
    </extensions>
    </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'burn_all_by_activation_id_without_extending', opts).returns(xml)
    ext = @ls.extension.burn_all_by_activation_id_without_extending(opts)
    assert_equal ext['extensions']['extension'], 'somethinguniquerightreally'
  end

  def test_burn_all_by_activation_id_without_extending_with_bad_parameters
    opts = {:bad_id => "im_supposed_to_be_invalid"}
    xml = %Q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
        <exception type="parameters_exception">An error occurred while processing this request.</exception>
      </response>
    ]
    ApiCommunicator.any_instance.expects(:api_call).with('extension', 'burn_all_by_activation_id_without_extending', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ParametersException) do
      @ls.extension.burn_all_by_activation_id_without_extending(opts)
    end
  end
end
