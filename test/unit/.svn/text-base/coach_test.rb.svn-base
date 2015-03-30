require File.expand_path('../../test_helper', __FILE__)

class CoachTest < ActiveSupport::TestCase

  test "two language qualifications for the same coach" do
    Coach.find_by_user_name("jramanathan").try(:destroy)
    coach=FactoryGirl.create(:coach, :user_name => "jramanathan", :full_name => "jramanathan", :preferred_name => "NULL", :rs_email => "jramanathan@rs.com", :type => "Coach", :lotus_qualified => true)
    coach.qualifications.create(:language_id => 10, :max_unit=>10)
    coach.qualifications.create(:language_id => 10, :max_unit=>15)
    assert !coach.valid?
    assert_equal ["has already been taken."], coach.errors['qualifications.language']
  end  

  def test_find_all_active_coaches
    Coach.find_by_user_name("jramanathan").try(:destroy)
    coach=FactoryGirl.create(:coach, :user_name => "jramanathan", :full_name => "jramanathan", :preferred_name => "NULL", :rs_email => "jramanathan@rs.com", :type => "Coach", :lotus_qualified => true)
    language = Language['CHI'] || TotaleLanguage.create(:identifier=>"CHI")
    language_2 = Language['ARA'] || TotaleLanguage.create(:identifier=>"ARA")
    coach.qualifications.create(:language_id => language.id, :max_unit=>10)
    assert_true Coach.find_all_active_coaches.include? coach
    assert_true Coach.find_all_active_coaches(language.identifier).include? coach
    assert_true Coach.find_all_active_coaches('KKR').include? coach
    assert_false Coach.find_all_active_coaches('ARA').include? coach
  end
  def test_update_time_off_create_session
    begining_of_hour = Time.now.beginning_of_hour
    time_off_start_date  = begining_of_hour + 1.hour
    time_off_end_date    = begining_of_hour + 3.hour
    coach       = create_coach_with_qualifications
    time_off    = UnavailableDespiteTemplate.create({
          :coach_id             => coach.id,
          :start_date           => time_off_start_date,
          :end_date             => time_off_end_date,
          :approval_status      => 1,
          :comments             => 'I can not teach.',
          :unavailability_type  => 0,
        })
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour + 2.hour, :language_identifier => "ARA", :eschool_session_id => 343)
    session_start_time = begining_of_hour + 2.hour
    coach.update_time_off(coach_session)
    time_off.reload
    assert_equal time_off_start_date.utc, time_off.start_date.utc
    assert_equal session_start_time.utc, time_off.end_date.utc
    # This will create a new time-off. Following code is to check that
    new_time_off = coach.time_off_at(session_start_time + 30.minutes)
    assert_equal (session_start_time + 30.minutes).utc, new_time_off.start_date.utc
    assert_equal time_off_end_date.utc, new_time_off.end_date.utc
  end

  def test_availability_for_week
    coach       = create_coach_with_qualifications("ela",["ARA","AUS"])
    start_date = Time.now.beginning_of_day
    availability_template = FactoryGirl.build(:coach_availability_template, :coach_id => coach.id, :effective_start_date => (start_date + 30.hour), :created_at => '2012-03-28', :label =>'abcdefgh',:status => 1)
    availability_template.save!
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(true)
    ConfirmedSession.any_instance.stubs(:supersaas_coach).returns([{:email => coach.rs_email}])
    coach_availability = availability_template.create_availilability(Time.now.beginning_of_hour+24.hour, Time.now.beginning_of_hour+30.hour, true)
    coach_availability = availability_template.create_availilability(Time.now.beginning_of_hour+32.hour, Time.now.beginning_of_hour+34.hour, true)
    session_start_time=Time.now.utc.beginning_of_hour + 24.hour
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => session_start_time, :language_identifier => "AUS", :eschool_session_id => 343)
    coach.max_level_unit_qualification_for_language(coach.aria_language)
    # assert_equal 2, coach.availlbility_for_week(Time.now.beginning_of_hour,"AUS").size
    coach_session_1   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour + 27.hour, :language_identifier => "ARA", :eschool_session_id => 343)
    coach.qualifications.create(:language_id => Language.find_by_identifier("AUS").id, :max_unit=>10)
    coach.qualifications.create(:language_id => Language.find_by_identifier("ARA").id, :max_unit=>10)
    #assert_false coach.threshold_reached?(Time.now.beginning_of_hour+24.hour)
    assert_equal start_date+9.hour,coach.detect_availability_change_for_slot_in_future(start_date + 9.hour)
    assert_equal start_date+30.hour, coach.approved_templates_for_language_start_time.first.effective_start_date
    lst = LanguageSchedulingThreshold.find_by_language_id(Language.find_by_identifier("AUS").id)
    if lst.nil?
      lst = FactoryGirl.create(:language_scheduling_threshold, :language_id=>Language.find_by_identifier("AUS").id,:max_assignment=>48,:max_grab=>28,:hours_prior_to_sesssion_override=>4)
    end
    Coach.any_instance.stubs(:thresholds).returns(lst)
    assert_equal [false,false], coach.threshold_reached?(Time.now.beginning_of_hour) 
    assert_true coach.can_create_recurring_session?(session_start_time+90.minute,false,true)
    assert_true coach.can_create_recurring_session?(session_start_time+2.hour,true,true)
  end

  def test_get_affected_session_count
    begining_of_hour = Time.now.beginning_of_hour
    start_date  = begining_of_hour + 3.hour
    end_date    = begining_of_hour + 5.hour
    coach       = create_coach_with_qualifications("ela",["ARA","AUS"])
    assert_equal [Language.find_by_identifier("ARA").id, Language.find_by_identifier("AUS").id],coach.all_languages
    assert_not_nil coach.all_language_identifier
    assert_equal "AUS",coach.aria_language
    assert_equal "ela@rs.com",coach.email
    grabber_coach = create_coach_with_qualifications("elavarasu",["ARA"])
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => start_date, :language_identifier => "ARA", :eschool_session_id => 343)
    susbtitution=FactoryGirl.create(:substitution,:coach_id => coach.id, :grabber_coach_id => grabber_coach.id,:grabbed => 1,:coach_session_id => coach_session.id,:cancelled => 0, :was_reassigned => true)
    assert_equal coach.session_cancelled_at_eschool?(begining_of_hour),[]
    count = coach.get_affected_session_count(start_date,end_date,0)
    count = coach.get_affected_session_count(start_date,end_date,1)
  end

  def test_update_time_off_create_session_for_30_min_time_off
    begining_of_hour = Time.now.beginning_of_hour
    time_off_start_date  = begining_of_hour + 1.hour
    time_off_end_date    = time_off_start_date + 30.minutes
    coach       = create_coach_with_qualifications
    time_off    = UnavailableDespiteTemplate.create({
          :coach_id             => coach.id,
          :start_date           => time_off_start_date,
          :end_date             => time_off_end_date,
          :approval_status      => 1,
          :comments             => 'I can not teach.',
          :unavailability_type  => 0,
        })
    assert_equal time_off_start_date, coach.time_off_at(time_off_start_date).start_date
    session_start_time = time_off_start_date # session starts at same time of time-off. different variable used for readability
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => session_start_time, :language_identifier => "ARA", :eschool_session_id => 343)
    coach.update_time_off(coach_session)
    assert_nil coach.time_off_at(time_off_start_date)
  end

  def test_update_time_off_for_session_at_time_off_starting
    begining_of_hour = Time.now.beginning_of_hour
    time_off_start_date  = begining_of_hour + 3.hours
    time_off_end_date    = time_off_start_date + 3.hours

    coach       = create_coach_with_qualifications
    time_off    = UnavailableDespiteTemplate.create({
                      :coach_id             => coach.id,
                      :start_date           => time_off_start_date,
                      :end_date             => time_off_end_date,
                      :approval_status      => 1,
                      :comments             => 'I can not teach.',
                      :unavailability_type  => 0,
                  })
    assert_equal time_off_start_date, coach.time_off_at(time_off_start_date).start_date
    session_start_time = time_off_start_date # session starts at same time of time-off. different variable used for readability
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => session_start_time, :language_identifier => "ARA", :eschool_session_id => 343)
    coach.update_time_off(coach_session)
    assert_not_nil coach.time_off_at(time_off_start_date + 30.minutes)
    assert_nil coach.time_off_at(time_off_start_date)
    assert_equal (time_off_start_date + 30.minutes), coach.time_off_at(time_off_start_date + 30.minutes).start_date
    assert_equal time_off_end_date , coach.time_off_at(time_off_start_date + 30.minutes).end_date
  end
  def test_update_time_off_for_session_at_time_off_ending
    begining_of_hour = Time.now.beginning_of_hour
    time_off_start_date  = begining_of_hour + 3.hours
    time_off_end_date    = time_off_start_date + 3.hours

    coach       = create_coach_with_qualifications
    time_off    = UnavailableDespiteTemplate.create({
                      :coach_id             => coach.id,
                      :start_date           => time_off_start_date,
                      :end_date             => time_off_end_date,
                      :approval_status      => 1,
                      :comments             => 'I can not teach.',
                      :unavailability_type  => 0,
                  })
    assert_equal time_off_start_date, coach.time_off_at(time_off_start_date).start_date
    session_start_time = time_off_end_date - 30.minutes # session starts at same time of time-off end time slot. different variable used for readability
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => session_start_time, :language_identifier => "ARA", :eschool_session_id => 343)
    coach.update_time_off(coach_session)
    assert_not_nil coach.time_off_at(time_off_start_date)
    assert_equal time_off_start_date, coach.time_off_at(time_off_start_date).start_date
    assert_equal (time_off_end_date - 30.minutes) , coach.time_off_at(time_off_start_date).end_date
  end

  def test_sessions_between_time_boundries
    CoachSession.delete_all
     Coach.find_by_user_name("rramesh").try(:destroy)
    coach=FactoryGirl.create(:coach, :user_name => "rramesh", :full_name => "rramesh", :preferred_name => "NULL", :rs_email => "rramesh@rs.com", :type => "Coach", :lotus_qualified => true)
    language_max_unit_array = [{:language => Language['ARA'].id,:max_unit => 12},{:language => Language['GRK'].id,:max_unit => 10},{:language => Language['HEB'].id,:max_unit => 10},{:language => Language['ENG'].id,:max_unit => 8}]
    create_qualifications(coach.id,language_max_unit_array)
    existing_session_start_time = (Time.now+1.hour).utc.beginning_of_hour
    
    session1 = FactoryGirl.create(:confirmed_session,:coach_id => coach.id,:session_start_time => existing_session_start_time,:eschool_session_id => "345698",:cancelled => "0", :language_identifier => "HEB" )
    session2 = FactoryGirl.create(:confirmed_session,:coach_id => coach.id,:session_start_time => existing_session_start_time+30.minutes,:eschool_session_id => "345699",:cancelled => "0", :language_identifier => "HEB" )
    session3 = FactoryGirl.create(:confirmed_session,:coach_id => coach.id,:session_start_time => existing_session_start_time+1.hour,:eschool_session_id => "345998",:cancelled => "0", :language_identifier => "HEB" )
    session4 = FactoryGirl.create(:confirmed_session,:coach_id => coach.id,:session_start_time => existing_session_start_time+90.minutes,:eschool_session_id => "345999",:cancelled => "0", :language_identifier => "HEB" )
    session1.save(:validate => false)
    session2.save(:validate => false)
    session3.save(:validate => false)
    session4.save(:validate => false)
    assert_true(coach.sessions_between_time_boundries(existing_session_start_time,existing_session_start_time+30.minutes).length > 0)
    assert_equal 1, coach.sessions_between_time_boundries(existing_session_start_time + 30.minutes,existing_session_start_time + 1.hour).length
    assert_equal 1, coach.sessions_between_time_boundries(existing_session_start_time + 45.minutes,existing_session_start_time + 75.minutes).length
    assert_true(coach.sessions_between_time_boundries(existing_session_start_time + 1.hour,existing_session_start_time + 90.minutes).length == 1)
    assert_true(coach.sessions_between_time_boundries(existing_session_start_time + 75.minutes,existing_session_start_time + 105.minutes).length == 1)
  end

 
  def test_is_excluded
    coach = create_coach_with_qualifications
    extra_session1 = FactoryGirl.create(:extra_session)
    FactoryGirl.create(:excluded_coaches_session, :coach_id => coach.id, :coach_session_id => extra_session1.id)
    assert_equal coach.is_excluded?(extra_session1),true
      Coach.find_by_user_name("psubramanian").try(:destroy)
    coach1 = FactoryGirl.create(:coach, :user_name => "psubramanian", :full_name => "psubramanian", :preferred_name => "NULL", :rs_email => "psubramanian@rs.com", :type => "Coach", :lotus_qualified => true)
    extra_session2 = FactoryGirl.create(:extra_session,:coach_id =>  coach1.id, :session_start_time => '2028-05-15 13:00:00', :eschool_session_id => 5432, :cancelled => 0, :language_identifier => 'ESP', :type => 'ExtraSession')
    assert_equal coach.is_excluded?(extra_session2),false
  end
  
  def test_total_session_count_limit_for_coach
      prepare_test_data
      thresholds = Coach.find_by_user_name("asangamlal").thresholds
 	   	assert_equal 50, thresholds.max_assignment
      assert_equal 29, thresholds.max_grab
 	end

  private
  
  def prepare_test_data
      l1 = Language.find_by_identifier('ARA')
      l2 = Language.find_by_identifier('CHI')
      l3 = Language.find_by_identifier('HIN')

      created_coach = FactoryGirl.create(:account,:user_name => "asangamlal",:full_name => "asangamlal",:preferred_name => "NULL",:rs_email => "asangamlal@rs.com",:type => "Coach",:lotus_qualified =>true)

      FactoryGirl.create(:qualification, :language_id =>l1.id,:coach_id=>created_coach.id,:max_unit =>10)
      FactoryGirl.create(:qualification, :language_id =>l2.id,:coach_id=>created_coach.id,:max_unit =>10)
      FactoryGirl.create(:qualification, :language_id =>l3.id,:coach_id=>created_coach.id,:max_unit =>10)

      FactoryGirl.create(:language_scheduling_threshold, :language_id=>l1.id,:max_assignment=>50,:max_grab=>28,:hours_prior_to_sesssion_override=>2)
      FactoryGirl.create(:language_scheduling_threshold, :language_id=>l2.id,:max_assignment=>49,:max_grab=>29,:hours_prior_to_sesssion_override=>3)
      FactoryGirl.create(:language_scheduling_threshold, :language_id=>l3.id,:max_assignment=>48,:max_grab=>27,:hours_prior_to_sesssion_override=>4)
  end

  def initialize_coach
    l1 = Language.find_by_identifier('ARA')
    l2 = Language.find_by_identifier('CHI')
    l3 = Language.find_by_identifier('ENG')

    created_coach = FactoryGirl.create(:account, :user_name => "newcoach", :full_name => "New Coach", :preferred_name => "NULL",:rs_email => "new_coach@rs.com",:type => "Coach",:lotus_qualified =>true)

    FactoryGirl.create(:qualification, :language_id =>l1.id,:coach_id=>created_coach.id,:max_unit =>10)
    FactoryGirl.create(:qualification, :language_id =>l2.id,:coach_id=>created_coach.id,:max_unit =>10)
    FactoryGirl.create(:qualification, :language_id =>l3.id,:coach_id=>created_coach.id,:max_unit =>10)
    Coach.find_by_user_name("newcoach")
  end

end
