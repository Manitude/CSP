# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::ContentRangeTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_remove_all_by_activation_id
    opts = {:activation_id => "valid_activation_id"}
    xml = %Q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
      <content_ranges activation_id="valid_activation_id">
        <content_range>somethinguniquerightreally</content_range>
      </content_ranges>
      </response>
    ]
    ApiCommunicator.any_instance.expects(:api_call).with('content_range', 'remove_all_by_activation_id', opts).returns(xml)
    ext = @ls.content_ranges.remove_all_by_activation_id(opts)
    assert_equal ext['content_ranges']['content_range'], 'somethinguniquerightreally'
  end

  def test_remove_all_by_activation_id_with_empty_parameter
    opts = {:activation_id => ""}
    xml = %Q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
        <exception type="argument_error_exception">An error occurred while processing this request: activation_id should not be empty</exception>
      </response>
    ]
    ApiCommunicator.any_instance.expects(:api_call).with('content_range', 'remove_all_by_activation_id', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ArgumentErrorException) do
      @ls.content_ranges.remove_all_by_activation_id(opts)
    end
  end

  def test_remove_all_by_activation_id_with_bad_parameters
    opts = {:bad_id => "im_supposed_to_be_invalid"}
    xml = %Q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
        <exception type="parameters_exception">An error occurred while processing this request.</exception>
      </response>
    ]
    ApiCommunicator.any_instance.expects(:api_call).with('content_range', 'remove_all_by_activation_id', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ParametersException) do
      @ls.content_ranges.remove_all_by_activation_id(opts)
    end
  end

  def test_remove_all_by_activation_id_when_none_found
    opts = {:bad_id => "none_like_this"}
    xml = %Q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
        <exception type="content_range_not_found_exception">An error occurred while processing this request: Api::ContentRangeNotFoundException</exception>
      </response>
    ]
    ApiCommunicator.any_instance.expects(:api_call).with('content_range', 'remove_all_by_activation_id', opts).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ContentRangeNotFoundException) do
      @ls.content_ranges.remove_all_by_activation_id(opts)
    end
  end

  def test_details
    xml  = %Q[<response license_server_version="1.0">
               <content_range guid="somethinguniquerightreally3">
                <min_unit>1</min_unit>
                <max_unit>4</max_unit>
                <guid>somethinguniquerightreally3</guid>
                <activation_id>somethingfromthefnoserverpresumably</activation_id>
                <entitlement_type>ProductRight</entitlement_type>
                <entitlement_guid>29f8a1fd-864e-45cb-8e4d-230d9dbdbbc3</entitlement_guid>
                <created_at>1277319272</created_at>
                <updated_at>1277319272</updated_at>
               </content_range>
             </response>]

    opts = {:guid => "somethinguniquerightreally3"}
    ApiCommunicator.any_instance.expects(:api_call).with('content_range', 'details', opts).at_least(1).returns(xml)

    details       = @ls.content_range.details(opts)
    formatted_time = Time.at(1277319272)
    assert_equal({"min_unit"          => "1",
                  "max_unit"          => "4",
                  "guid"              => ["somethinguniquerightreally3", "somethinguniquerightreally3"],
                  "activation_id"     => "somethingfromthefnoserverpresumably",
                  "entitlement_type"  => "ProductRight",
                  "created_at"        => formatted_time,
                  "updated_at"        => formatted_time,
                  "entitlement_guid"  => "29f8a1fd-864e-45cb-8e4d-230d9dbdbbc3"},
                details)
  end

  def test_details_with_weird_response_tells_us_about_the_weirdness_when_it_raises
    xml = %Q[<response license_server_version="1.0">
                <something_weird>
                  <content_range guid="somethinguniquerightreally3">
                     <min_unit>1</min_unit>
                     <max_unit>4</max_unit>
                     <guid>somethinguniquerightreally3</guid>
                     <activation_id>somethingfromthefnoserverpresumably</activation_id>
                     <entitlement_type>ProductRight</entitlement_type>
                     <entitlement_guid>29f8a1fd-864e-45cb-8e4d-230d9dbdbbc3</entitlement_guid>
                     <created_at>1277319272</created_at>
                     <updated_at>1277319272</updated_at>
                  </content_range>
                </something_weird>
             </response>]

    opts = {:guid => "somethinguniquerightreally3"}
    ApiCommunicator.any_instance.expects(:api_call).with('content_range', 'details', opts).at_least(1).returns(xml)

    assert_raise_with_message(RuntimeError, /Error parsing response from ls_api.content_range.details/) do
      @ls.content_range.details(opts)
    end
  end

end
