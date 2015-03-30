require 'test_helper'

class EschoolSessionTest < ActiveSupport::TestCase

  test 'dashboard data api throws resource not found exception from eschool' do
    Eschool::Session.stubs(:find).raises(ActiveResource::ResourceNotFound.new('eschool throws resource not found exception'))
    response = Eschool::Session.dashboard_data('srajgopal', 100, 1, nil, nil, 'Advanced', 'All', nil, {}, false)
    assert_nil response
  end

  test 'dashboard data api with no exception from eschool' do
    session1 = Eschool::Session.new({"audio_device_status"=>"audio_input_device_unknown_device", "teacher_last_seen_at"=>nil, "teacher_first_seen_at"=>nil, "session"=>"Arabic - ARA Level 1 Unit 1: Sat, Feb 11, 2012 01:00 AM (EST)"})
    session2 = Eschool::Session.new({"audio_device_status"=>"audio_input_device_unknown_device", "teacher_last_seen_at"=>nil, "teacher_first_seen_at"=>nil, "session"=>"Arabic - ARA Level 1 Unit 1: Sat, Feb 11, 2012 01:00 AM (EST)"})
    sessions = mock("sessions")
    sessions.stubs(:eschool_sessions).returns([session1, session2])
    Eschool::Session.stubs(:find).returns(sessions)
    response = Eschool::Session.dashboard_data('srajgopal', 100, 1, nil, nil, 'Advanced', 'All', nil, {}, false)
    assert_equal(2, response.eschool_sessions.size)
  end

  def test_find_by_ids_returns_sessions
    xml_str = <<EOF
    <eschool_sessions type="array">
        <eschool_session>
          <eschool_session_id>1001</eschool_session_id>
          <language>ESP</language>
          <level>1</level>
          <unit>1</unit>
          <teacher>lballou</teacher>
          <teacher_id>600000043</teacher_id>
          <start_time time_zone="UTC">2009-11-16 21:00:00</start_time>
          <duration_in_seconds>3600</duration_in_seconds>
          <cancelled>false</cancelled>
          <number_of_seats>4</number_of_seats>
          <learners_signed_up>0</learners_signed_up>
          <students_attended>0</students_attended>
          <wildcard>false</wildcard>
          <wildcard_units></wildcard_units>
          <wildcard_locked>false</wildcard_locked>
          <teacher_confirmed>true</teacher_confirmed>
          <external_village_id></external_village_id>
          <teacher_arrived>false</teacher_arrived>
        </eschool_session>
      </eschool_sessions>
EOF
    xml = XML::Parser.string(xml_str).parse
    LibXML::XML::Document.any_instance.expects(:read_body).returns(xml_str)
    eschool_session = Eschool::Session.new
    Eschool::Session.expects(:post).returns(xml)
    EschoolResponseParser.any_instance.expects(:parse).returns(eschool_session)
    assert_true Eschool::Session.find_by_ids([1001]).instance_of? Eschool::Session
  end

  def test_find_by_ids_returns_empty_array_when_resource_not_found_raised
    Eschool::Session.expects(:post).raises(ActiveResource::ResourceNotFound)
    assert_nil Eschool::Session.find_by_ids([1001])
  end

  def test_find_by_ids_returns_empty_array_and_notifies_hoptoad_when_error_raised
    Eschool::Session.expects(:post).raises(Exception)
    HoptoadNotifier.expects(:notify).with(instance_of Exception)
    assert_nil Eschool::Session.find_by_ids([1001])
  end

  def test_default_find_by_ids_returns_empty_array_when_connection_refused
    Eschool::Session.expects(:post).raises(Errno::ECONNREFUSED)
    assert_nil Eschool::Session.find_by_ids([1001])
  end

  def test_find_by_ids_returns_connection_refused_error_when_handle_eschool_down_is_set
    Eschool::Session.expects(:post).raises(Errno::ECONNREFUSED)
    assert_true Eschool::Session.find_by_ids([1001], true)[:connection_refused]
  end
end
