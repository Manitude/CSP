require File.expand_path("../../test_helper", __FILE__)

class EschoolResponseParserTest < Test::Unit::TestCase

  def test_should_parse_xml
    xml = read_input_file(File.expand_path('../sample_response.xml', __FILE__))
    parser = EschoolResponseParser.new(xml)
    eschool_sessions = parser.parse()
    assert_equal 4, eschool_sessions.size
    eschool_session = eschool_sessions[0]
    assert_equal "160070", eschool_session.eschool_session_id
    assert_equal "KLE", eschool_session.language
    assert_equal "1", eschool_session.level
    assert_equal "emmiller", eschool_session.teacher
    assert_equal "2011-08-14 04:58:08", eschool_session.start_time
    assert_equal "60", eschool_session.duration_in_seconds
    assert_equal "true", eschool_session.cancelled
    assert_equal "1", eschool_session.number_of_seats
    assert_equal "0", eschool_session.learners_signed_up
    assert_equal "0", eschool_session.students_attended
    assert_equal "false", eschool_session.wildcard
    assert_true eschool_session.wildcard_units.empty?
    assert_equal "false", eschool_session.wildcard_locked
    assert_equal "true", eschool_session.teacher_confirmed
    assert_true eschool_session.external_village_id.empty?
    
  end

  def read_input_file(file_name)
    File.open(file_name, 'r').read
  end
end