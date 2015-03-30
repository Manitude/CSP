# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::MulticallTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @api_communicator = mock
    @base = stub(:api_communicator => @api_communicator, :multicall_communicator => stub(:queued_calls => []))
  end

  def test_multicall_takes_a_base
    assert multicall = Multicall.new(:base => @base)
    assert_equal @base, multicall.base
  end

  def test_creating_a_request_and_response_handler_without_a_base_raises_an_argument_error
    assert_raises(ArgumentError) { Multicall.new }
  end

  def test_multicall_always_switches_multicall_mode_off_even_after_exception
    # breaking Singleton temporarily.
    ls = RosettaStone::ActiveLicensing::Base.send :new
    RosettaStone::ActiveLicensing::Multicall.any_instance.expects(:call).raises(Exception)
    assert_raises(Exception) { ls.multicall {} }
    ls.api_communicator.expects(:api_call).returns(nil)
    ls.api_call('bababooey', 'bababooey', {})
    assert_equal false, ls.instance_variable_get(:'@multicalling')
  end

  def test_splitting_xml_response
    @multicall = Multicall.new(:base => @base)
    xml = %q[<response license_server_version="1.0">
    <message type="success">Requests processed</message>
    <calls rolled_back="false">
      <call raised_exception="false">
        <product_rights>
          <product_right product_identifier="DEU" product_version="2">
            <active>false</active>
            <usable>false</usable>
            <created_at>1074091259</created_at>
            <ends_at>1105574400</ends_at>
            <demo>false</demo>
          </product_right>
        </product_rights>
      </call>
      <call raised_exception="false">
        <product_rights>
          <product_right product_identifier="DEU" product_version="2">
            <active>false</active>
            <usable>false</usable>
            <created_at>1074091259</created_at>
            <ends_at>1105574400</ends_at>
            <demo>false</demo>
          </product_right>
        </product_rights>
      </call>
    </calls>
    </response>]

    xml_array = @multicall.send(:split_xml, REXML::Document.new(xml))
    assert_equal 2, xml_array.size
    [
      '<response>\s*<product_rights>\s*<product_right.*</product_right>\s*</product_rights>\s*</response>',
      '<active>false</active>',
      '<usable>false</usable>',
      '<demo>false</demo>',
      '<created_at>1074091259</created_at>',
      '<ends_at>1105574400</ends_at>',
      %q(<product_right .*product_identifier=["']DEU["'].*>),
      %q(<product_right .*product_version=["']2["'].*>),
    ].each do |pattern|
      xml_array.each do |split_response|
        assert_match(%r(#{pattern})m, split_response)
      end
    end
  end

  def test_handle_multicall_response_will_call_the_appropriate_request_and_response_handlers
    @multicall = Multicall.new(:base => @base)

    calls = [{:api_category => 'license', :method_name => 'product_rights', :params => {:license => 'ms'}}]

    xml = %q[<response license_server_version="1.0">
    <message type="success">Requests processed</message>
    <calls rolled_back="false">
      <call raised_exception="false">
        <product_rights>
          <product_right product_identifier="DEU" product_version="2">
            <active>false</active>
            <usable>false</usable>
            <created_at>1074091259</created_at>
            <ends_at>1105574400</ends_at>
            <demo>false</demo>
          </product_right>
        </product_rights>
      </call>
    </calls>
    </response>]
    license_mock = mock
    license_mock.expects(:handle_response).with('product_rights', @multicall.send(:split_xml, REXML::Document.new(xml)).first).returns({:awesome => true})

    request_and_response_handler_mock = mock
    request_and_response_handler_mock.expects(:[]).with('license').returns(license_mock)
    @base.expects(:request_and_response_handlers).at_least(1).returns(request_and_response_handler_mock)

    @multicall.send(:handle_multicall_response, calls, xml)
  end

  def test_handle_multicall_response_will_raise_a_call_exception_wrapping_the_original_exception
    @multicall = Multicall.new(:base => @base)

    @multicall.expects(:split_xml).raises(LicenseServerException)
    assert_raises(CallException) { @multicall.send(:handle_multicall_response, [], 'xml') }
  end

  def test_handle_blank_multicall_response
    multicall = Multicall.new(:base => @base)
    exception = assert_raises(RosettaStone::ActiveLicensing::CallException) do
      multicall.send(:handle_multicall_response, [], '')
    end
    assert_true(exception.original_exception.is_a?(RosettaStone::ActiveLicensing::BlankResponseException))
  end

  def test_xml_parse_exception_on_multicall_response
    multicall = Multicall.new(:base => @base)
    exception = assert_raises(RosettaStone::ActiveLicensing::CallException) do
      multicall.send(:handle_multicall_response, [], 'not blank but not valid xml either <  />')
    end
    assert_true(exception.original_exception.is_a?(RosettaStone::ActiveLicensing::LicenseServerException))
  end

  def test_handling_top_level_ls_api_exception_on_multicall_response
    multicall_parse_exception_response = %Q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
        <exception type="multicall_parse_exception">An error occurred while processing this request: Badly formatted XML was posted.</exception>
      </response>
    ].strip
    multicall = Multicall.new(:base => @base)
    exception = assert_raises(RosettaStone::ActiveLicensing::CallException) do
      multicall.send(:handle_multicall_response, [], multicall_parse_exception_response)
    end
    assert_true(exception.original_exception.is_a?(RosettaStone::ActiveLicensing::MulticallParseException))
  end
end
