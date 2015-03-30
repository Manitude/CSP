CoachPortal::Application.routes.draw do
  resources :appointment_types

  resources :topics

  resources :box_links

  match '/search_result' => 'extranet/learners#search_result', :as => :search_result
  match 'show_events_by_date/:event_date' => 'extranet/events#show_events_by_date'
  match 'homes/:action' => 'extranet/homes#(?i-mx:[a-z_]+)'
  match '/learner_details' => 'extranet/learners#learner_details', :as => :learner_details
  match '/show_reason_in_sub_report' => 'substitution#show_reason_in_sub_report', :as => :show_reason_in_sub_report
  match '/consumables_report' => 'support_user_portal/licenses#consumables_report', :as => :consumables_report
  match '/grandfathering_report' => 'support_user_portal/licenses#grandfathering_report', :as => :grandfathering_report
  match '/get_grandfathering_report' => 'support_user_portal/licenses#get_grandfathering_report'
  match '/download_grandfathering_report_csv' => 'support_user_portal/licenses#download_grandfathering_report_csv'
  match 'save_topics' => 'topics#save_topics', :as => :save_topics
  match 'fetch_topics' => 'topics#fetch_topics', :as => :fetch_topics
  scope :module => "extranet" do
    match 'learners/my_calendar' => 'learners#my_calendar'
    match 'events/calendar' => 'events#calendar'
    resources :learners
    resources :homes
    resources :roles
    resources :links
    resources :events
    resources :announcements
    resources :resources
    match 'learners/:action' => 'learners#(?i-mx:[a-z_]+)'
    match 'announcements/:action' => 'announcements#(?i-mx:[a-z_]+)'
    match 'events/:action' => 'events#(?i-mx:[a-z_]+)'
    match 'roles/:action' => 'roles#(?i-mx:[a-z_]+)'
    match 'links/:action' => 'links#(?i-mx:[a-z_]+)'
    match '/profile' => 'homes#view_profile', :as => :profile
    match 'homes/audit_logs' => 'homes#audit_logs', :as => :home_audit_logs
    match 'homes/track_users' => 'homes#track_users', :as => :home_track_users
    match 'homes/admin_dashboard' => 'homes#admin_dashboard', :as => :home_admin_dashboard
    match 'homes/release_lock' => 'homes#release_lock', :as => :home_release_lock
    match 'homes/simulate_delayed_job' => 'homes#simulate_delayed_job', :as => :home_simulate_delayed_job
    match 'homes/set_global_settings' => 'homes#set_global_settings', :as => :home_set_global_settings
    match 'selected_learner_chat_history' => 'learners#selected_learner_chat_history', :as => :selected_chat_history
    match 'detailed_chat_history' => 'learners#detailed_chat_history', :as => :detailed_chat_history
    resources :regions
    match 'regions/:action' => 'regions#(?i-mx:[a-z_]+)'
    resources :learners, :only => [:show] do
      member do
        get :rworld_social_app_info
      end
    end
  end
  match '/sync_eschool_csp_data' => 'application#sync_eschool_csp_data', :as => :sync_eschool_csp_data
  match '/course_info_detail' => 'extranet/learners#course_info_detail', :as => :course_info_detail
  match '/audit_logs' => 'extranet/learners#audit_logs', :as => :audit_logs
  match '/learner/:id(/learner_studio_history/:view_access)' => 'extranet/learners#learner_studio_history', :as => :learner_studio_history
  match 'learner/:id/change_password' => 'extranet/learners#change_password', :as => :change_password
  match 'resources/:action' => 'extranet/resources#(?i-mx:[a-z_]+)'
  match 'resource/:id/download_file' => 'extranet/resources#download_file', :as => :download_file
  match 'get_learner_details' => 'application#get_learner_details', :as => :get_learner_details
  match 'update_aria_session_with_slot_id' => 'application#update_aria_session_with_slot_id', :as => :update_aria_session_with_slot_id
  match 'lotus_real_time_data' => 'lotus#lotus_real_time_data', :as => :lotus_real_time_data
  match 'last_5_logins' => 'lotus#last_5_logins', :as => :last_5_logins
  match 'logged_in_history' => 'extranet/learners#logged_in_history', :as => :logged_in_history
  match 'about_lotus_data' => 'lotus#about_lotus_data', :as => :about_lotus_data
  match 'about_report_data' => 'report#about_report_data', :as => :about_report_data
  match 'learner_search_info' => 'extranet/learners#learner_search_info', :as => :learner_search_info
  match 'reflex_coach_details' => 'lotus#reflex_coach_details', :as => :reflex_coach_details
  match 'reflex_coach_scheduled_details' => 'lotus#reflex_coach_scheduled_details', :as => :reflex_coach_scheduled_details
  match 'reflex_learner_details' => 'lotus#reflex_learner_details', :as => :reflex_learner_details
  match 'activate_deactivate_license' => 'support_user_portal/licenses#activate_deactivate_license', :as => :activate_deactivate_license
  match 'learners_waiting_details' => 'lotus#learners_waiting_details', :as => :learners_waiting_details
  match 'application-status' => 'application#application_status', :as => :application_status
  match 'substitutions_alert' => 'substitution#substitutions_alert', :as => :substitutions_alert
  match 'application_configuration' => 'application#application_configuration', :as => :application_configuration
  match 'schedules/' => 'schedules#index', :as => :schedules
  match 'master-scheduler/' => 'schedules#index', :as => :master_scheduler
  match 'schedules/:language/' => 'schedules#language_schedules', :as => :language
  match 'schedules/:language/:village/' => 'schedules#language_schedules', :as => :language_and_village
  match 'schedules/:language/:village/:date/' => 'schedules#language_schedules', :as => :language_and_village_and_start_date
  match 'schedules/:language/:village/:date/:classroom_type' => 'schedules#language_schedules', :as => :language_and_village_and_start_date
  match 'slots/:language_id/:village_id/:start_time/' => 'schedules#slot_info', :as => :slot_info
  match 'create_session/:lang_identifier/:ext_village_id/:start_time' => 'schedules#create_session', :as => :create_session
  match 'schedules_coach_availability/:language/:coach/:date' => 'schedules#coach_availability_for_week', :as => :coach_availability
  match 'save_local_session' => 'schedules#save_local_session', :as => :save_local_session
  match 'extra_session_reflex/:language/:ext_village_id/:start_time' => 'schedules#extra_session_reflex', :as => :extra_session_reflex
  match 'save_extra_session' => 'schedules#save_extra_session', :as => :save_extra_session
  match 'delete_local_session' => 'schedules#delete_local_session', :as => :delete_local_session
  match 'edit_session' => 'schedules#edit_session', :as => :edit_session
  match 'remove_lotus_session' => 'schedules#remove_lotus_session', :as => :remove_lotus_session
  match 'edit_extra_session_totale' => 'schedules#edit_extra_session_totale', :as => :edit_extra_session_totale
  match 'push_sessions_to_eschool' => 'schedules#push_sessions_to_eschool', :as => :push_sessions_to_eschool
  match 'save_assign_sub' => 'schedules#save_assign_sub', :as => :save_assign_sub
  match 'edit_extra_session_reflex' => 'schedules#edit_extra_session_reflex', :as => :edit_extra_session_reflex
  match 'update_extra_session_reflex' => 'schedules#update_extra_session_reflex', :as => :update_extra_session_reflex
  match 'edit_reflex_session_details' => 'schedules#edit_reflex_session_details', :as => :edit_reflex_session_details
  match 'save_edited_session' => 'schedules#update_session', :as => :save_edited_session
  match 'cancel_totale_session' => 'schedules#cancel_totale_session', :as => :cancel_totale_session
  match 'view_session_details' => 'schedules#view_session_details', :as => :view_session_details
  match 'get_learner_info' => 'schedules#get_learner_info', :as => :get_learner_info
  match 'check_recurrence_end_date' => 'schedules#check_recurrence_end_date', :as => :check_recurrence_end_date
  match 'availability' => 'availability#index', :as => :index
  match 'availability/:coach_id/' => 'availability#index', :as => :index
  match 'availability/:coach_id/:template_id' => 'availability#index', :as => :index
  match 'load_template' => 'availability#load_template', :as => :load_template
  match 'save_template' => 'availability#save_template', :as => :save_template
  match 'approve_template' => 'availability#approve_template', :as => :approve_template
  match 'delete_template' => 'availability#delete_template', :as => :delete_template
  match 'coach_scheduler/' => 'coach_scheduler#index', :as => :index
  match 'export_schedules_in_csv/:start_date_to_export' => 'coach_scheduler#export_schedules_in_csv', :as => :export_schedules_in_csv
  match 'coach_scheduler/:language/' => 'coach_scheduler#index', :as => :language
  match 'coach_scheduler/:language/:coach/' => 'coach_scheduler#index', :as => :language_coach
  match 'coach_scheduler/:language/:coach/:filter_language/' => 'coach_scheduler#index', :as => :language_coach_filter_language
  match 'coach_scheduler/:language/:coach/:filter_language/:date/' => 'coach_scheduler#index', :as => :language_coach_filter_language_date
  match 'coaches_for_given_language/:language/' => 'coach_scheduler#coaches_for_given_language', :as => :coaches_for_given_language
  match 'languages_for_given_language_filter' => 'schedules#languages_for_given_language_filter', :as => :languages_for_given_language_filter
  match 'topic_for_cefr_and_given_language/:language/:cefrLevel/' => 'coach_scheduler#topic_for_cefr_and_given_language', :as => :topic_for_cefr_and_given_language
  match 'create_session_form_in_coach_scheduler' => 'coach_scheduler#create_session_form_in_coach_scheduler', :as => :create_session_form_in_coach_scheduler
  match 'aria_launch_url' => 'application#aria_launch_url', :as => :aria_launch_url
  match 'create_eschool_session_from_coach_scheduler' => 'coach_scheduler#create_eschool_session_from_coach_scheduler', :as => :create_eschool_session_from_coach_scheduler
  match 'coach_session_details/:start_time/:coach_id' => 'coach_scheduler#coach_session_details', :as => :coach_session_details_manager
  match 'coach_session_details/:start_time' => 'coach_scheduler#coach_session_details', :as => :coach_session_details_coach
  match 'edit_coach_session' => 'coach_scheduler#edit_session_for_coach', :as => :edit_session_for_coach
  match 'update_session_from_cs' => 'coach_scheduler#update_session_from_cs', :as => :update_session_from_cs
  match 'my_schedule' => 'coach_scheduler#my_schedule', :as => :my_schedule
  match 'my_schedule/:language' => 'coach_scheduler#my_schedule', :as => :my_schedule_language
  match 'my_schedule/:language/:date' => 'coach_scheduler#my_schedule', :as => :my_schedule_language_date
  match 'game_history' => 'extranet/learners#game_history', :as => :game_history
  match 'user_interaction' => 'extranet/learners#user_interaction', :as => :user_interaction
  match 'chat_history' => 'extranet/learners#chat_history', :as => :chat_history
  match 'user_invite_history' => 'extranet/learners#user_invite_history', :as => :user_invite_history
  match 'student_evaluation_feedback' => 'extranet/learners#student_evaluation_feedback', :as => :student_evaluation_feedback
  match 'export_student_history_to_csv' => 'extranet/learners#export_student_history_to_csv', :as => :export_student_history_to_csv
  match 'get_generate_range_for_chat_history' => 'extranet/learners#get_generate_range_for_chat_history', :as => :get_generate_range_for_chat_history
  match 'view_chat_history' => 'extranet/learners#view_chat_history', :as => :view_chat_history
  match 'selected_learner_chat_history' => 'extranet/learners#selected_learner_chat_history', :as => :selected_learner_chat_history
  match 'cmt_reports' => 'extranet/reports#index', :as => :reports
  match 'learner_profile' => 'extranet/reports#profile', :as => :learner_profile
  match 'keepalive' => 'keepalive#index', :as => :keepalive
  match 'reroute' => 'application#reroute', :as => :reroute
  match 'eschool-sessions' => 'support_user_portal/eschool_sessions#show', :as => :eschool_sessions
  match 'attendances' => 'support_user_portal/eschool_sessions#show_attendances', :as => :attendances
  match 'add_student' => 'support_user_portal/eschool_sessions#add_student', :as => :add_student
  match 'remove_student' => 'support_user_portal/eschool_sessions#remove_student', :as => :remove_student
  match 'export-sessions-to-csv' => 'support_user_portal/eschool_sessions#export_sessions_to_csv', :as => :export_sessions_to_csv
  match 'support_user_portal' => 'support_user_portal/licenses#license_details', :as => :support_portal_home
  match 'show-extension-form' => 'support_user_portal/licenses#show_extension_form', :as => :show_extension_form
  match 'add-or-remove-with-consumables' => 'support_user_portal/licenses#add_or_remove_with_consumables', :as => :add_or_remove_with_consumables
  match 'add-or-remove-extension' => 'support_user_portal/licenses#add_or_remove_extension', :as => :add_or_remove_extension
  match 'support_user_portal/reset_password' => 'support_user_portal/licenses#reset_password', :as => :reset_password
  match 'support_user_portal/licenses_hierarchy' => 'support_user_portal/licenses#licenses_hierarchy', :as => :licenses_hierarchy
  match 'learner_access_log' => 'support_user_portal/licenses#view_access_log', :as => :view_access_log
  match 'product_rights_modification_report' => 'support_user_portal/licenses#product_rights_modification_report', :as => :report_search
  match 'rights_extension_report' => 'support_user_portal/licenses#show_rights_extension_report', :as => :show_rights_extension_report
  match 'mail_report' => 'support_user_portal/licenses#mail_report', :as => :mail_report
  match 'view_access_log' => 'support_user_portal/licenses#view_access_log', :as => :view_access_log
  match 'product_rights_export_to_csv' => 'support_user_portal/licenses#product_rights_export_to_csv', :as => :view_access_log
  match 'studio_history' => 'support_user_portal/licenses#studio_history', :as => :studio_history
  match 'course_info_details' => 'support_user_portal/licenses#course_info_details', :as => :course_info_details
  match 'community_audit_logs' => 'support_user_portal/licenses#community_audit_logs', :as => :community_audit_logs
  match 'view_license_information' => 'support_user_portal/licenses#license_info', :as => :view_license_information
  match 'view_extension_details' => 'support_user_portal/licenses#view_extension_details', :as => :view_extension_details
  match 'support_user_portal/modify_language' => 'support_user_portal/licenses#modify_language', :as => :modify_language
  match 'view_learner/:license_guid' => 'support_user_portal/licenses#show_learner_profile_and_license_information', :as => :show_learner_profile_and_license_information
  match 'support_user_portal/end_date_calculation' => 'support_user_portal/licenses#end_date_calculation', :as => :end_date_calculation
  match 'support_user_portal/remove_end_date_calculation' => 'support_user_portal/licenses#remove_end_date_calculation', :as => :remove_end_date_calculation
  match 'show_consumable_form' => 'support_user_portal/licenses#show_consumable_form', :as => :show_consumable_form
  match 'add_consumable' => 'support_user_portal/licenses#add_consumable', :as => :add_consumable
  match 'show_uncap_learner_form' => 'support_user_portal/licenses#show_uncap_learner_form', :as => :show_uncap_learner_form
  match 'uncap_learner' => 'support_user_portal/licenses#uncap_learner', :as => :uncap_learner
  match 'view_all_consumables' => 'support_user_portal/licenses#view_all_consumables', :as => :view_all_consumables
  match 'granted_additional_sessions' => 'support_user_portal/licenses#granted_additional_sessions', :as => :granted_additional_sessions
  match 'remove_learner_from_session' => 'support_user_portal/licenses#remove_learner_from_session', :as => :remove_learner_from_session
  match 'dashboard' => 'dashboard#index', :as => :dashboard
  match 'dashboard/filter_sessions' => 'dashboard#filter_sessions', :as => :filter_sessions
  match 'dashboard/:id/get_learners_for_session' => 'dashboard#get_learners_for_session', :as => :learners_for_session
  match 'dashboard/filter_learners' => 'dashboard#filter_learners', :as => :filter_learners
  match 'reassign_coach' => 'dashboard#reassign_coach', :as => :reassign_coach
  match 'support_user_portal/edit-profile' => 'support_user_portal/support_portal#edit_profile', :as => :edit_support_profile
  match 'support_user_portal/edit-admin-profile' => 'support_user_portal/support_portal#edit_admin_profile', :as => :edit_admin_profile
  match 'support_user_portal/view-profile' => 'support_user_portal/support_portal#view_profile', :as => :view_support_profile
  match 'support_user_portal/preference-settings' => 'support_user_portal/support_portal#preference_settings', :as => :support_preference_settings
  match '/' => 'coach_portal#login', :as => :login
  match 'logout' => 'coach_portal#logout', :as => :logout
  match 'coach' => 'coach_portal#index', :as => :coach_portal
  match 'sign-in-as-super-user' => 'coach_portal#sign_in_as_super_user', :as => :sign_in_as_super_user
  match 'next_session_start_time' => 'application#next_session_start_time', :as => :next_session_start_time
  match 'get-next-session-details' => 'coach_portal#get_next_session_details', :as => :get_next_session_details
  match 'get-coach-language-details' => 'manager_portal#get_coach_langauges', :as => :get_coach_langauges
  match 'coach-showed-up' => 'coach_portal#coach_showed_up', :as => :coach_showed_up
  match 'update_draft_after_substitue_check' => 'coach_portal#update_draft_after_substitue_check', :as => :update_draft_after_substitue_check
  match 'new-template' => 'coach_portal#new_template', :as => :new_template
  match 'create-template' => 'coach_portal#create_template', :as => :create_template
  match 'delete-template' => 'coach_portal#delete_template', :as => :delete_template
  match 'list-timeoff' => 'timeoff#list_timeoff', :as => :list_timeoff
  match 'edit-timeoff' => 'timeoff#edit_timeoff', :as => :edit_timeoff
  match 'create-timeoff' => 'timeoff#create_timeoff', :as => :create_timeoff
  match 'save-timeoff' => 'timeoff#save_timeoff', :as => :save_timeoff
  match 'cancel-timeoff' => 'timeoff#cancel_timeoff', :as => :cancel_timeoff
  match 'check-policy-violation' => 'timeoff#check_policy_violation_for_availability_modification', :as => :check_policy_violation
  match 'view-profile' => 'coach_portal#view_profile', :as => :view_profile
  match 'edit-profile' => 'coach_portal#edit_profile', :as => :edit_profile
  #match 'coach-preference-settings' => 'coach_portal#preference_settings', :as => :coach_preference_settings
  match 'update-template' => 'coach_portal#update_template', :as => :update_template
  match 'copy-template' => 'coach_portal#copy_template', :as => :copy_template
  match 'coach-notifications' => 'coach_portal#notifications', :as => :notifications
  match 'calendar_week' => 'coach_portal#calendar_week', :as => :calendar_week
  match 'availability_template' => 'coach_portal#availability_template', :as => :availability_template
  match 'view_my_upcoming_classes' => 'coach_portal#view_my_upcoming_classes', :as => :view_my_upcoming_classes
  match 'view_my_today_classes' => 'coach_portal#view_my_today_classes', :as => :view_my_today_classes
  match 'manager' => 'manager_portal#index', :as => :manager_portal
  match 'coach_time_off' => 'manager_portal#coach_time_off', :as => :coach_time_off
  match 'get_time_off_ui' => 'manager_portal#get_time_off_ui', :as => :get_time_off_ui
  match 'export_time_off_report' => 'manager_portal#export_time_off_report',:as => :export_time_off_report
  match 'sign-in-as-my-coach/:coach_id' => 'manager_portal#sign_in_as_my_coach', :as => :sign_in_as_my_coach
  match 'approve-modification/:id/:status' => 'timeoff#approve_modification', :as => :approve_modification
  match 'manage-languages' => 'manager_portal#manage_languages', :as => :manage_languages
  match 'manage-languages' => 'manager_portal#keyboard_shortcuts', :as => :manage_languages

  match 'village-admin' => 'village_preferences#index', :as => :village_preference
  match 'save_village_preferences' => 'village_preferences#save_village_preferences'

  match 'remove-language' => 'manager_portal#remove_language', :as => :remove_language
  match 'assign-coaches' => 'manager_portal#assign_coaches', :as => :assign_coaches
  match 'mail_template' => 'manager_portal#mail_template' , :as => :mail_template
  match 'fetch_mail_address/:id' => 'manager_portal#fetch_mail_address', :as => :fetch_mail_address
  match 'send_mail_to_coaches' => 'manager_portal#send_mail_to_coaches' , :as => :send_mail_to_coaches
  match 'configurations' => 'extranet/homes#index', :as => :configurations
  match 'view-coach-profiles' => 'manager_portal#view_coach_profiles', :as => :view_coach_profiles
  match 'inactivate_coach' => 'manager_portal#inactivate_coach', :as => :inactivate_coach
  match 'view-coach-profile/:coach_id' => 'manager_portal#view_coach_profiles', :as => :view_coach_profile
  match 'week-view' => 'manager_portal#week_view', :as => :week_view
  match 'print_coach_schedule' => 'manager_portal#print_coach_schedule', :as => :print_coach_schedule
  match 'manager-notifications' => 'manager_portal#notifications', :as => :manager_notifications
  match 'substitutions-report' => 'manager_portal#substitutions_report', :as => :substitutions_report
  match 'export-to-csv' => 'manager_portal#export_to_csv', :as => :export_to_csv
  match 'assign-substitute' => 'manager_portal#assign_substitute', :as => :assign_substitute
  match 'create-eschool-session' => 'extranet/homes#index', :as => :create_eschool_session
  match 'cancel-session' => 'manager_portal#cancel_session', :as => :cancel_session
  match 'get_teachers_for_language/:lang_identifier' => 'manager_portal#get_teachers_for_language', :as => :get_teachers_for_language
  match 'max_qual_of_coach/:coach_user_name/:lang_identifier' => 'manager_portal#max_qual_of_coach', :as => :max_qual_of_coach
  match 'start_minute_of_lang/:lang_identifier' => 'manager_portal#start_minute_of_language', :as => :start_minute_of_lang
  match 'get_teachers_for_manager_in_language/:lang_identifier' => 'manager_portal#get_teachers_for_manager_in_language', :as => :get_teachers_for_manager_in_language
  resources :scheduling_thresholds
  match 'create-coach' => 'coach#create_coach', :as => :create_coach
  match 'edit-coach/:id' => 'coach#edit_coach', :as => :edit_coach
  # match 'edit-coach' => 'coach#edit_coach', :as => :edit_coach
  match 'view_report' => 'staffing#view_report', :as => :view_report
  match 'show_staffing_file_info' => 'staffing#show_staffing_file_info', :as => :show_staffing_file_info
  match 'import_staffing_data' => 'staffing#import_staffing_data', :as => :import_staffing_data
  match 'download_staffing_data_file/:id' => 'staffing#download_staffing_data_file', :as => :download_staffing_data_file
  match 'get_report_data_for_a_week' => 'staffing#get_report_data_for_a_week', :as => :get_report_data_for_a_week
  match 'export_staffing_report' => 'staffing#export_staffing_report', :as => :export_staffing_report
  match 'create_extra_session_reflex_smr' => 'staffing#create_extra_session_reflex_smr', :as => :create_extra_session_reflex_smr
  match 'show_create_extra_session_popup_reflex_smr/:lang_identifier/:start_time' => 'staffing#show_create_extra_session_popup_reflex_smr', :as => :show_create_extra_session_popup_reflex_smr
  match 'report' => 'report#index', :as => :report
  match 'get_report_ui' => 'report#get_report_ui', :as => :get_report_ui
  match 'get_qualified_coaches_for_language/:lang_identifier' => 'report#get_qualified_coaches_for_language', :as => :get_qualified_coaches_for_language
  match 'get_generate_range' => 'application#get_generate_range', :as => :get_generate_range
  match 'export-car-to-csv' => 'report#export_car_to_csv', :as => :export_car_to_csv

  scope :module => 'report' do
    match 'reflex' => 'reflexes#show'
    match 'reflex/generate' => 'reflexes#generate'
    match 'reflex/generate_csv' => 'reflexes#export_reflex_report_to_csv'
    match 'reflex/generate_eng_csv' => 'reflexes#export_all_american_report_to_csv'
    match 'reflex/americaneng' => 'reflexes#show_eng'
    match 'reflex/generate_eng' => 'reflexes#generate_eng'
  end

  match 'background-tasks' => 'background#background_tasks', :as => :background_tasks
  match 'trigger_sms' => 'substitution#trigger_sms', :as => :trigger_sms
  match 'substitutions' => 'substitution#substitutions', :as => :substitutions
  match 'grab_substitution' => 'substitution#grab_substitution', :as => :grab_substitution
  match 'request_substitute_for_coach' => 'substitution#request_substitute_for_coach', :as => :request_substitute_for_coach
  match 'assign_substitute_for_coach' => 'substitution#assign_substitute_for_coach', :as => :assign_substitute_for_coach
  match 'fetch_available_coaches' => 'substitution#fetch_available_coaches', :as => :fetch_available_coaches
  match 'reason_for_sub_request' => 'substitution#reason_for_sub_request' , :as => :reason_for_sub_request
  match 'reason_for_cancellation' => 'application#reason_for_cancellation' , :as => :reason_for_cancellation
  match 'check_sub_policy_violation' => 'substitution#check_sub_policy_violation' , :as => :check_sub_policy_violation
  match 'cancel_substitution' => 'substitution#cancel_substitution', :as => :cancel_substitution
  match '/mark-notification-as-read/:id' => 'application#mark_notification_as_read'
  match 'users/photos/:id/:filename' => 'application#photos'
  match 'on_duty_list' => 'application#on_duty_list', :as => :on_duty_list
  match 'edit_on_duty_list' => 'application#edit_on_duty_list', :as => :edit_on_duty_list
  match 'save_on_duty_list' => 'application#save_on_duty_list', :as => :save_on_duty_list
  match 'save_text_message' => 'application#save_text_message', :as => :save_text_message
  match '/coach-roster/(:language/(:region))' => 'coach_roster#coach_roster', :as => :coach_roster
  match '/coach-list-as-csv' => 'coach_roster#export_coach_list_as_csv', :as => :coach_list_as_csv
  match '/mgmt-list-as-csv' => 'coach_roster#export_mgmt_list_as_csv', :as => :mgmt_list_as_csv

  match 'edit_management_team' => 'coach_roster#edit_management_team', :as => :edit_management_team_path
  match 'management_team_form' => 'coach_roster#management_team_form', :as => :management_team_form
  match 'save_member_details' => 'coach_roster#save_member_details', :as => :save_member_details
  match 'delete_member' => 'coach_roster#delete_member', :as => :delete_member
  match 'hide_member' => 'coach_roster#hide_member', :as => :hide_member
  match 'save_order_of_members' => 'coach_roster#save_order_of_members', :as => :save_order_of_members
  match 'management/photos/:id/:filename' => 'coach_roster#images'
  match 'save_on_duty_list' => 'application#save_on_duty_list', :as => :save_on_duty_list
  match 'save_on_duty_message' => 'application#save_on_duty_message', :as => :save_on_duty_message
  match 'publish_coach_alert' => 'application#publish_coach_alert', :as => :publish_coach_alert
  match 'alert_is_active' => 'application#alert_is_active', :as => :alert_is_active 
  match 'remove_coach_alert' => 'application#remove_coach_alert', :as => :remove_coach_alert
  match 'coach_alert' => 'application#coach_alert', :as => :coach_alert
  match 'get_dialects' => 'application#get_dialects', :as => :get_dialects

  match 'get_aeb_topics' => 'schedules#get_aeb_topics', :as => :get_aeb_topics
  match 'update_topics' => 'topics#update_topics', :as => :update_topics
  match 'request-help' => 'application#populate_help_request', :via => [:post]
  match 'crossdomain.xml' => "application#get_crossdomain_xml", :as => "get_crossdomain_xml"
  match 'fetch_languages' => "application#fetch_languages", :as => "fetch_languages"
  match 'fetch_aeb_first_seen_at' => 'dashboard#fetch_aeb_first_seen_at', :as => "fetch_aeb_first_seen_at"


  #all routes should be define above this line
  match '*path' => 'application#routes_catchall'
end
