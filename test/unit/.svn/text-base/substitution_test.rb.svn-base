require File.dirname(__FILE__) + '/../test_helper'

class SubstituionTest < ActiveSupport::TestCase

  def test_validates_presence_of
    session = FactoryGirl.create(:coach_session, :session_start_time => '2090-05-15 13:00:00', :language_identifier => 'KLE',:type => "LocalSession")
    substitution = FactoryGirl.create(:substitution, :coach_session_id => session.id, :coach_id => 123)
    assert_presence_required(substitution, :coach_session_id)
  end

  def test_session_unit
    session = FactoryGirl.create(:coach_session, :session_start_time => '2090-05-15 13:00:00', :language_identifier => 'KLE',:type => "LocalSession")
    substitution = FactoryGirl.create(:substitution, :coach_session_id => session.id, :coach_id => 123)
    assert_nil substitution.session_unit
  end

  def test_substitution_date
    session = FactoryGirl.create(:coach_session, :session_start_time => '2090-05-15 13:00:00', :language_identifier => 'KLE',:type => "LocalSession")
    substitution = FactoryGirl.create(:substitution, :coach_session_id => session.id, :coach_id => 123)
    assert_equal substitution.substitution_date, session.session_start_time
  end

  def test_get_future_alerts_for_coach_manager_without_last_seen
    manager = FactoryGirl.create(:account, :type => 'CoachManager', :user_name => 'rajkumar', :rs_email => 'rajkumar@rs.com')

    create_substituion_within(1.hour)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 1, substitutions.length

    create_substituion_within(2.hour)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 2, substitutions.length
  end
  
  def test_get_future_alerts_for_coach_manager_with_last_seen
    manager = FactoryGirl.create(:account, :type => 'CoachManager', :user_name => 'rajkumar', :rs_email => 'rajkumar@rs.com')

    substitution = create_substituion_within(1.hour)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 1, substitutions.length

    mock_now(Time.now + 5.seconds)
    FactoryGirl.create(:shown_substitutions, :coach_id => manager.id)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 0, substitutions.length

    mock_now(Time.now + 10.seconds)
    substitution.update_attributes(:coach_id => 123)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 1, substitutions.length
  end

  def test_get_future_alerts_for_substitutions_display_time_limit_as_per_preference
    manager = FactoryGirl.create(:account, :type => 'CoachManager', :user_name => 'rajkumar', :rs_email => 'rajkumar@rs.com')

    manager.get_preference.update_attributes(:substitution_alerts_display_time => 2.days)
    create_substituion_within(1.hour)
    create_substituion_within(2.hour)
    create_substituion_within(25.hour)
    create_substituion_within(50.hour)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 3, substitutions.length

    create_substituion_within(40.hour)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 4, substitutions.length

    create_substituion_within(60.hour)
    substitutions = Substitution.get_future_alerts(manager)
    assert_equal 4, substitutions.length
  end

  def test_get_future_alerts_for_coach_for_single_qualification
    coach = FactoryGirl.create(:account, :type => 'Coach', :user_name => 'rajkumar', :rs_email => 'rajkumar@rs.com')
    language = FactoryGirl.create(:language, :identifier => "RAJ")
    FactoryGirl.create(:qualification, :language => language, :coach_id => coach.id, :max_unit => 10)
    
    create_substituion_within(1.hour, language.identifier)
    substitutions = Substitution.get_future_alerts(coach)
    assert_equal 1, substitutions.length
  end

  def test_get_future_alerts_for_coach_for_multiple_qualifications
    coach = FactoryGirl.create(:account, :type => 'Coach', :user_name => 'rajkumar', :rs_email => 'rajkumar@rs.com')
    
    language1 = FactoryGirl.create(:language, :identifier => "RAJ")
    language2 = FactoryGirl.create(:language, :identifier => "JAR")
    FactoryGirl.create(:qualification, :language => language1, :coach_id => coach.id, :max_unit => 10)
    FactoryGirl.create(:qualification, :language => language2, :coach_id => coach.id, :max_unit => 10)
    
    create_substituion_within(1.hour, language1.identifier)
    create_substituion_within(2.hour, language2.identifier)
    substitutions = Substitution.get_future_alerts(coach)
    assert_equal 2, substitutions.length
  end

  def test_audit_logging_for_substitution_creation
    CustomAuditLogger.set_changed_by!("test21")

    session = FactoryGirl.create(:coach_session, :session_start_time => '2090-05-15 13:00:00', :language_identifier => 'KLE',:type => "LocalSession")
    substitution = FactoryGirl.create(:substitution, :coach_session_id => session.id, :coach_id => 123)
    
    audit_record = AuditLogRecord.last

    assert_equal substitution.id, audit_record.loggable_id
    assert_equal "Substitution", audit_record.loggable_type
    assert_equal "create", audit_record.action
    assert_equal "test21", audit_record.changed_by
  end
  
end
