require File.dirname(__FILE__) + '/../test_helper'

class CoachScheduleTemplateTest < ActiveSupport::TestCase

  def test_validates_presence_of
    coach = FactoryGirl.create(:account, :user_name => 'coach', :type => 'Coach')
    template = FactoryGirl.build(:coach_availability_template, :coach_id => coach.id, :effective_start_date => Time.now + 1.day, :created_at => '2012-03-28', :label =>'ara0108grk',:status => 1)
    template.save
    assert_presence_required(template, :coach)
    assert_presence_required(template, :label)
    assert_presence_required(template, :effective_start_date)
  end

  def test_should_merge_two_templates
    beginning_of_week = '2012-08-27'.to_time
    coach = create_a_coach
    template1 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, 
      :deleted => 0, :status => 1, :coach_id => coach.id, :label => 'template1')
    template1.update_attribute('effective_start_date', '2012-08-12'.to_time - 10.days)
    FactoryGirl.create(:coach_availability, :coach_availability_template => template1, :day_index => 2, :start_time => '15:30:00')
    FactoryGirl.create(:coach_availability, :coach_availability_template => template1, :day_index => 5, :start_time => '18:30:00')
    template2 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day,
      :deleted => 0, :status => 1, :coach_id => coach.id, :label => 'template2')
    template2.update_attribute('effective_start_date', '2012-08-29'.to_time)
    FactoryGirl.create(:coach_availability, :coach_availability_template => template2, :day_index => 5, :start_time => '16:30:00')

    availabilities = CoachAvailability.availability_for_week(beginning_of_week, beginning_of_week + 7.days, coach)
    assert_include(availabilities.collect(&:start_time), '2000-01-01 16:30:00'.to_time)
    assert_equal(2, availabilities.size)
  end

  def test_should_merge_two_templates_with_availability_range
    beginning_of_week = '2012-08-27'.to_time
    coach = create_a_coach
    template1 = FactoryGirl.create(:coach_availability_template, :effective_start_date => '2025-08-05'.to_time - 10.days,
      :deleted => 0, :status => 1, :coach_id => coach.id, :label => 'template1')
    FactoryGirl.create(:coach_availability, :coach_availability_template => template1, :day_index => 2, :start_time => '15:30:00')
    FactoryGirl.create(:coach_availability, :coach_availability_template => template1, :day_index => 5, :start_time => '18:30:00')
    template2 = FactoryGirl.create(:coach_availability_template, :effective_start_date => '2025-08-05'.to_time,
      :deleted => 0, :status => 1, :coach_id => coach.id, :label => 'template2')
    FactoryGirl.create(:coach_availability, :coach_availability_template => template2, :day_index => 5, :start_time => '16:30:00')

    availabilities = CoachAvailability.availability_for_week("2025-08-06 04:00:00","2025-08-11 04:00:00", coach)
    assert_include(availabilities.collect(&:start_time), '2000-01-01 16:30:00'.to_time)
    assert_equal(2, availabilities.size)
  end

  def test_should_merge_two_templates_considering_start_end_time
    beginning_of_week = '2012-08-27'.to_time
    coach = create_a_coach

    template1 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, :deleted => 0, :status => 1, :coach_id => coach.id, :label => 'template1')
    template1.update_attribute('effective_start_date', '2012-08-12'.to_time - 10.days)
    FactoryGirl.create(:coach_availability, :coach_availability_template => template1, :day_index => 2, :start_time => '15:30:00')
    FactoryGirl.create(:coach_availability, :coach_availability_template => template1, :day_index => 5, :start_time => '18:30:00')

    template2 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, :deleted => 0, :status => 1, :coach_id => coach.id, :label => 'template2')
    template2.update_attribute('effective_start_date', '2012-08-29'.to_time)

    FactoryGirl.create(:coach_availability, :coach_availability_template => template2, :day_index => 5, :start_time => '16:30:00')

    template3 = FactoryGirl.create(:coach_availability_template, :effective_start_date =>  Time.now + 1.day,
      :deleted => 0, :status => 1, :coach_id => coach.id, :label => 'template3')
    template3.update_attribute('effective_start_date', '2012-09-29'.to_time)

    FactoryGirl.create(:coach_availability, :coach_availability_template => template3, :day_index => 4, :start_time => '14:30:00')

    availabilities = CoachAvailability.availability_for_week(beginning_of_week, beginning_of_week + 7.days, coach)

    assert_include(availabilities.collect(&:start_time), '2000-01-01 16:30:00'.to_time)
    assert_equal(2, availabilities.size)
  end

  def test_effective_start_date_starts_in_future
    coach = Coach.find_by_user_name('jramanathan')
    template = CoachAvailabilityTemplate.new(:effective_start_date => Time.now, :label => 'test_template')
    template.coach = coach
    assert !template.save
    # assert_equal 'should be a date in future', template.errors.on(:effective_start_date)
  end

  def test_length_of_label

    created_coach = Coach.find_by_user_name('jramanathan').present? ? Coach.find_by_user_name('jramanathan') : FactoryGirl.create(:account,:user_name => "jramanathan",:full_name => "jramanathan",:active => true, :rs_email => "jramanathan@rs.com", :type => "Coach")
    coach = Coach.find(created_coach.id)
    template = CoachAvailabilityTemplate.new(:effective_start_date => Time.now+10.week, :label => 'test_template', :coach_id => coach.id)
    template.coach = coach  
    assert template.valid?
    template.label = 'te'
    assert !template.valid?
    assert template.errors[:label].any?
    template.label = 'tes'
    assert template.valid?
    assert !template.errors[:label].any?
  end

  def test_uniqueness_of_label_for_a_coach
    coach = FactoryGirl.create(:account, :user_name => 'coach', :type => 'Coach')
    template = FactoryGirl.build(:coach_availability_template, :coach_id => coach.id, :effective_start_date => Time.now + 1.hour, :created_at => '2012-03-28', :label =>'ara0108grk',:status => 1)
    dup_template = CoachAvailabilityTemplate.new(:label => template.label, :effective_start_date => Time.now + 1.day, :coach_id => template.coach_id)
    template.save
    assert template.valid?
    assert !dup_template.valid?
    dup_template.label = "new_label"
    assert dup_template.valid?
  end

  def test_uniqueness_of_start_date_for_a_template_despite_different_start_time
    coach = FactoryGirl.create(:account, :user_name => 'coach', :type => 'Coach')
    template = FactoryGirl.build(:coach_availability_template, :coach_id => coach.id, :effective_start_date => Time.now + 1.hour, :created_at => '2012-03-28', :label =>'ara0108grk',:status => 1)
    dup_template = FactoryGirl.build(:coach_availability_template, :coach_id => coach.id, :effective_start_date => template.effective_start_date + 1.second , :created_at => '2012-03-28', :label =>'ara0108grk1',:status => 1)
    template.save
    dup_template.save
    assert template.valid?
    assert !dup_template.valid?
    assert_equal ['already exists for another template'], dup_template.errors[:effective_start_date]
    dup_template.effective_start_date = dup_template.effective_start_date+1.day
    assert dup_template.valid?
  end

  def test_should_return_coaches_with_templates_switch_in_week
    coach = FactoryGirl.create(:account, :user_name => 'coach', :type => 'Coach')
    template = FactoryGirl.build(:coach_availability_template, :coach_id => coach.id, :effective_start_date => "2025-08-07 04:00:00", :created_at => '2012-03-28', :label =>'ara0108grk',:status => 1)
    template.save
    coach_ids = CoachAvailabilityTemplate.coaches_with_template_switch_in_week("2025-08-06 04:00:00","2025-08-11 04:00:00")
    assert_equal 1,coach_ids.size
  end

  def test_create_availability_entries_for_template
    coach = FactoryGirl.create(:account, :user_name => 'coach', :type => 'Coach')
    template = FactoryGirl.build(:coach_availability_template, :coach_id => coach.id, :effective_start_date => "2025-02-12 04:00:00", :created_at => '2012-03-28', :label =>'ara0108grk',:status => 1)
    template.save
    availabilities = {"1" => {"start" => ("2012-09-18 21:00:00".to_time.to_i)*1000, "end" => ("2012-09-19 02:00:00".to_time.to_i)*1000},
                      "2" => {"start" => ("2012-09-20 00:00:00".to_time.to_i)*1000, "end" => ("2012-09-20 02:00:00".to_time.to_i)*1000},
                      "3" => {"start" => ("2012-09-21 00:00:00".to_time.to_i)*1000, "end" => ("2012-09-21 05:00:00".to_time.to_i)*1000},
                      "4" => {"start" => ("2012-09-20 23:00:00".to_time.to_i)*1000, "end" => ("2012-09-21 05:00:00".to_time.to_i)*1000}}
    template.create_availability_entries_for_template(availabilities, true)

    availabilities_for_week = CoachAvailability.find_all_by_coach_availability_template_id(template.id)
    assert_equal availabilities_for_week.size, 6
  end

end
