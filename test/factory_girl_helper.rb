# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'factory_girl'

FactoryGirl.define do

  factory :account do |accounts|
    accounts.user_name {"test#{rand(1000)}"}
    accounts.full_name 'test'
    accounts.preferred_name 'test'
    accounts.rs_email {"user_#{rand(1000).to_s}@factory.com" }
    accounts.type 'CoachManager'
    accounts.bio nil
    accounts.primary_phone  '5402334456'
    accounts.primary_country_code '1'
    accounts.mobile_country_code '1'
    accounts.native_language 'en-US'
    accounts.lotus_qualified true
    accounts.active true
  end

  factory :coach, :parent => :account, :class => 'Coach' do |coach|
    coach.type 'Coach'
  end

  factory :background_task do |bt|
    bt.referer_id nil
    bt.triggered_by nil
    bt.background_type nil
    bt.state nil
    bt.locked true
    bt.job_start_time Time.now.utc
    bt.message "Task enqueued."
  end

  factory :cm_preference do |cp|
    cp.account_id nil
    cp.receive_reflex_sms_alert false
  end

  factory  :qualification do |ca|
    ca.coach_id nil
    ca.language_id nil
    ca.max_unit nil
  end

  factory :application_configuration do |ac|
    ac.setting_type nil
    ac.value nil
    ac.data_type nil
    ac.display_name nil
  end

  factory  :language do |l|
    l.identifier 'ARA'
    l.type "TotaleLanguage"
  end

 factory :aria_language, :parent => :language, :class => 'AriaLanguage' do |l|
    l.type 'AriaLanguage'
    l.identifier 'AUS'
 end

 factory :totale_language, :parent => :language, :class => 'TotaleLanguage' do |l|
    l.type 'TotaleLanguage'
    l.identifier 'ARA'
 end

 factory :reflex_language, :parent => :language, :class => 'ReflexLanguage' do |l|
    l.type 'ReflexLanguage'
    l.identifier 'KLE'
 end

  factory :shown_substitutions do |ss|
    ss.coach_id nil
  end

  factory  :excluded_coaches_session do |ecs|
    ecs.coach_id nil
    ecs.coach_session_id nil
  end

  factory :coach_session do |session|
    session.coach_id 18
    session.session_start_time (Time.now.beginning_of_hour.utc + 2.hours)
    session.session_end_time nil
    session.number_of_seats 0
    session.single_number_unit 1
    session.eschool_session_id nil
    session.cancelled 0
    session.language_identifier 'ENG'
    session.coach_showed_up 0
    session.topic_id nil
  end

  factory :local_session, :parent => :coach_session, :class => 'LocalSession' do |session|
    session.type 'LocalSession'
  end
 
 factory :confirmed_session, :parent => :coach_session, :class => 'ConfirmedSession' do |session|
    session.type 'ConfirmedSession'
 end

 factory :global_setting do |global_setting|
    global_setting.attribute_name "allow_session_creation_after"
    global_setting.description "Allowed time in minutes after session start time that a session can be created"
    global_setting.attribute_value "29" 
 end

 factory :extra_session, :parent => :coach_session, :class => 'ExtraSession' do |session|
    session.type 'ExtraSession'
    session.coach_id nil
 end
 
  factory :session_metadata do |session_metadata|
    session_metadata.coach_session_id 123
    session_metadata.teacher_confirmed nil
    session_metadata.lessons nil
    session_metadata.recurring false
    session_metadata.action 'create'
  end

  factory :substitution do |substitution|
    substitution.coach_id nil
    substitution.grabber_coach_id nil
    substitution.grabbed 0
    substitution.coach_session_id nil
    substitution.created_at nil
    substitution.updated_at nil
    substitution.cancelled 0
    substitution.was_reassigned nil
  end

  factory :unavailable_despite_template do |unavailable|
    unavailable.coach_id nil
    unavailable.start_date (Time.now.beginning_of_hour.utc + 2.hours)
    unavailable.end_date nil
    unavailable.unavailability_type 0
    unavailable.approval_status 0
    unavailable.comments 'test comment'
  end

  factory :learner do |learner|
    learner.first_name 'first'
    learner.last_name 'last'
    learner.guid '419og-ds885-hj98l'
    learner.village_id nil
    learner.user_source_type 'Community::User'
    learner.learner_product_rights { |right| [right.association(:learner_product_right)]}
  end

  factory :learner_product_right do |rights|
    rights.language_identifier 'SPA'
    rights.learner_id nil
    rights.product_guid nil
    rights.activation_id nil
  end

  factory :coach_availability_template do |cat|
    cat.coach_id nil
    cat.effective_start_date nil
    cat.status TEMPLATE_STATUS.index('Approved')
    cat.deleted false
    cat.label {next(:label)}
  end

  factory  :coach_availability do |ca|
    ca.association :coach_availability_template, :factory => :coach_availability_template
    ca.coach_availability_template_id nil
    ca.day_index 1
    ca.start_time '00:00:00'
    ca.end_time '01:00:00'
  end

  factory :scheduler_metadata do |sm|
    sm.lang_identifier "ARA"
    sm.total_sessions 0
    sm.completed_sessions 0
    sm.total_sessions_to_be_created 0
    sm.successfully_created_sessions 0
    sm.error_sessions 0
    sm.locked 0
  end

  factory :reflex_activity do |ra|
    ra.coach_id 32
    ra.timestamp Time.now
  end

  factory :master_scheduler_bulk_data do |ms|
    ms.language_identifier "ARA"
    ms.start_of_the_week Time.now.utc.beginning_of_week
    ms.bulk_data {}
  end

  factory :community_user, :class => Community::User do |cu|
    cu.first_name 'raj-community'
    cu.last_name 'kumar-community'
    cu.email 'raj.kumar@community.com'
    cu.preferred_name 'Kumar, Raj'
    cu.mobile_number '9123456789'
    cu.village_id 10
    cu.guid 'community-guid'
    cu.gender 'male'
    cu.birth_date '1985-12-18'
    cu.city 'Chennai'
    cu.country_iso 356
    cu.state_province 'Tamilnadu'
    cu.time_zone 'Eastern Time (US & Canada)'
  end

  factory :viper_user, :class => RsManager::User do |cu|
    cu.first_name 'raj-viper'
    cu.last_name 'kumar-viper'
    cu.email_address 'raj.kumar@viper.com'
    cu.guid 'viper-guid'
  end

  factory :product_right, :class => LicenseServer::ProductRight do |pr|
    pr.license_id nil
    pr.product_id nil
    pr.activation_id nil
    pr.guid nil
  end

  factory :product, :class => LicenseServer::Product do |p|
    p.identifier nil
  end

  factory :license, :class => LicenseServer::License do |p|
    p.guid nil
  end

  factory :staffing_data do |data|
    data.number_of_coaches 10
    data.staffing_file_info_id 1
  end

  factory :staffing_file_info do |info|
    info.start_of_the_week Date.today.beginning_of_week - 1.day
    info.file_name "test.csv"
    info.manager_id 1
    info.status "Processing"
    info.file ""
  end

  factory :product_language_log do |log|
    log.support_user_id nil
    log.license_guid nil
    log.product_rights_guid nil
    log.previous_language nil
    log.changed_language "ARA"
    log.reason "Every thing is happening for some reasons"
  end

  factory :language_scheduling_threshold do |threshold|
    threshold.language_id nil
    threshold.max_assignment 30
    threshold.max_grab 30
    threshold.hours_prior_to_sesssion_override 1
  end

  factory :region do |region|
    region.name "DC"
  end

  factory :link do |link|
    link.name "Test-Link"
    link.url "Test-URL"
   end  
  factory :coach_recurring_schedule do |schedule|
    schedule.coach_id nil
    schedule.day_index nil
    schedule.start_time nil
    schedule.recurring_start_date Time.now - 15.days
    schedule.recurring_end_date nil
    schedule.language_id nil
    schedule.external_village_id nil
  end

  factory :event do |event|
    event.event_description "Test event - desc"
    event.event_name "Test event"
    event.event_start_date Time.now.beginning_of_hour + 1.day
    event.event_end_date Time.now.beginning_of_hour + 2.days
    event.language_id -1
    event.region_id -1
  end

  factory :announcement do |an|
    an.body "testing"
    an.subject "test"
    an.expires_on Time.now.utc + 2.days
    an.language_id -1
    an.region_id -1
    an.language_name 'English'
  end

  factory :preference_setting do |pf|
      pf.notifications_email "1"
      pf.notifications_email_type "RS"
      pf.notifications_email_sending_schedule "IMMEDIATELY"
      pf.substitution_alerts_email "1"
      pf.substitution_alerts_email_type "RS"
      pf.substitution_alerts_email_sending_schedule "IMMEDIATELY"
      pf.calendar_notices_email "1"
      pf.calendar_notices_email_type "RS"
      pf.calendar_notices_email_sending_schedule "IMMEDIATELY"
      pf.substitution_alerts_sms "1"
      pf.coach_not_present_alert "1"
      pf.session_alerts_display_time "20"
  end

  factory :notification_recipient do |nr|
    nr.notification_id nil
    nr.name nil
    nr.rel_recipient_obj nil
  end

  factory :notification_message_dynamic do |nmd|
    nmd.notification_id nil
    nmd.msg_index nil
    nmd.name nil
    nmd.rel_obj_type nil
    nmd.rel_obj_attr nil
  end

  factory :system_notification do |sn|
    sn.notification_id nil
    sn.recipient_id nil
    sn.recipient_type nil
    sn.target_id nil
  end

  factory :support_language do |sl|
    sl.name 'English'
    sl.language_code 'en-US'
  end

  factory :trigger_event do |te|
    te.name nil
    te.description nil
  end

  factory :notification do |n|
    n.trigger_event_id nil
    n.message nil
    n.target_type nil
  end

  factory :management_team_member do |n|
    n.name nil
    n.title nil
    n.phone_cell nil
    n.phone_desk nil
    n.email nil
    n.image_file_name nil
    n.image_content_type nil
    n.image_file_size nil
    n.image_file nil
    n.hide nil
  end


  factory :resource do |r|
    r.title nil
    r.description nil 
    r.size nil       
    r.content_type nil
    r.filename nil    
    r.db_file_id nil
  end

  factory :box_link do |r|
    r.title "Folder#{Time.now}"
    r.url "https://app.box.com/embed_widget/eafbff29c305/s/oi3tq6j#{Time.now}f0mcl8j8ai?view=list&sort=name&direction=ASC&theme=blue"
  end

  factory :topic do |topic|
    topic.title "Test topic title"
    topic.cefr_level "C1"
    topic.description "Test topic description"
    topic.language 685445102
    topic.selected true
    topic.removed false
    topic.guid "id-1"
  end

end
