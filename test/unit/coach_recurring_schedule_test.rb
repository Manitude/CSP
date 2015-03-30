require File.expand_path('../../test_helper', __FILE__)

class CoachRecurringScheduleTest < ActiveSupport::TestCase

  def test_aaaaaaa_this_test_should_be_run_first_to_create_the_function_for_time_zone
    run_time_zone_fn
  end

  def test_should_return_recurring_schedules_for_all_villages
    Thread.stubs(:current).returns(:current_user => OpenStruct.new(:time_zone => 'America/New_York'))
    coach = create_coach_with_qualifications("testcoach", ['ARA'])
    language = Language['ARA']
    date  = "2035-01-07 00:00:00".to_time # (Sending as UTC Time)
    CoachAvailabilityTemplate.delete_all
    CoachRecurringSchedule.delete_all
    template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => date.to_s(:db)})
    template.availabilities.create({:day_index => "2", :start_time => "05:00:00", :end_time => "07:00:00"})
    template.availabilities.create({:day_index => "3", :start_time => "05:00:00", :end_time => "07:00:00"})
  
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00',
      :day_index => 2, :coach_id => coach.id, :language_id => language.id, :recurring_start_date => date-1.week)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:30:00', :day_index => 3, :coach_id => coach.id,
      :language_id => language.id,:external_village_id => 15, :recurring_start_date => date-1.week)

    schedules = CoachRecurringSchedule.fetch_for("2035-01-05 05:00:00".to_time, "2035-01-11 05:00:00".to_time, language.id, 'all')
    assert_equal(2, schedules.size)
  end

  def test_should_not_return_recurring_schedules_as_there_no_availability_template_for_coaches
    
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    language = Language['ARA']
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00',
      :day_index => 2, :coach_id => coach.id, :language_id => language.id, :recurring_start_date => '2012-11-12 05:30:00')
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00', :day_index => 3, :coach_id => coach.id,
      :language_id => language.id,:external_village_id => 15, :recurring_start_date => '2012-11-12 05:  00:00')

    schedules = CoachRecurringSchedule.fetch_for('2012-08-12'.to_time, '2012-08-12'.to_time + 7.days, language.id, 'all')
    assert_equal(0, schedules.size)
  end

  def test_should_return_schedules_for_selected_village_id
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    language =Language['ARA']
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "2", :start_time => "05:00:00", :end_time => "07:00:00"})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "05:00:00", :end_time => "07:00:00"})
    
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00',
      :day_index => 2, :coach_id => coach.id, :language_id => language.id, :external_village_id => 56, :recurring_start_date => date-1.week )
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:30:00',
      :day_index => 3, :coach_id => coach.id, :language_id => language.id, :external_village_id => 15, :recurring_start_date => date-1.week )
    
    schedules = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, language.id, "56")
    assert_equal(1, schedules.size)
    assert_equal(date-1.week, schedules.first.recurring_start_date)
  end

  def test_should_return_appropriate_start_time_in_dst
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    language =Language['ARA']
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "05:00:00", :end_time => "07:00:00"})

    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00',
        :day_index => 3, :coach_id => coach.id, :recurring_start_date => date-1.week, :language_id => language.id, :external_village_id => 56)
    schedules = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, language.id, "56")
    assert_equal(date - 1.week, schedules.first.recurring_start_date)
  end

  def test_should_not_return_if_coach_already_scheduled_another_language
    CoachRecurringSchedule.delete_all
    coach = create_coach_with_qualifications('newcoach', ['ARA', 'SPA'])
    language = Language['ARA']
    another_language = Language['SPA']
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "2", :start_time => "05:00:00", :end_time => "08:00:00"})

    FactoryGirl.create(:coach_session, :coach_id => coach.id, :session_start_time => '2025-01-07 05:30:00'.to_time, :language_identifier => another_language.identifier, :type => 'ExtraSession')
    FactoryGirl.create(:coach_session, :coach_id => coach.id, :session_start_time => '2025-01-08 05:30:00'.to_time, :language_identifier => another_language.identifier, :type => 'ExtraSession')
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '05:30:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2012-07-18', :language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:30:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2012-07-18', :language_id => language.id)

    schedules = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, language.id, "all")

    assert_equal(2, schedules.size)
    assert_equal('2012-07-18 00:00:00'.to_time, schedules.first.recurring_start_date)
  end

  def test_should_recurring_schedules_that_considers_recurring_end_date
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    language = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "2", :start_time => "05:00:00", :end_time => "07:00:00"})
    coach_availability_template.availabilities.create({:day_index => "1", :start_time => "07:00:00", :end_time => "09:00:00"})
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '05:30:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2012-07-18', :language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '07:30:00', :day_index => 1, :coach_id => coach.id,
        :recurring_start_date => '2012-08-06', :language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:30:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2012-08-07', :recurring_end_date => '2012-08-08', :language_id => language.id)

    schedules = CoachRecurringSchedule.fetch_for('2025-01-05 00:00:00'.to_time, '2025-01-05 23:59:00'.to_time + 7.days, language.id, 'all')

    assert_equal(2, schedules.size)
  end

  def test_should_recurring_schedules_that_has_older_start_date
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    language = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "2", :start_time => "05:00:00", :end_time => "07:00:00"})
    coach_availability_template.availabilities.create({:day_index => "1", :start_time => "07:00:00", :end_time => "09:00:00"})
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '05:30:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2012-07-18',:language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '07:30:00', :day_index => 1, :coach_id => coach.id,
        :recurring_start_date => '2011-08-06',:language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:30:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2025-02-06',:language_id => language.id)

    schedules = CoachRecurringSchedule.fetch_for('2025-01-05 00:00:00'.to_time, '2025-01-05 23:59:00'.to_time + 7.days, language.id, 'all')

    assert_equal(2, schedules.size)
  end

  def test_should_fetch_recurring_schedules_grouped_by_session_start_time
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    coach1 = create_coach_with_qualifications('newcoach', [])
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    language = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "2", :start_time => "15:00:00", :end_time => "17:00:00"})
    coach_availability_template.availabilities.create({:day_index => "1", :start_time => "15:00:00", :end_time => "18:00:00"})
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '15:30:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2012-07-18 15:30:00',:language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '16:30:00', :day_index => 1, :coach_id => coach1.id,
        :recurring_start_date => '2011-08-06 16:30:00', :language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '16:30:00', :day_index => 1, :coach_id => coach1.id,
        :recurring_start_date => '2011-08-06 16:30:00', :language_id => language.id)

    schedules = CoachRecurringSchedule.fetch_for('2025-01-05 00:00:00'.to_time, '2025-01-05 23:59:00'.to_time + 7.days, language.id, 'all')
    count_1630=0
    count=0
    schedules.each do |schedule|
        if schedule.recurring_start_date.strftime('%H-%M-%S') == '16-30-00'
          count_1630=count_1630+1
        else
          count=count+1
        end
    end
      assert_equal(2, count_1630)
      assert_equal(1, count)
    assert_equal(3, schedules.size)
  end

  def test_should_not_return_multiple_records_unnecessarily
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    language = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "2", :start_time => "05:00:00", :end_time => "07:00:00"})
    coach_availability_template.availabilities.create({:day_index => "1", :start_time => "07:00:00", :end_time => "09:00:00"})
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '07:30:00', :day_index => 1, :coach_id => coach.id,
        :recurring_start_date => date-2.week, :language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00', :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => language.id)
    FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => '2025-01-01'.to_time,
        :end_date => '2025-01-07'.to_time, :comments => 'test availability', :approval_status => 1)
    udt = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => '2025-06-15'.to_time,
        :end_date => '2025-06-30'.to_time, :comments => 'test availability', :approval_status => 1)
    udt.save(:validation => false)
    schedules = CoachRecurringSchedule.fetch_for('2025-01-05 00:00:00'.to_time, '2025-01-05 23:59:00'.to_time + 7.days, language.id, 'all')

    assert_equal(1, schedules.size)
  end

  def test_should_return_recurring_schedules_considering_unavailable_despite_templates
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "1", :start_time => "05:00:00", :end_time => "07:00:00"})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "05:00:00", :end_time => "07:00:00"})
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00', :day_index => 1, :coach_id => coach.id,
        :recurring_start_date => date-2.week, :language_id => lang.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '06:00:00', :day_index => 3, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => lang.id)
    FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => '2025-01-06'.to_time,
        :end_date => '2025-01-07'.to_time, :comments => 'test availability', :approval_status => true)
    schedules = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, lang.id, 'all')

    assert_equal(1, schedules.size)
  end

  def test_should_return_recurring_schedules_considering_approved_time_off
    language = Language['ARA']
    coach = FactoryGirl.create(:coach, :user_name => '12testxy')
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '2012-08-06 17:30:00'.to_time.strftime('%H:%M:%S'), :day_index => 1, :coach_id => coach.id,
        :recurring_start_date => '2012-07-16', :recurring_end_date => '2012-08-12', :language_id => language.id)
    FactoryGirl.create(:coach_recurring_schedule, :start_time => '2012-08-07 16:30:00'.to_time.strftime('%H:%M:%S'), :day_index => 2, :coach_id => coach.id,
        :recurring_start_date => '2012-07-20', :recurring_end_date => '2012-08-12', :language_id => language.id)
    udt1 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => '2025-08-03'.to_time,
        :end_date => '2025-08-07'.to_time, :comments => 'test availability', :approval_status => true)
    udt1.start_date = '2012-08-03'.to_time
    udt1.end_date = '2012-08-07'.to_time
    udt1.save(:validation => false)
    schedules = CoachRecurringSchedule.fetch_for('2012-08-05'.to_time, '2012-08-05'.to_time + 7.days, language.id, 'all')

    assert_equal(0, schedules.size)
  end

  def test_sl_recurring_with_ca_rs_and_without_actual_sessions_cua_records_for_next_week
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    FactoryGirl.create(:coach_recurring_schedule, :start_time => "06:00:00", :day_index => 1, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => lang.id)

    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "1", :start_time => "05:00:00", :end_time => "07:00:00"})

    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, lang.id, "all")
    assert_equal 1                              , recurring_data_for_the_week.count
    assert_equal coach.id                       , recurring_data_for_the_week[0].coach_id
    assert_equal "2025-01-06 06:00:00"  , recurring_data_for_the_week[0].schedule_time
    assert_equal lang.id                        , recurring_data_for_the_week[0].language_id
    assert_equal nil                            , recurring_data_for_the_week[0].external_village_id
  end

  def test_sl_recurring_with_ca_rs_uncancelled_actual_session_and_without_cua_records_for_same_week
    coach = FactoryGirl.create(:coach,:user_name => "newcoach",:full_name => "new coach",:active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    create_recurring_session(coach, date, lang)

    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "00:00", :end_time => "01:00"})

    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2024-12-29 00:00:00".to_time, "2025-01-04 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end

  def test_sl_recurring_with_ca_and_without_rs_actual_session_cua_records_for_same_week
    coach = FactoryGirl.create(:coach,:user_name => "newcoach",:full_name => "new coach",:active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "00:00", :end_time => "01:00"})
    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2024-12-29 00:00:00".to_time, "2025-01-04 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end


  def test_sl_recurring_with_rs_and_without_ca_actual_session_cua_records_for_same_week
    coach = FactoryGirl.create(:coach, :user_name => "newcoach", :full_name => "new coach", :active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    create_recurring_session(coach, date, lang)
    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2024-12-29 00:00:00".to_time, "2025-01-04 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end

  def test_sl_recurring_with_ca_rs_cua_on_same_slot_and_without_actual_session_records_for_same_week
    coach = FactoryGirl.create(:coach, :user_name => "newcoach", :full_name => "new coach", :active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']

    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "00:00", :end_time => "01:00"})
    coach.availability_modifications.create({:start_date => "2025-01-05 00:00:00".to_time, :end_date => "2025-01-11 23:59:00".to_time, :unavailability_type => 0, :comments => "Test ..", :approval_status => 1})
    create_recurring_session(coach, date, lang)
    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count

    coach.availability_modifications.create({:start_date => "2025-01-05 00:00:00".to_time, :end_date => "2025-01-06 23:59:00".to_time, :unavailability_type => 0, :comments => "Test ..", :approval_status => 1})
    create_recurring_session(coach, date, lang)
    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end


  def test_sl_recurring_with_ca_rs_cua_on_different_slot_and_without_actual_session_records_for_same_week
    coach = create_coach_with_qualifications('newcoach', ['ARA'])
    date  = "2025-01-07 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    FactoryGirl.create(:coach_recurring_schedule, :start_time => "06:00:00", :day_index => 3, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => lang.id)

    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "05:00:00", :end_time => "07:00:00"})
    coach.availability_modifications.create({:start_date => "2025-01-05 00:00:00".to_time, :end_date => "2025-01-06 23:59:00".to_time, :unavailability_type => 0, :comments => "Test ..", :approval_status => 1})

    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for(date-1.week, date, lang.id, "all")
    assert_equal 1, recurring_data_for_the_week.count
  end


  def test_sl_recurring_with_ca_rs_cancelled_actual_session_and_without_cua_records_for_same_week
    coach = FactoryGirl.create(:coach,:user_name => "newcoach",:full_name => "new coach",:active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "00:00", :end_time => "01:00"})
    create_recurring_session(coach, date, lang)
    # Canceling the actual session.
    coach.coach_sessions.first.update_attribute(:cancelled, true)
    assert_true coach.coach_sessions.first.cancelled

    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2024-12-29 00:00:00".to_time, "2025-01-04 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end

  # Test for Coach with Multiple languages (ml = Multiple languages)

  def test_ml_recurring_with_ca_rs_uncancelled_actual_session_for_language_starting_in_another_start_time_and_without_cua_records_for_same_week
    coach = FactoryGirl.create(:coach,:user_name => "newcoach",:full_name => "new coach",:active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang1 = FactoryGirl.create(:language, :identifier => 'ARA1')
    lang2 = FactoryGirl.create(:language, :identifier => 'ARA2')
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => (date).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "00:00", :end_time => "01:00"})

    create_recurring_session(coach, date, lang1)
    FactoryGirl.create(:confirmed_session,:coach_id=>coach.id,:session_start_time =>"2025-01-08 00:00:00".to_time, :language_identifier => lang2.identifier, :eschool_session_id => 786 )

    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, lang1.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end


  def test_ml_recurring_with_ca_rs_cua_near_the_end_of_hour_and_without_actual_session_records_for_same_week
    coach = FactoryGirl.create(:coach, :user_name => "newcoach", :full_name => "new coach", :active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => date.to_s(:db), :status => 1,:created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "00:00", :end_time => "01:00"})
    create_recurring_session(coach, date, lang)
    coach.availability_modifications.create({:start_date => "2025-01-07 23:15:00".to_time, :end_date => "2025-01-08 00:15:00".to_time, :unavailability_type => 0, :comments => "Test ..", :approval_status => 1})

    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end


  # Need to modify the query for this test to pass, So i am ignoring this test.
  def test_ml_recurring_with_ca_rs_cua_near_the_start_of_hour_and_without_actual_session_records_for_same_week
    coach = FactoryGirl.create(:coach,:user_name => "newcoach1",:full_name => "new coach",:active => true, :rs_email => "newcoach1@rs.com")
    date  = "2025-01-01 00:00:00".to_time # (Sending as UTC Time)
    lang = Language['ARA']
    coach_availability_template = coach.availability_templates.create({:label => "ActiveTemplate", :effective_start_date => date.to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template.availabilities.create({:day_index => "3", :start_time => "00:00", :end_time => "01:00"})
    create_recurring_session(coach, date, lang)
    coach.availability_modifications.create({:start_date => "2025-01-08 00:15:00".to_time, :end_date => "2025-01-08 01:15:00".to_time, :unavailability_type => 0, :comments => "Test ..", :approval_status => 1})

    recurring_data_for_the_week = CoachRecurringSchedule.fetch_for("2025-01-05 00:00:00".to_time, "2025-01-11 23:59:00".to_time, lang.id, 'all')
    assert_equal 0, recurring_data_for_the_week.count
  end

  def test_ml_recurring_with_ca_rs_and_without_cua_and_actual_session_records_for_same_week
    coach = create_coach_with_qualifications('newcoach', ['ARA1', 'ARA2'])
    date  = (Time.now + 1.year).beginning_of_week # (Sending as UTC Time)
    lang1 = Language['ARA1']
    lang2 = Language['ARA2']
    coach_availability_template_1 = coach.availability_templates.create!({:label => "ActiveTemplateESP", :effective_start_date => (date-1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template_1.availabilities.create({:day_index => "3", :start_time => "00:00:00", :end_time => "01:00:00"})

    coach_availability_template_2 = coach.availability_templates.create!({:label => "ActiveTemplateGRK", :effective_start_date => (date-2.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template_2.availabilities.create({:day_index => "3", :start_time => "00:30:00", :end_time => "01:30:00"})

    FactoryGirl.create(:coach_recurring_schedule, :start_time => "00:00:00", :day_index => 3, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => lang1.id)
    create_recurring_session(coach, date, lang1)

    recurring_data_for_the_week_esp = CoachRecurringSchedule.fetch_for(date-1.week, date, lang1.id, "all")
    assert_equal 1                              , recurring_data_for_the_week_esp.size
    assert_equal coach.id                       , recurring_data_for_the_week_esp[0].coach_id
    assert_equal date-1.week  , recurring_data_for_the_week_esp[0].recurring_start_date
    assert_equal nil                            , recurring_data_for_the_week_esp[0].recurring_end_date
    assert_equal lang1.id                       , recurring_data_for_the_week_esp[0].language_id
    assert_equal nil                            , recurring_data_for_the_week_esp[0].external_village_id

    recurring_data_for_the_week_grk = CoachRecurringSchedule.fetch_for(date-1.week, date, lang2.id, "all")
    assert_equal 0, recurring_data_for_the_week_grk.count
  end

  def test_ml_recurring_with_ca_rs_and_without_cua_and_actual_session_records_for_same_week_on_last_hour_of_day_for_00_start_time
    coach = create_coach_with_qualifications('newcoach', ['ARA1', 'ARA2'])
    date  = (Time.now + 1.year).beginning_of_week # (Sending as UTC Time)
    lang1 = Language['ARA1']
    lang2 = Language['ARA2']
    coach_availability_template_1 = coach.availability_templates.create!({:label => "ActiveTemplateESP", :effective_start_date => (date-1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template_1.availabilities.create({:day_index => "6", :start_time => "23:00:00", :end_time => "00:00:00"})
    coach_availability_template_2 = coach.availability_templates.create!({:label => "ActiveTemplateGRK", :effective_start_date => (date-2.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template_2.availabilities.create({:day_index => "6", :start_time => "23:30:00", :end_time => "00:30:00"})
    FactoryGirl.create(:coach_recurring_schedule, :start_time => "23:00:00", :day_index => 6, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => lang1.id)
    create_recurring_session(coach, date, lang1)
    
    recurring_data_for_the_week_esp = CoachRecurringSchedule.fetch_for(date -1.week, date, lang1.id, 'all')
    assert_equal 1                              , recurring_data_for_the_week_esp.size
    assert_equal coach.id                       , recurring_data_for_the_week_esp[0].coach_id
    assert_equal date-1.week , recurring_data_for_the_week_esp[0].recurring_start_date
    assert_equal nil                            , recurring_data_for_the_week_esp[0].recurring_end_date
    assert_equal lang1.id                       , recurring_data_for_the_week_esp[0].language_id
    assert_equal nil                            , recurring_data_for_the_week_esp[0].external_village_id

    recurring_data_for_the_week_grk = CoachRecurringSchedule.fetch_for(date -1.week, date, lang2.id, 'all')
    assert_equal 0, recurring_data_for_the_week_grk.count
  end

  def test_ml_recurring_with_ca_rs_and_without_cua_and_actual_session_records_for_same_week_on_last_hour_of_day_for_30_start_time
    coach = create_coach_with_qualifications('newcoach', ['ARA1', 'ARA2'])
    date  = (Time.now + 1.year).beginning_of_week # (Sending as UTC Time)
    lang1 = Language['ARA1']
    lang2 = Language['ARA2']
    coach_availability_template_1 = coach.availability_templates.create!({:label => "ActiveTemplateESP", :effective_start_date => (date - 1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template_1.availabilities.create({:day_index => "6", :start_time => "23:00", :end_time => "00:00"})
    coach_availability_template_2 = coach.availability_templates.create!({:label => "ActiveTemplateGRK", :effective_start_date => (date - 2.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template_2.availabilities.create({:day_index => "6", :start_time => "23:30", :end_time => "00:30"})
    FactoryGirl.create(:coach_recurring_schedule, :start_time => "23:00:00", :day_index => 6, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => lang2.id)
    create_recurring_session(coach, date, lang2)
    recurring_data_for_the_week_grk = CoachRecurringSchedule.fetch_for(date-1.week, date, lang2.id, 'all')
  
    assert_equal 1                              , recurring_data_for_the_week_grk.count
    assert_equal coach.id                       , recurring_data_for_the_week_grk[0].coach_id
    assert_equal date-1.week  , recurring_data_for_the_week_grk[0].recurring_start_date
    assert_equal nil                            , recurring_data_for_the_week_grk[0].recurring_end_date
    assert_equal lang2.id                       , recurring_data_for_the_week_grk[0].language_id
    assert_equal nil                            , recurring_data_for_the_week_grk[0].external_village_id

    recurring_data_for_the_week_esp = CoachRecurringSchedule.fetch_for(date-1.week, date, lang1.id, 'all')
    assert_equal 0, recurring_data_for_the_week_esp.count
  end

  def test_sl_recurring_with_ca_rs_and_without_cua_and_actual_session_records_for_same_week_on_last_four_hours
    coach = create_coach_with_qualifications('newcoach', ['ARA1'])
    lang = Language['ARA1']
    date  = "2025-11-10 00:00:00".to_time # (Sending as UTC Time)
   
    FactoryGirl.create(:coach_recurring_schedule, :start_time => "06:00:00", :day_index => 1, :coach_id => coach.id,
        :recurring_start_date => date-1.week, :language_id => lang.id)
     
    coach_availability_template_1 = coach.availability_templates.create!({:label => "ActiveTemplateESP", :effective_start_date => (date-1.week).to_s(:db), :status => 1, :created_at => (date).to_s(:db)})
    coach_availability_template_1.availabilities.create({:day_index => "1", :start_time => "05:00:00", :end_time => "07:00:00"})
    # no recurring should be fetched when loading MS for the same week.
    recurring_data_for_the_week_esp = CoachRecurringSchedule.fetch_for("2025-11-02 05:00:00".to_time, "2025-11-09 07:00:00".to_time, lang.id, "all")
    assert_equal 0                              , recurring_data_for_the_week_esp.count
    
    recurring_data_for_the_week_esp = CoachRecurringSchedule.fetch_for(date-1.week, date, lang.id, "all")
    assert_equal 1                              , recurring_data_for_the_week_esp.count
    assert_equal coach.id                       , recurring_data_for_the_week_esp[0].coach_id
    assert_equal "2025-11-04 06:00:00"  , recurring_data_for_the_week_esp[0].schedule_time
    assert_equal lang.id                       , recurring_data_for_the_week_esp[0].language_id
    assert_equal nil                            , recurring_data_for_the_week_esp[0].external_village_id
  end

  def test_find_all_sessions_with_ids
    coach1 = FactoryGirl.create(:coach,:user_name => "newcoach1",:full_name => "new coach",:active => true, :rs_email => "newcoach1@rs.com")
    lang1 = FactoryGirl.create(:language, :identifier => 'ARA1')
    crs1 = FactoryGirl.create(:coach_recurring_schedule, :coach_id =>coach1.id, :day_index => 3, :start_time => Time.now.utc, :recurring_start_date=> Time.now.utc,:language_id => lang1.id )
    crs2 = FactoryGirl.create(:coach_recurring_schedule, :coach_id =>coach1.id, :day_index => 3, :start_time => Time.now.utc + 30.minutes, :recurring_start_date=> Time.now.utc,:language_id => lang1.id )
    crs3 = FactoryGirl.create(:coach_recurring_schedule, :coach_id =>coach1.id, :day_index => 3, :start_time => Time.now.utc + 1.hours, :recurring_start_date=> Time.now.utc,:language_id => lang1.id )
    recurring_ids = [crs1.id, crs2.id,crs3.id]
    coach_recurring_array = CoachRecurringSchedule.find_all_sessions_with_ids(recurring_ids)
    coach_recurring_array
    assert_equal 3, coach_recurring_array.length
    recurring_ids = []
    coach_recurring_array = CoachRecurringSchedule.find_all_sessions_with_ids(recurring_ids)
    assert_equal 0, coach_recurring_array.length
  end
end
