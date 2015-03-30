require File.expand_path('../../test_helper', __FILE__)
# require 'dupe'

class ExtraSessionTest < ActiveSupport::TestCase

  def test_excluded_coaches_sessions

    extra_session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 250)
    assert_equal [], extra_session1.excluded_coaches_sessions

    extra_session2 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    FactoryGirl.create(:excluded_coaches_session, :coach_session_id => extra_session2.id, :coach_id=> Coach.first.id)
    assert_equal 1, extra_session2.excluded_coaches_sessions.size
    assert_equal 251, extra_session2.excluded_coaches_sessions.first.extra_session.eschool_session_id

    extra_session3 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 252)
    FactoryGirl.create(:excluded_coaches_session, :coach_session_id => extra_session3.id, :coach_id=> Coach.first.id)
    FactoryGirl.create(:excluded_coaches_session, :coach_session_id => extra_session3.id, :coach_id=> Coach.last.id)
    assert_equal 2, extra_session3.excluded_coaches_sessions.size

  end

  def test_excluded_coaches

    extra_session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 250)
    assert_equal [], extra_session1.excluded_coaches

    extra_session2 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    FactoryGirl.create(:excluded_coaches_session, :coach_session_id => extra_session2.id, :coach_id=> Coach.first.id)
    FactoryGirl.create(:excluded_coaches_session, :coach_session_id => extra_session2.id, :coach_id=> Coach.last.id)
    assert_equal 2, extra_session2.excluded_coaches.size
    assert_equal Coach.first.user_name, extra_session2.excluded_coaches.first.user_name
    assert_equal Coach.last.user_name, extra_session2.excluded_coaches.last.user_name
  end

  def test_create_one_off_and_check_for_a_record
    params = {:lang_identifier => 'ESP', :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    excluded_coach_id = Coach.first.id
    excluded_coach_list = "#{excluded_coach_id}"
    stub_stuffs_to_create_a_session
    Eschool::Session.stubs(:substitute).returns true
    result = ExtraSession.create_one_off(params, excluded_coach_list)
    assert_equal "Session was successfully created.", result[:notice]
    extra_session = result[:session]
    assert_equal 1, Substitution.find_all_by_coach_session_id(extra_session.id).size
    assert_equal excluded_coach_id ,extra_session.excluded_coaches.first.id
    assert_equal 1 ,extra_session.excluded_coaches.size
  end

  def test_create_one_off_reflex_and_check_for_a_record
    params = {:start_time => Time.now.beginning_of_day + 1.day, :lang_identifier => 'KLE', :name => "water bottle"}
    excluded_coach_id = Coach.first.id
    excluded_coach_list = [excluded_coach_id]
    result = ExtraSession.create_one_off_reflex(params, excluded_coach_list)
    assert_equal "Session was successfully created.", result[:notice]
    extra_session = result[:session]
    assert_equal 1, Substitution.find_all_by_coach_session_id(extra_session.id).size
    assert_equal excluded_coach_id ,extra_session.excluded_coaches.first.id
    assert_equal 1 ,extra_session.excluded_coaches.size
  end

  def test_create_one_off_reflex_excluding_more_than_one_coach
    params = {:start_time => Time.now.beginning_of_day + 1.day, :lang_identifier => 'KLE', :name => "water bottle"}
    excluded_coach_list = [Coach.first.id, Coach.last.id]
    result = ExtraSession.create_one_off_reflex(params, excluded_coach_list)
    assert_equal "Session was successfully created.", result[:notice]
    extra_session = result[:session]
    assert_equal 1, Substitution.find_all_by_coach_session_id(extra_session.id).size
    assert_equal 2 ,extra_session.excluded_coaches.size
  end
  def test_create_one_off_excluding_more_than_one_coaches
    params = {:lang_identifier => 'ESP', :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    excluded_coach_list = "#{Coach.first.id}, #{Coach.last.id}"
    stub_stuffs_to_create_a_session
    Eschool::Session.stubs(:substitute).returns true
    result = ExtraSession.create_one_off(params, excluded_coach_list)
    assert_equal "Session was successfully created.", result[:notice]
    extra_session = result[:session]
    assert_equal 1, Substitution.find_all_by_coach_session_id(extra_session.id).size
    assert_equal 2 ,extra_session.excluded_coaches.size
  end

  def test_update_session_details_with_same_excluded_coach_list
    params = {:lang_identifier => 'ITA', :name => "tom", :number_of_seats => 4, :external_village_id=> 3, :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    excluded_coach_id = Coach.first.id
    excluded_coach_list = "#{excluded_coach_id}"
    stub_stuffs_to_create_a_session
    Eschool::Session.stubs(:substitute).returns true
    extra_session = ExtraSession.create_one_off(params, excluded_coach_list)[:session]
    assert_equal "tom", extra_session.name
    assert_equal 4, extra_session.number_of_seats
    assert_equal 3, extra_session.external_village_id
    assert_equal excluded_coach_id ,extra_session.excluded_coaches.first.id
    extra_session.update_session_details("Jerry", 4, 1,1,36, "#{excluded_coach_id}")
    assert_equal "ITA", extra_session.language_identifier
    assert_equal "Jerry", extra_session.name
    assert_equal 4, extra_session.number_of_seats
    assert_equal 36, extra_session.external_village_id
    assert_equal excluded_coach_id ,extra_session.excluded_coaches.first.id
  end

  def test_update_session_details_with_superset_excluded_coach_list
    params = {:lang_identifier => 'ITA', :name => "tom", :external_village_id=> 3, :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    coach1 = create_coach_with_qualifications("jramanathan",[])
    coach2 = create_coach_with_qualifications("ssitoke",[])
    coach3 = create_coach_with_qualifications("psubramanian",[])
    coach4 = create_coach_with_qualifications("dutchfellow",[])
    old_excluded_coach_id_list = "#{coach1.id},#{coach2.id}"
    stub_stuffs_to_create_a_session
    Eschool::Session.stubs(:substitute).returns true
    extra_session = ExtraSession.create_one_off(params, old_excluded_coach_id_list)[:session]
    assert_equal 2 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(coach1)
    assert_true extra_session.excluded_coaches.include?(coach2)
    extra_session.update_session_details("Jerry", 2, 1,1,36, "#{coach1.id},#{coach3.id},#{coach2.id},#{coach4.id} ")
    extra_session.reload
    assert_equal 4 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(coach1)
    assert_true extra_session.excluded_coaches.include?(coach2)
    assert_true extra_session.excluded_coaches.include?(coach3)
    assert_true extra_session.excluded_coaches.include?(coach4)
  end

  def test_update_session_details_with_disjoint_set_excluded_coach_list
    params = {:lang_identifier => 'ITA', :name => "tom", :external_village_id=> 3, :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    coach1 = create_coach_with_qualifications("jramanathan",[])
    coach2 = create_coach_with_qualifications("ssitoke",[])
    coach3 = create_coach_with_qualifications("psubramanian",[])
    coach4 = create_coach_with_qualifications("dutchfellow",[])
    old_excluded_coach_id_list = "#{coach1.id},#{coach2.id}"
    stub_stuffs_to_create_a_session
    Eschool::Session.stubs(:substitute).returns true
    extra_session = ExtraSession.create_one_off(params, old_excluded_coach_id_list)[:session]
    assert_equal 2 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(coach1)
    assert_true extra_session.excluded_coaches.include?(coach2)
    extra_session.update_session_details("Jerry", 2, 1,1,36, "#{coach3.id},#{coach4.id}")
    extra_session.reload
    assert_equal 2 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(coach3)
    assert_true extra_session.excluded_coaches.include?(coach4)
  end

  def test_update_session_details_with_sub_set_excluded_coach_list
    params = {:lang_identifier => 'ITA', :name => "tom", :external_village_id=> 3, :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    coach1 = create_coach_with_qualifications("jramanathan",[])
    coach2 = create_coach_with_qualifications("ssitoke",[])
    coach3 = create_coach_with_qualifications("psubramanian",[])
    coach4 = create_coach_with_qualifications("dutchfellow",[])
    old_excluded_coach_id_list = "#{coach1.id},#{coach2.id},#{coach4.id} "
    stub_stuffs_to_create_a_session
    Eschool::Session.stubs(:substitute).returns true
    extra_session = ExtraSession.create_one_off(params, old_excluded_coach_id_list)[:session]
    assert_equal 3 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(coach1)
    assert_true extra_session.excluded_coaches.include?(coach2)
    extra_session.update_session_details("Jerry", 2, 1,1,36, "#{coach4.id} ")
    extra_session.reload
    assert_equal 1 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(coach4)
  end

  def test_update_session_details_with_empty_set_excluded_coach_list
    params = {:lang_identifier => 'ITA', :name => "tom", :external_village_id=> 3, :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    coach1 = create_coach_with_qualifications("jramanathan",[])
    coach2 = create_coach_with_qualifications("ssitoke",[])
    coach3 = create_coach_with_qualifications("psubramanian",[])
    coach4 = create_coach_with_qualifications("dutchfellow",[])
    old_excluded_coach_id_list = "#{coach1.id},#{coach2.id},#{coach4.id} "
    stub_stuffs_to_create_a_session
    Eschool::Session.stubs(:substitute).returns true
    extra_session = ExtraSession.create_one_off(params, old_excluded_coach_id_list)[:session]
    assert_equal 3 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(coach1)
    assert_true extra_session.excluded_coaches.include?(coach2)
    extra_session.update_session_details("Jerry", 2, 1,1,36, "")
    extra_session.reload
    assert_equal 0 ,extra_session.excluded_coaches.size
  end

  def test_exclude_coach_for_the_session
    extra_session = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    extra_session.exclude_coach_for_the_session(Coach.first.id)
    assert_equal 1 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(Coach.first)
  end

  def test_include_coach_for_the_session
    extra_session = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    extra_session.exclude_coach_for_the_session(Coach.first.id)
    assert_equal 1 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(Coach.first)
    extra_session.reload
    extra_session.include_coach_to_the_session(Coach.first.id)
    assert_equal 0 ,extra_session.excluded_coaches.size
  end

  def test_exclude_coaches_from_the_session
    extra_session = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    extra_session.exclude_coaches_from_the_session([Coach.first.id, Coach.last.id])
    assert_equal 2 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(Coach.first)
    assert_true extra_session.excluded_coaches.include?(Coach.last)
  end

  def test_include_coaches_to_the_session
    extra_session = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    extra_session.exclude_coaches_from_the_session([Coach.first.id, Coach.last.id])
    assert_equal 2 ,extra_session.excluded_coaches.size
    assert_true extra_session.excluded_coaches.include?(Coach.first)
    assert_true extra_session.excluded_coaches.include?(Coach.last)
    extra_session.reload
    extra_session.include_coaches_to_the_session([Coach.first.id, Coach.last.id])
    assert_equal 0 ,extra_session.excluded_coaches.size
  end

  def test_exclude_junk_coach_for_the_session
    extra_session = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    extra_session.exclude_coach_for_the_session(-1)
    assert_equal 0 ,extra_session.excluded_coaches.size
  end

  def test_include_junk_coach_to_the_session
    extra_session = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    extra_session.include_coach_to_the_session(-1)
    assert_equal 0 ,extra_session.excluded_coaches.size
  end

  def test_scheduled_extra_session_count_for_reflex
    session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 251, :session_start_time => '2025-05-20 10:00:00'.to_time)
    session2 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 252, :session_start_time => '2025-05-20 10:00:00'.to_time)
    session3 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :cancelled => 1, :eschool_session_id => 253, :session_start_time => '2025-05-20 10:00:00'.to_time)

    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session1.id)
    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session2.id)
    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session3.id)
    
    extra_session_count = ExtraSession.get_total_extra_session_count_for_reflex_on_a_slot('2025-05-20 10:00:00')
    assert_equal 2, extra_session_count
  end

  def test_scheduled_extra_session_count_for_reflex_after_grabbed
    session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 251, :session_start_time => '2025-05-20 10:00:00'.to_time)
    session2 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 252, :session_start_time => '2025-05-20 10:00:00'.to_time)

    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session1.id)
    sub = FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session2.id, :grabbed => 1)
    session2.update_attribute('type', "ConfirmedSession")
    extra_session_count = ExtraSession.get_total_extra_session_count_for_reflex_on_a_slot('2025-05-20 10:00:00')
    assert_equal 1, extra_session_count
  end

  def test_scheduled_extra_session_count_for_reflex_after_sub_requesting_grabbed_sessions
    session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 251, :session_start_time => '2025-05-20 10:00:00'.to_time)
    session2 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 252, :session_start_time => '2025-05-20 10:00:00'.to_time)

    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session1.id)
    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session2.id, :grabbed => 1)
    FactoryGirl.create(:substitution, :coach_session_id => session2.id)

    extra_session_count = ExtraSession.get_total_extra_session_count_for_reflex_on_a_slot('2025-05-20 10:00:00')
    assert_equal 2, extra_session_count
  end
  
  def test_grabbed_extra_session_count_for_reflex
    session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 251, :session_start_time => '2025-05-20 10:00:00'.to_time)
    session2 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 252, :session_start_time => '2025-05-20 10:00:00'.to_time)

    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session1.id)
    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session2.id, :grabbed => 1)

    grabbed_session_count = ExtraSession.get_grabbed_extra_session_count_for_reflex_on_a_slot('2025-05-20 10:00:00')
    assert_equal 1, grabbed_session_count
  end

  def test_grabbed_extra_session_count_for_reflex_after_sub_requesting_grabbed_sessions
    session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 251, :session_start_time => '2025-05-20 10:00:00'.to_time)
    session2 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 252, :session_start_time => '2025-05-20 10:00:00'.to_time)

    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session1.id)
    FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session2.id, :grabbed => 1)
    FactoryGirl.create(:substitution, :coach_session_id => session2.id, :grabbed => 1)

    grabbed_session_count = ExtraSession.get_grabbed_extra_session_count_for_reflex_on_a_slot('2025-05-20 10:00:00')
    assert_equal 1, grabbed_session_count
  end

  def test_create_invalid_one_off_and_check_for_error
    params = {:lang_identifier => 'ESP', :start_time => (Time.now.beginning_of_hour + 2.day).to_s(:db)}
    excluded_coach_id = Coach.first.id
    excluded_coach_list = "#{excluded_coach_id}"
    stub_stuffs_to_create_an_invalid_session
    Eschool::Session.stubs(:substitute).returns true
    result = ExtraSession.create_one_off(params, excluded_coach_list)
    assert_equal "Session failed to create", result[:error]
  end

  def test_create_invalid_one_off_reflex_and_check_for_error
    params = {:start_time => "not a time", :lang_identifier => 'KLE', :name => "water bottle"}
    excluded_coach_id = Coach.first.id
    excluded_coach_list = [excluded_coach_id]
    result = ExtraSession.create_one_off_reflex(params, excluded_coach_list)
    assert_equal "Session cannot be created.", result[:error]
  end

  def test_excluded_coaches_should_not_recieve_mail_for_extra_sessions
    coach = create_coach_with_qualifications('espcoach', ['ESP'])
    extra_session = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'ESP', :eschool_session_id => 251)
    sub = FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => extra_session.id)
    coaches = extra_session.language.coaches
    coaches.reject!{|coach| !coach.active?}
    extra_session.exclude_coaches_from_the_session([coach.id])
    Coach.expects(:email_recipients).returns("sample@rosettastone.com")
    CoachManager.expects(:email_recipients).returns("sample@rosettastone.com")
    extra_session.send_email_to_coaches_and_coach_managers([coaches.first.id])
  end

  private
  def stub_stuffs_to_create_a_session
    REXML::Document.stubs(:new).returns(XML::Parser.string(get_response_for_eschool_create).parse)
    Eschool::Session.stubs(:create).returns(Eschool::Session.new)
    Eschool::Session.any_instance.stubs(:read_body).returns(get_response_for_eschool_create)
    XML::Document.any_instance.stubs(:elements).returns(REXML::Element.new(get_response_for_eschool_create))
    REXML::Element.any_instance.stubs(:to_a).with(anything).returns([create_session])
    Eschool::Session.any_instance.stubs(:get_tag_value).with(kind_of(String)).returns(nil)
    Eschool::Session.any_instance.stubs(:get_tag_value).with("language").returns("ITA")
    Eschool::Session.any_instance.stubs(:get_tag_value).with("eschool_session_id").returns(251)
    Eschool::Session.any_instance.stubs(:get_tag_value).with("external_village_id").returns(24)
    Eschool::Session.any_instance.stubs(:get_tag_value).with("start_time").returns(Time.now + 1.day)
    NilClass.any_instance.stubs(:to_time).returns(nil)
    Eschool::Session.stubs(:substitute).returns(nil)
    Eschool::Session.stubs(:find_by_id).returns(create_session)
    EschoolResponseParser.any_instance.stubs(:parse).returns([create_session])

  end

  def stub_stuffs_to_create_an_invalid_session
    REXML::Document.stubs(:new).returns(XML::Parser.string(get_response_for_eschool_create).parse)
    Eschool::Session.stubs(:create).returns(nil)
    Eschool::Session.stubs(:get_session_details).returns(nil)
    EschoolResponseParser.any_instance.stubs(:parse).returns(nil)
    Eschool::Session.any_instance.stubs(:read_body).returns(get_response_for_eschool_create)
    XML::Document.any_instance.stubs(:elements).returns(REXML::Element.new(get_response_for_eschool_create))
    REXML::Element.any_instance.stubs(:to_a).with("//error_session").returns([])
    REXML::Element.any_instance.stubs(:to_a).with("//eschool_session").returns([])
    NilClass.any_instance.stubs(:get_tag_value).with("message").returns("Session failed to create")
  end

  def get_response_for_eschool_create
    xml = <<EOF
          <eschool_sessions type='array'>
            <eschool_session>
              <eschool_session_id>1001</eschool_session_id>
              <eschool_class_id>101</eschool_class_id>
              <language>'ESP'</language>
              <level>1</level>
              <unit>1</unit>
              <teacher>'psubramanian'</teacher>
              <teacher_id>101</teacher_id>
              <start_time time_zone='UTC'>'2015-05-31 19:00:00'</start_time>
              <duration_in_seconds>3600</duration_in_seconds>
              <cancelled>false</cancelled>
              <number_of_seats>4</number_of_seats>
              <learners_signed_up>0</learners_signed_up>
              <students_attended>0</students_attended>
              <wildcard>true</wildcard>
              <wildcard_units>'1,2,3,4,5,6,7,8,9,10'</wildcard_units>
              <wildcard_locked>false</wildcard_locked>
              <teacher_confirmed>true</teacher_confirmed>
              <external_village_id></external_village_id>
            </eschool_session>
          </eschool_sessions>
EOF
    return xml
  end
  def create_session
    return Eschool::Session.new(
      :eschool_session_id =>1001, :eschool_class_id=>101,
      :language=>'ESP', :level=>1, :unit=>1, :teacher=>{:user_name=>'psubramanian'},
      :start_time =>"Tue, 31 May 2011 15:00:00 EDT -04:00",
      :duration_in_seconds=>3600, :cancelled=>false,
      :number_of_seats=>4, :learners_signed_up=>0,
      :students_attended=>0, :wildcard=>true,
      :wildcard_units=>'1,2,3,4,5,6,7,8,9,10',:wildcard_locked=>false,
      :teacher_confirmed=>true, :external_village_id=>nil
    )
  end
end
