require File.dirname(__FILE__) + '/../test_helper'

class GeneralMailerTest < ActionMailer::TestCase

  def test_substitutions_email
    # Send the email, then test that it got queued
    options_hash = {
      :coach_id => "27490237",
      :lang_id => "39274832",
      :is_manager => true,
      :message => "This is a sample message for e-mail.",
      :recipients => ["arunkumar.jayakodi@listertechnologies.com"],
      :datetime => "Advanced English Substitute Needed: 12:00 AM Fri Sep 23 2011"
    }
    email = GeneralMailer.substitutions_email(options_hash).deliver
    assert_true !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal options_hash[:recipients], email.to
    assert_true email.subject.include?("Sub Alert:")
    assert_match /To Re-assign\/Cancel any listed session, go to/ , email.body
  end

  def test_send_mail_to_coaches
   
    body = "This is a sample message for e-mail."
    to = ["preethi.baskar@listertechnologies.com", "arunkumar.jayakodi@listertechnologies.com"]
    subject = "Hello"
    email = GeneralMailer.send_mail_to_coaches(subject,to,body).deliver
    assert_true !ActionMailer::Base.deliveries.empty?
    assert_equal to, email.to
    assert_equal ["RSStudioTeam-Supervisors-l@rosettastone.com"], email.from
    assert_true email.body.include?("This is a")

  end
  
  def test_email_alert_hourly_and_daily_for_substitutions
    sub_hash = {
      :daily_cap=>12,
      :pref_id=>"1",
      :mails_sent=>1,
      :lang_identifiers=>["ARA", "CHI", "DEU", "KLE"],
      :sub_details=>[{:learners_signed_up=>"NA", :coach=> 'newcoach', :language=>Language.find_by_identifier("KLE"), :subsitution_date=>"Fri, 23 Sep 2011 00:00:00 EDT -04:00", :unit=>"N/A", :level=>"N/A", :sub_id=>10}, {:learners_signed_up=>"NA", :coach=>"KLE coach", :language=>Language.find_by_identifier("KLE"), :subsitution_date=>"Fri, 23 Sep 2011 01:00:00 EDT -04:00", :unit=>"N/A", :level=>"N/A", :sub_id=>11}, {:learners_signed_up=>"YES(1)", :coach=>"chinese_coach", :language=>Language.find_by_identifier("CHI"), :subsitution_date=>"Mon, 19 Sep 2011 05:00:00 EDT -04:00", :unit=>1, :level=>1, :sub_id=>12}, {:learners_signed_up=>"YES(1)", :coach=>"chinese_coach", :language=>Language.find_by_identifier("CHI"), :subsitution_date=>"Mon, 19 Sep 2011 06:00:00 EDT -04:00", :unit=>1, :level=>1, :sub_id=>13}],
      :sub_ids=>"12,13,10,11,",
      :name=>"ara_test",
      :id=>2,
      :email=>"ara_test@personal.com",
      :type => 'CoachManager'
    }
    sub_subject = 'Sub Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s
    email = GeneralMailer.email_alert_hourly_and_daily('sub_alert',sub_subject,sub_hash[:sub_details],sub_hash[:email],'CoachManager').deliver
    assert_true !ActionMailer::Base.deliveries.empty?
    assert_true email.subject.include?('Sub Alert:')
    assert_true email.body.include?('Substitute Needed:')
    
    email2 = nil
    sub_hash[:mails_sent] = 12
    if (sub_hash[:sub_details].size >= 0 && (sub_hash[:mail_sent] && sub_hash[:daily_cap] && (sub_hash[:mails_sent] < sub_hash[:daily_cap])))
    email2 = GeneralMailer.email_alert_hourly_and_daily('event',sub_subject,sub_hash[:sub_details],sub_hash[:email]).deliver
    end
    assert_nil email2
  end

  def test_email_alert_hourly_and_daily_for_notifications
    noti_hash = {
      :daily_cap=>10,
      :pref_id=>"1",
      :notifications=>"Your requested time off from <b>September 21, 2011  6:30 AM</b> to <b>September 21, 2011  7:30 AM</b> has been approved .#",
      :mails_sent=>1,
      :name=>"ara_test",
      :id=>2,
      :email=>"ara_test@rs.com",
      :type => 'Coach'
      }
    noti_subject = 'Notifications:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s
    str_array = noti_hash[:notifications].split('#')
    email = GeneralMailer.email_alert_hourly_and_daily('notification',noti_subject,str_array,noti_hash[:email],noti_hash[:type]).deliver
    assert_true !ActionMailer::Base.deliveries.empty?
    assert_true email.subject.include?('Notifications:')
    assert_true email.body.include?('Your requested time off from <b>September 21, 2011  6:30 AM</b> to <b>September 21, 2011  7:30 AM</b> has been approved .')
  end

  def test_email_alert_hourly_and_daily_for_calendar_events
    event_hash = {
        :lang_identifiers=>["ARA", "CHI", "DEU", "KLE"],
        :daily_cap=>17,
        :pref_id=>"1",
        :event_ids=>"2,1",
        :mails_sent=>8,
        :name=>"ara_test",
        :id=>2,
        :email=>"ara_test@rs.com",
        :type => 'Coach'
        }
    event_subject = 'Event Alerts:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s
    event = FactoryGirl.create(:event)
    email = GeneralMailer.email_alert_hourly_and_daily('event', event_subject, event.to_a, event_hash[:email], event_hash[:type]).deliver
    assert_true !ActionMailer::Base.deliveries.empty?
    assert_true email.subject.include?('Event Alerts:')
    assert_true email.body.include?("#{event.event_name} from #{TimeUtils.format_time(event.event_start_date, "%b %d, %Y")} to #{TimeUtils.format_time(event.event_end_date, "%b %d, %Y")} description: #{event.event_description}")
  end

  def test_notifications_email
    recipient = "kaarthik.palraj@listertechnologies.com"
    email = GeneralMailer.notifications_email("Some message", recipient).deliver
    assert_true !ActionMailer::Base.deliveries.empty?
    assert_equal [recipient], email.to
    assert_equal 'Notification Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s, email.subject
    assert_true email.body.include?('RosettaStone has the following notifications:')
  end

  def test_calendar_notifications_email
    event = FactoryGirl.create(:event)
    recipient = "kaarthik.palraj@listertechnologies.com"
    email = GeneralMailer.calendar_notifications_email(event, recipient).deliver
    assert_true !ActionMailer::Base.deliveries.empty?
    assert_equal [recipient], email.to
    assert_equal 'Calendar Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s, email.subject
    assert_true email.body.include?('RosettaStone has the following events:')
  end
end
