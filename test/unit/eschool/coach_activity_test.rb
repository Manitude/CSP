require File.expand_path('../../../test_helper', __FILE__)

class EschoolCoachActivityTest < ActiveSupport::TestCase

  def test_coach_activity_report_when_there_is_a_connection_error
    Eschool::CoachActivity.stubs(:post).raises(ActiveResource::ResourceNotFound.new('some error'))
    assert_nil Eschool::CoachActivity.activity_report_for_coaches([],'','',[])
  end

  def test_coach_activity_report_returns_empty_arry
    Net::HTTPOK.any_instance.expects(:body).returns('[]')
    sample_response_obj = Net::HTTPOK.new('1', '1', 'hello')
    Net::HTTPOK.any_instance.expects(:response).returns(sample_response_obj)
    api_response = Net::HTTPOK.new('1', '1', 'hello')
    Eschool::CoachActivity.expects(:post).returns(api_response)
    ids = []
    lang_identifier = ['ARA']
    start_date = Time.now - 1.months
    end_date = Time.now + 1.months
    sessions = Eschool::CoachActivity.activity_report_for_coaches(ids,start_date,end_date,lang_identifier)
    assert_equal sessions , []
  end


  def test_coach_activity_report_sample_scenario
    Net::HTTPOK.any_instance.expects(:body).returns('[]')
    sample_response_obj = Net::HTTPOK.new('1', '1', 'hello')
    Net::HTTPOK.any_instance.expects(:response).returns(sample_response_obj)
    api_response = Net::HTTPOK.new('1', '1', 'hello')
    Eschool::CoachActivity.expects(:post).returns(api_response)
    ids = [12,9]
    lang_identifier = ['ARA']
    start_date = '2012-01-01 00:00:00'
    end_date = '2018-01-01 00:00:00'
    Thread.current[:user_details] = 'TEST32'
    sessions = Eschool::CoachActivity.activity_report_for_coaches(ids,start_date,end_date,lang_identifier)
    assert_equal 'TEST32', Eschool::CoachActivity.headers['X-CSP-Audit']
  end

  def test_should_not_send_nil_header_to_eschool
    response = nil
    begin
        response = Eschool::CoachActivity.activity_report_for_coaches([1,2,3],'2012-01-11 12:12:12', '2012-02-11 12:12:12', ['ARA'])
    rescue Exception => e
        assert_false e.message === "can't convert nil into Hash", "calls to eschool not going through properly"
    end
  end

end
