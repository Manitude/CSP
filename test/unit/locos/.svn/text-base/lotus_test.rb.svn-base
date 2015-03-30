require File.expand_path('../../../test_helper', __FILE__)

class LotusTest < ActiveSupport::TestCase

  def test_locos_rescuer_rescues_with_na_in_case_of_exception
    rescuer_rescues = Locos::Lotus.send :within_locos_rescuer do raise Exception end
    assert_nil(rescuer_rescues)
  end

  def test_locos_rescuer_yields_block_in_case_of_no_exception
    rescuer_yields = Locos::Lotus.send :within_locos_rescuer do return 'a_proper_return_value' end
    assert_equal 'a_proper_return_value', rescuer_yields
  end

  def test_locos_rescuer_rescues_with_na_in_case_of_a_non_200_response
    response_obj = SimpleHTTP::Client::Response.new(:body => "something", :message => "Internal Server Error", :code=>"500")
    SimpleHTTP::Client.any_instance.stubs(:get).returns(response_obj)
    assert_nil(Locos::Lotus.find_active_session_details_by_activity)
  end

end
