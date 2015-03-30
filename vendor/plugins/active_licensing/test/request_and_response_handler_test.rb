# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::RequestAndResponseHandlerTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @api_communicator = mock()
    @base = stub(:api_communicator => @api_communicator)
    @request_and_response_handler = RequestAndResponseHandler.new(:base => @base)
  end

  def test_creating_a_request_and_response_handler_without_an_api_communicator_raises_an_argument_error
    assert_raises(ArgumentError) { RequestAndResponseHandler.new }
  end

  def test_unknown_methods_should_call_handle_response_and_call_api_call_on_the_api_communicator
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns(true)
    @request_and_response_handler.expects(:handle_response).with("something_wack", true).at_least(1).returns(true)

    assert @request_and_response_handler.something_wack
  end

  def test_handle_response_raises_when_response_body_is_blank
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns(nil)
    assert_raises(RosettaStone::ActiveLicensing::BlankResponseException) do
      assert_nil @request_and_response_handler.something_wack
    end
  end

  def test_handle_response_will_call_handle_exception_when_the_xml_contains_an_exception
    xml = %q[<response license_server_version="1.0"><exception type="license_not_found">An error occurred during processing this request.</exception></response>]
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns(xml)
    @request_and_response_handler.expects(:handle_exception).at_least(1).returns(nil)
    @request_and_response_handler.something_wack
  end

  def test_handle_exception_will_throw_an_exception_based_on_the_hash
    xml = %q[<response license_server_version="1.0"><exception type="license_not_found">An error occurred during processing this request.</exception></response>]
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::LicenseNotFound) { @request_and_response_handler.something_wack }
  end

  def test_handle_response_will_call_the_appropriate_response_handling_method_if_it_is_defined
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns("<hello></hello>")
    @request_and_response_handler.expects(:respond_to?).at_least(1).with(:handle_something_wack).returns(true)

    @request_and_response_handler.expects(:handle_something_wack).at_least(1).returns(true)
    assert @request_and_response_handler.something_wack
  end

  def test_handle_response_will_call_default_response_handler_if_no_custom_handler_is_found
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns("<hello></hello>")
    @request_and_response_handler.expects(:respond_to?).at_least(1).with(:handle_something_wack).returns(false)

    @request_and_response_handler.expects(:default_response_handler).at_least(1).returns(true)
    assert @request_and_response_handler.something_wack
  end

  def test_handle_message_returns_true_if_message_type_is_success
    assert @request_and_response_handler.send(:handle_message, { 'type'=> 'success'})
  end

  def test_handle_message_returns_false_if_message_type_is_not_success
    assert !@request_and_response_handler.send(:handle_message, { 'type'=> 'barf'})
  end

  def test_api_category
    assert_equal expected_api_category, @request_and_response_handler.send(:api_category)
  end

  def test_default_response_handler_calls_handle_message_if_there_is_a_message_attribute
    xml = %Q[<response license_server_version="1.0"><message type="success">License created</message></response>]
    @request_and_response_handler.expects(:handle_message).with({'type' => 'success', 'content' => 'License created'}).returns true

    assert @request_and_response_handler.send(:default_response_handler, "something_wack", ParsedResponseHash.from_xml(xml))
  end

  def test_default_response_handler_raises_exception_if_there_is_no_message_attribute
    assert_raises(LicenseServerException) { @request_and_response_handler.send(:default_response_handler, "something_wack", ParsedResponseHash.from_xml("<hello></hello>")) }
  end

  def test_calling_handle_in_the_class_adds_an_instance_method_by_that_same_name
    pr = Proc.new {|resp| resp}
    RequestAndResponseHandler.send(:handle, :jerk, &pr)
    assert_nothing_raised { @request_and_response_handler.handle_jerk("") }
  end

  def test_invalid_response_from_license_server_raises_invalid_response_xml
    xml = %q[<response>Invalid Response</response>]
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns(xml)

    # Defining the exception constant
    exception_type = "invalid_response_xml"
    RosettaStone::ActiveLicensing.const_set(exception_type.classify, Class.new(LicenseServerException)) unless RosettaStone::ActiveLicensing.const_defined?(exception_type.classify)

    assert_raise(RosettaStone::ActiveLicensing::InvalidResponseXml) { @request_and_response_handler.something_wack }
  end

  def test_valid_response_does_not_raise_invalid_response_xml
    valid_response = %Q[<response license_server_version="1.0"><message type="success">License created</message></response>]
    @base.expects(:api_call).with(expected_api_category, "something_wack", nil).at_least(1).returns(valid_response)
    assert_nothing_raised { @request_and_response_handler.something_wack }
  end

  def test_invalid_method_definition_options_raises_an_exception
    assert_raises(ArgumentError) do
      Class.new(RequestAndResponseHandler) do
        handle(:broken, :not_an_option => true) do |respose|
        end
      end
    end
  end

private
  def expected_api_category
    "request_and_response_handler"
  end

end
