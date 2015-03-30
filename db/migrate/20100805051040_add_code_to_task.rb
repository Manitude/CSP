class AddCodeToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :code, :string
    execute "TRUNCATE TABLE tasks"
    Task.reset_column_information
    Task.create([{:name => 'Full Name',:section => 'Coach Profile',:code => 'coach_full_name'},
{:name => 'Preferred Name',:section => 'Coach Profile',:code => 'coach_preferred_name'},
{:name => 'Rosetta Stone Email',:section => 'Coach Profile',:code => 'coach_rs_email'},
{:name => 'Personal Email',:section => 'Coach Profile',:code => 'coach_personal_email'},
{:name => 'Skype ID',:section => 'Coach Profile',:code => 'coach_skype_id'},
{:name => 'Birth Date (only day and month)',:section => 'Coach Profile',:code => 'coach_birth_date'},
{:name => 'Hire Date',:section => 'Coach Profile',:code => 'hire_date'},
{:name => 'Time Zone',:section => 'Coach Profile',:code => 'coach_time_zone'},
{:name => 'Region (Seattle, DC, NYC, Remote, etc.)',:section => 'Coach Profile',:code => 'coach_region'},
{:name => 'Coach Manager',:section => 'Coach Profile',:code => 'coach_manager'},
{:name => 'Primary phone number (Add “Receive text message reminders/requests?” field)',:section => 'Coach Profile',:code => 'coach_pri_phone_no'},
{:name => 'Secondary phone number (Add “Receive text message reminders/requests” field)',:section => 'Coach Profile',:code => 'coach_sec_phone_no'},
{:name => 'Photo',:section => 'Coach Profile',:code => 'coach_photo'},
{:name => 'Bio',:section => 'Coach Profile',:code => 'coach_bio'},
{:name => 'Coach Manager Notes',:section => 'Coach Profile',:code => 'coach_manager_notes'},
{:name => 'Weekly Templates',:section => 'Coach Profile',:code => 'weekly_template'},
{:name => 'Schedule of Sessions',:section => 'Studio (Coach specific)',:code => 'schedule_of_sessions'},
{:name => 'Total # of Studio sessions allowed per week  (current)',:section => 'Studio (Coach specific)',:code => 'total_no_of_studio_session'},
{:name => 'Total # of availability modifications requested (YTD)',:section => 'Studio (Coach specific)',:code => 'total_no_of_availability_mod'},
{:name => 'Total # of availability modifications requested within 2 weeks of live events (YTD)',:section => 'Studio (Coach specific)',:code => 'total_no_of_availability_mod_requested_in_2_weeks'},
{:name => 'Total # of Studio session cancellations (YTD)',:section => 'Studio (Coach specific)',:code => 'total_no_of_studio_session_cancellations'},
{:name => 'Total # of Sessions where the Coach didn’t show up',:section => 'Studio (Coach specific)',:code => 'total_no_of_sessions_where_the_coach_not_shown_up'},
{:name => 'Post session learner feedback',:section => 'Studio (Coach specific)',:code => 'post_session_learner_feedback'},
{:name => 'Post session Coach feedback (learner evaluations)',:section => 'Studio (Coach specific)',:code => 'post_session_coach_feedback'},
{:name => 'Games that the Coach has played (Counts, Game Names, Timestamps)',:section => 'World Activity (for all associated languages tied to account)',:code => 'games_played'},
{:name => 'Total time spent in each Game',:section => 'World Activity (for all associated languages tied to account)',:code => 'time_in_game'},
{:name => 'Total time spent in World (total time all games)',:section => 'World Activity (for all associated languages tied to account)',:code => 'time_in_world'},
{:name => 'Total time spent in Language(s) (Drill down capability to view dates/times of activity)',:section => 'Course Activity (for all associated languages tied to account)', :code => 'time_in_language'},
{:name => 'High Water Mark',:section => 'Course Activity (for all associated languages tied to account)',:code => 'high_water_mark'},
{:name => 'Most Recent Path Completed',:section => 'Course Activity (for all associated languages tied to account)',:code => 'recent_path_completed'},
{:name => 'Last Access Timestamp',:section => 'Course Activity (for all associated languages tied to account)',:code => 'last_access'},
{:name => 'Product rights',:section => 'Licenses (for all associated languages tied to account)',:code => 'product_rights'},
{:name => 'License expiration date',:section => 'Licenses (for all associated languages tied to account)',:code => 'license_expiration_date'},
{:name => 'Ability to extend license subscription duration',:section => 'Licenses (for all associated languages tied to account)',:code => 'extend_license_subscription_duration'},
{:name => 'Ability to edit/add product rights',:section => 'Licenses (for all associated languages tied to account)',:code => 'ability_modify_product_rights'},
{:name => 'Ability to reset password',:section => 'Licenses (for all associated languages tied to account)',:code => 'ability_reset_password'},
{:name => 'Coach Active? (Yes/No)',:section => 'Configurable Settings',:code => 'coach_active'},
{:name => 'Language qualifications',:section => 'Configurable Settings',:code => 'language_qualifications'},
{:name => 'Level qualifications – If the Coach changes this, the CM must be notified and approve this change before implemented. ',:section => 'Configurable Settings',:code => 'level_qualifications'},
{:name => 'Name',:section => 'Learner Profile',:code => 'learner_name'},
{:name => 'Preferred Name',:section => 'Learner Profile',:code => 'learner_preferred_name'},
{:name => 'Age (birth date)',:section => 'Learner Profile',:code => 'learner_age'},
{:name => 'Gender',:section => 'Learner Profile',:code => 'learner_gender'},
{:name => 'Location',:section => 'Learner Profile',:code => 'learner_location'},
{:name => 'High water mark',:section => 'Learner Profile',:code => 'learner_high_water_mark'},
{:name => 'Studio sessions attended',:section => 'Learner Profile',:code => 'studio_sessions_attended'},
{:name => 'Studio sessions skipped',:section => 'Learner Profile',:code => 'studio_sessions_skipped'},
{:name => 'Studio sessions scheduled',:section => 'Learner Profile',:code => 'studio_sessions_scheduled'},
{:name => 'Learner Evaluations',:section => 'Learner Profile',:code => 'learner_evaluation'},
{:name => 'CST Discovery Information',:section => 'Learner Profile',:code => 'cst_discovery_information'}])
  end

  def self.down
    remove_column :tasks, :code
  end
end
