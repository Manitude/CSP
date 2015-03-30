require File.expand_path('../../test_helper', __FILE__)

class NotificationMessageDynamicsTest < ActiveSupport::TestCase

  def test_get_msg_str_for_not_email
    coach = create_coach_with_qualifications
    udt = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id)
    notif = FactoryGirl.create(:notification, :trigger_event_id => 6, :message => 'has requested time off from to .', :target_type => 'UnavailableDespiteTemplate')
    FactoryGirl.create(:notification_recipient, :notification_id => notif.id, :name => 'Coach Manager', :rel_recipient_obj => 'all_managers')
    NotificationMessageDynamic.delete_all
    nmd = FactoryGirl.create(:notification_message_dynamic, :notification_id => notif.id, :name => 'Coach Name', :msg_index => 0, :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    
    #not for email
    str = nmd.get_msg_str(udt)
    assert_not_nil(str)
    assert_false str.include?("http://coachportal.rosettastone.com")
  
    #for email
    str = nmd.get_msg_str(udt, true)
    assert_not_nil(str)
    assert_true str.include?("http://coachportal.rosettastone.com")
  end

  def test_notification_should_show_advanced_english_instead_of_kle
    language = Language.find_by_identifier('KLE')
    Substitution.any_instance.expects(:language).returns(language)
    notif = FactoryGirl.create(:notification, :trigger_event_id => 10, :message => 'Your Studio Session on has been canceled.', :target_type => 'Substitution')
    nmd = NotificationMessageDynamic.find_by_id(15)
    nmd = FactoryGirl.create(:notification_message_dynamic, :notification_id => notif.id, :name => 'Language identifier', :msg_index => 0, :rel_obj_type => 'language', :rel_obj_attr => 'identifier')
    FactoryGirl.create(:notification_recipient, :notification_id => notif.id, :name => 'Coach', :rel_recipient_obj => 'coach')
    assert_equal "<b>Advanced English</b> ", nmd.get_msg_str(Substitution.new)
  end

  def test_linking_to_coach_profile
    coach = create_coach_with_qualifications
    start_date = Time.now.beginning_of_hour.utc + 2.hour
    udt = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => start_date, :end_date => start_date + 2.hours, :comments => "test")
    notif = FactoryGirl.create(:notification, :trigger_event_id => 6, :message => 'has requested time off from to .', :target_type => 'UnavailableDespiteTemplate')
    FactoryGirl.create(:notification_recipient, :notification_id => notif.id, :name => 'Coach Manager', :rel_recipient_obj => 'all_managers')
    NotificationMessageDynamic.delete_all
    nmd = FactoryGirl.create(:notification_message_dynamic, :name => 'Coach Name', :notification_id => notif.id, :msg_index => 0, :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    assert_equal("<a href = '/view-coach-profiles?coach_id=#{coach.id}'>#{coach.name}</a> ", nmd.get_msg_str(udt))
  end

  def test_linking_to_coach_availability_template
    coach = create_coach_with_qualifications
    template = FactoryGirl.create(:coach_availability_template, :coach_id => coach.id, :effective_start_date => (Time.now + 5.day).to_date, :label => "test")
    NotificationMessageDynamic.delete_all
    nmd = FactoryGirl.create(:notification_message_dynamic, :notification_id => 14, :name => 'Template Name', :msg_index => 0, :rel_obj_attr => 'label')
    assert_equal("<a href = '/availability/#{coach.id}/#{template.id}'>#{template.label}</a> ", nmd.get_msg_str(template))
  end

end
