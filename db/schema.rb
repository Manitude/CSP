# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141205062517) do

  create_table "accounts", :force => true do |t|
    t.string   "user_name"
    t.string   "full_name"
    t.string   "preferred_name"
    t.string   "rs_email"
    t.string   "personal_email"
    t.string   "skype_id"
    t.string   "primary_phone"
    t.string   "secondary_phone"
    t.date     "birth_date"
    t.date     "hire_date"
    t.text     "bio"
    t.text     "manager_notes"
    t.boolean  "active",                                                                          :default => true,  :null => false
    t.integer  "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                                                                               :null => false
    t.integer  "region_id"
    t.integer  "next_session_alert_in",      :limit => 3
    t.datetime "last_logout"
    t.string   "country"
    t.string   "native_language"
    t.string   "other_languages"
    t.string   "address"
    t.boolean  "lotus_qualified",                                                                 :default => true
    t.decimal  "next_substitution_alert_in",                       :precision => 10, :scale => 0, :default => 24
    t.string   "mobile_phone"
    t.integer  "sessions_allowed_per_week",  :limit => 2,                                         :default => 8,     :null => false
    t.boolean  "is_supervisor",                                                                   :default => false
    t.string   "mobile_country_code"
    t.string   "aim_id"
    t.string   "primary_country_code"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.binary   "photo_file",                 :limit => 2147483647
    t.string   "coach_guid"
  end

  add_index "accounts", ["manager_id"], :name => "index_coaches_on_manager_id"
  add_index "accounts", ["mobile_phone"], :name => "index_accounts_on_mobile_phone"
  add_index "accounts", ["type"], :name => "index_accounts_on_type"
  add_index "accounts", ["user_name"], :name => "index_coaches_on_user_name"

  create_table "add_consumable_logs", :force => true do |t|
    t.integer  "support_user_id",    :null => false
    t.string   "license_guid",       :null => false
    t.string   "reason",             :null => false
    t.string   "case_number",        :null => false
    t.string   "consumable_type"
    t.string   "pooler_guid"
    t.string   "pooler_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.integer  "number_of_sessions"
  end

  create_table "alerts", :force => true do |t|
    t.text     "description"
    t.string   "created_by"
    t.boolean  "active",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "announcements", :force => true do |t|
    t.text     "body"
    t.string   "subject"
    t.datetime "expires_on"
    t.integer  "language_id"
    t.integer  "region_id"
    t.string   "language_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "announcements", ["created_at"], :name => "index_announcements_on_created_at"
  add_index "announcements", ["expires_on"], :name => "index_announcements_on_expires_on"
  add_index "announcements", ["language_id"], :name => "index_announcements_on_language_id"
  add_index "announcements", ["language_name"], :name => "index_announcements_on_language_name"
  add_index "announcements", ["region_id"], :name => "index_announcements_on_region_id"
  add_index "announcements", ["subject"], :name => "index_announcements_on_subject"

  create_table "application_configurations", :force => true do |t|
    t.string   "setting_type"
    t.string   "value"
    t.string   "data_type"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appointment_types", :force => true do |t|
    t.string   "title"
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audit_log_records", :force => true do |t|
    t.string   "loggable_type"
    t.integer  "loggable_id"
    t.string   "attribute_name"
    t.string   "action"
    t.text     "previous_value"
    t.text     "new_value"
    t.datetime "timestamp"
    t.datetime "created_at"
    t.string   "changed_by"
  end

  add_index "audit_log_records", ["action"], :name => "index_audit_log_records_on_action"
  add_index "audit_log_records", ["loggable_id"], :name => "index_audit_log_records_on_loggable_id"
  add_index "audit_log_records", ["loggable_type"], :name => "index_audit_log_records_on_loggable_type"
  add_index "audit_log_records", ["timestamp"], :name => "index_audit_log_records_on_timestamp"

  create_table "background_tasks", :force => true do |t|
    t.integer  "referer_id"
    t.string   "state"
    t.string   "error"
    t.string   "background_type"
    t.datetime "job_start_time"
    t.datetime "job_end_time"
    t.string   "triggered_by"
    t.boolean  "locked",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
  end

  create_table "backup_for_coach_ids_for_time_zone_null", :id => false, :force => true do |t|
    t.integer "coach_id"
  end

  create_table "backup_for_coach_recurring_schedules", :id => false, :force => true do |t|
    t.integer "crs_id"
  end

  create_table "backup_for_coach_recurring_schedules_1", :id => false, :force => true do |t|
    t.integer "crs_id"
  end

  create_table "backup_for_coach_recurring_schedules_20111116", :id => false, :force => true do |t|
    t.integer "crs_id"
  end

  create_table "backup_for_coach_recurring_schedules_20111122", :id => false, :force => true do |t|
    t.integer "crs_id"
  end

  create_table "backup_for_coach_sessions_20120422", :id => false, :force => true do |t|
    t.integer "cs_id"
  end

  create_table "backup_for_duplicate_entry_in_coach_recurring_schedules", :force => true do |t|
    t.integer  "coach_id",                          :null => false
    t.integer  "day_index",            :limit => 1, :null => false
    t.time     "start_time",                        :null => false
    t.datetime "recurring_start_date",              :null => false
    t.datetime "recurring_end_date"
    t.integer  "language_id",                       :null => false
    t.integer  "external_village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "backup_for_duplicate_entry_in_coach_recurring_schedules", ["language_id", "recurring_end_date"], :name => "idx_c_rec_sched_lang_end_date"

  create_table "backup_for_duplicate_entry_in_coach_recurring_schedules_1", :force => true do |t|
    t.integer  "coach_id",                          :null => false
    t.integer  "day_index",            :limit => 1, :null => false
    t.time     "start_time",                        :null => false
    t.datetime "recurring_start_date",              :null => false
    t.datetime "recurring_end_date"
    t.integer  "language_id",                       :null => false
    t.integer  "external_village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "backup_for_duplicate_entry_in_coach_recurring_schedules_1", ["language_id", "recurring_end_date"], :name => "idx_c_rec_sched_lang_end_date"

  create_table "backup_for_duplicate_entry_in_coach_recurring_schedules_20111116", :force => true do |t|
    t.integer  "coach_id",                          :null => false
    t.integer  "day_index",            :limit => 1, :null => false
    t.time     "start_time",                        :null => false
    t.datetime "recurring_start_date",              :null => false
    t.datetime "recurring_end_date"
    t.integer  "language_id",                       :null => false
    t.integer  "external_village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "backup_for_duplicate_entry_in_coach_recurring_schedules_20111116", ["language_id", "recurring_end_date"], :name => "idx_c_rec_sched_lang_end_date"

  create_table "backup_for_duplicate_entry_in_coach_recurring_schedules_20111122", :force => true do |t|
    t.integer  "coach_id",                          :null => false
    t.integer  "day_index",            :limit => 1, :null => false
    t.time     "start_time",                        :null => false
    t.datetime "recurring_start_date",              :null => false
    t.datetime "recurring_end_date"
    t.integer  "language_id",                       :null => false
    t.integer  "external_village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "backup_for_duplicate_entry_in_coach_recurring_schedules_20111122", ["language_id", "recurring_end_date"], :name => "idx_c_rec_sched_lang_end_date"

  create_table "beta_lotus_sessions_corrections_20110426", :force => true do |t|
    t.string   "coach_user_name"
    t.integer  "eschool_session_id"
    t.datetime "session_start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cancelled",           :default => false
    t.integer  "external_village_id"
    t.string   "language_identifier"
  end

  add_index "beta_lotus_sessions_corrections_20110426", ["coach_user_name"], :name => "index_coach_sessions_on_coach_user_name"
  add_index "beta_lotus_sessions_corrections_20110426", ["eschool_session_id"], :name => "idx_coach_sessions_eschool_session_id"
  add_index "beta_lotus_sessions_corrections_20110426", ["session_start_time"], :name => "idx_coach_sessions_start_time"

  create_table "beta_lotus_sessions_corrections_20110616", :force => true do |t|
    t.binary   "data",                :limit => 16777215
    t.datetime "start_of_week"
    t.string   "lang_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "external_village_id"
  end

  create_table "box_links", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cm_preferences", :force => true do |t|
    t.integer  "account_id"
    t.integer  "min_time_to_alert_for_session_with_no_coach", :default => 2
    t.boolean  "email_alert_enabled",                         :default => false
    t.string   "email_preference"
    t.boolean  "page_alert_enabled",                          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "receive_reflex_sms_alert",                    :default => false
  end

  create_table "cm_preferences_backup_20111219_2012", :force => true do |t|
    t.integer  "account_id"
    t.integer  "min_time_to_alert_for_session_with_no_coach", :default => 2
    t.boolean  "sms_alert_enabled",                           :default => false
    t.boolean  "email_alert_enabled",                         :default => false
    t.string   "email_preference"
    t.boolean  "page_alert_enabled",                          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coach_availabilities", :force => true do |t|
    t.integer  "coach_availability_template_id",                                 :null => false
    t.integer  "day_index",                      :limit => 1,                    :null => false
    t.time     "start_time",                                                     :null => false
    t.time     "end_time",                                                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "availabled_by_manager",                       :default => false
    t.integer  "recurring_id"
    t.integer  "daylight_diff"
  end

  add_index "coach_availabilities", ["coach_availability_template_id"], :name => "idx_coach_availabilities_coach_availability_template_id"

  create_table "coach_availabilities_backup_20110530", :force => true do |t|
    t.integer  "coach_availability_template_id",                             :null => false
    t.integer  "day_index",                      :limit => 1,                :null => false
    t.integer  "status",                         :limit => 1, :default => 2
    t.time     "start_time",                                                 :null => false
    t.time     "end_time",                                                   :null => false
    t.integer  "suggested_by",                   :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recurring_start_date"
    t.integer  "external_village_id"
    t.string   "recurring_language_identifier"
  end

  add_index "coach_availabilities_backup_20110530", ["coach_availability_template_id"], :name => "index_coach_availabilities_on_coach_availability_template_id"

  create_table "coach_availability_corrections_20110225", :force => true do |t|
    t.integer  "coach_availability_template_id",                             :null => false
    t.integer  "day_index",                      :limit => 1,                :null => false
    t.integer  "status",                         :limit => 1, :default => 2
    t.time     "start_time",                                                 :null => false
    t.time     "end_time",                                                   :null => false
    t.integer  "suggested_by",                   :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recurring_start_date"
  end

  add_index "coach_availability_corrections_20110225", ["coach_availability_template_id"], :name => "index_coach_availabilities_on_coach_availability_template_id"

  create_table "coach_availability_modifications_backup_20110530", :force => true do |t|
    t.integer  "coach_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "availability_status",  :limit => 1
    t.text     "comments"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "eschool_session_id"
    t.boolean  "substitute_requested",              :default => false
    t.integer  "coach_session_id",     :limit => 3
  end

  add_index "coach_availability_modifications_backup_20110530", ["approved"], :name => "index_coach_availability_modifications_on_approved"
  add_index "coach_availability_modifications_backup_20110530", ["coach_id"], :name => "index_coach_availability_modifications_on_coach_id"
  add_index "coach_availability_modifications_backup_20110530", ["end_date"], :name => "idx_coach_availability_modifications_end_date"
  add_index "coach_availability_modifications_backup_20110530", ["start_date"], :name => "idx_coach_availability_modifications_start_date"

  create_table "coach_availability_templates", :force => true do |t|
    t.integer  "coach_id",                                             :null => false
    t.string   "label"
    t.datetime "effective_start_date"
    t.integer  "status",               :limit => 1, :default => 0
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",                           :default => false
  end

  add_index "coach_availability_templates", ["coach_id"], :name => "index_coach_availability_templates_on_coach_id"
  add_index "coach_availability_templates", ["deleted", "status"], :name => "idx_cat_del_stat_lng_st_time"

  create_table "coach_avl_mods_ids_created", :id => false, :force => true do |t|
    t.integer "coach_availability_modification_id"
  end

  create_table "coach_contacts", :force => true do |t|
    t.integer  "coach_id"
    t.string   "coach_manager"
    t.string   "supervisor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coach_recurring_schedules", :force => true do |t|
    t.integer  "coach_id",                                                           :null => false
    t.integer  "day_index",            :limit => 1,                                  :null => false
    t.time     "start_time",                                                         :null => false
    t.datetime "recurring_start_date",                                               :null => false
    t.datetime "recurring_end_date"
    t.integer  "language_id",                                                        :null => false
    t.integer  "external_village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_seats",                   :default => 4
    t.integer  "topic_id"
    t.string   "recurring_type",                    :default => "recurring_session"
    t.integer  "appointment_type_id"
  end

  add_index "coach_recurring_schedules", ["appointment_type_id"], :name => "index_coach_recurring_schedules_on_appointment_type_id"
  add_index "coach_recurring_schedules", ["language_id", "recurring_end_date"], :name => "idx_c_rec_sched_lang_end_date"
  add_index "coach_recurring_schedules", ["recurring_type"], :name => "index_coach_recurring_schedules_on_recurring_type"

  create_table "coach_sessions", :force => true do |t|
    t.integer  "eschool_session_id"
    t.datetime "session_start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cancelled",                :default => false
    t.integer  "external_village_id"
    t.string   "language_identifier"
    t.integer  "single_number_unit"
    t.integer  "number_of_seats"
    t.integer  "attendance_count"
    t.boolean  "coach_showed_up",          :default => false
    t.integer  "seconds_prior_to_session"
    t.integer  "recurring_schedule_id"
    t.integer  "coach_id"
    t.integer  "session_status",           :default => 1
    t.string   "type",                     :default => "LocalSession", :null => false
    t.string   "name"
    t.datetime "session_end_time"
    t.integer  "language_id",                                          :null => false
    t.string   "cancellation_reason"
    t.integer  "topic_id"
    t.boolean  "reassigned"
    t.integer  "appointment_type_id"
  end

  add_index "coach_sessions", ["appointment_type_id"], :name => "index_coach_sessions_on_appointment_type_id"
  add_index "coach_sessions", ["coach_id"], :name => "index_coach_sessions_on_coach_id"
  add_index "coach_sessions", ["eschool_session_id"], :name => "idx_coach_sessions_eschool_session_id"
  add_index "coach_sessions", ["language_identifier"], :name => "index_coach_sessions_on_coach_user_name_and_language_identifier"
  add_index "coach_sessions", ["session_start_time"], :name => "idx_coach_sessions_start_time"

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dialects", :force => true do |t|
    t.string   "name"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.text     "event_description"
    t.string   "event_name"
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.integer  "language_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["created_at"], :name => "index_events_on_created_at"
  add_index "events", ["event_name"], :name => "index_events_on_event_name"
  add_index "events", ["language_id"], :name => "index_events_on_language_id"

  create_table "excluded_coaches_sessions", :force => true do |t|
    t.integer  "coach_session_id", :null => false
    t.integer  "coach_id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "global_settings", :force => true do |t|
    t.string "attribute_name"
    t.string "attribute_value"
    t.string "description"
  end

  create_table "help_requests", :force => true do |t|
    t.string   "role"
    t.string   "user_id"
    t.integer  "external_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "language_configurations", :force => true do |t|
    t.integer  "language_id"
    t.integer  "session_start_time", :limit => 1
    t.integer  "created_by"
    t.datetime "created_at"
  end

  add_index "language_configurations", ["language_id"], :name => "index_language_configurations_on_language_id"

  create_table "language_scheduling_thresholds", :force => true do |t|
    t.integer  "language_id",                                      :null => false
    t.integer  "max_assignment",                   :default => 50, :null => false
    t.integer  "max_grab",                         :default => 30, :null => false
    t.integer  "hours_prior_to_sesssion_override", :default => 12, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string   "identifier",                                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_pushed_week",   :default => '2011-10-27 23:22:54'
    t.string   "type",               :default => "TotaleLanguage",      :null => false
    t.integer  "duration",           :default => 30
    t.string   "connection_type"
    t.string   "external_scheduler"
  end

  add_index "languages", ["identifier"], :name => "index_languages_on_identifier"

  create_table "learner_product_rights", :force => true do |t|
    t.integer "learner_id"
    t.string  "language_identifier"
    t.string  "activation_id"
    t.string  "product_guid"
  end

  add_index "learner_product_rights", ["activation_id"], :name => "idx_product_rights_activation_id"
  add_index "learner_product_rights", ["language_identifier"], :name => "idx_product_rights_language"
  add_index "learner_product_rights", ["learner_id"], :name => "idx_product_rights_learner_id"
  add_index "learner_product_rights", ["product_guid"], :name => "idx_product_rights_product_guid"

  create_table "learner_support_statuses", :force => true do |t|
    t.string   "guid"
    t.integer  "session_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "learners", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "mobile_number"
    t.string   "guid"
    t.string   "user_source_type"
    t.boolean  "totale",                       :default => false
    t.boolean  "rworld",                       :default => false
    t.boolean  "osub",                         :default => false
    t.boolean  "osub_active",                  :default => false
    t.boolean  "totale_active",                :default => false
    t.boolean  "enterprise_license_active",    :default => false
    t.boolean  "parature_customer",            :default => false
    t.text     "previous_license_identifiers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "village_id"
    t.string   "user_name"
  end

  add_index "learners", ["email"], :name => "idx_learners_email"
  add_index "learners", ["enterprise_license_active"], :name => "idx_learners_enterprise_license_active"
  add_index "learners", ["first_name"], :name => "idx_learners_first_name"
  add_index "learners", ["guid"], :name => "idx_learners_guid"
  add_index "learners", ["last_name"], :name => "idx_learners_last_name"
  add_index "learners", ["mobile_number"], :name => "idx_learners_mobile_number"
  add_index "learners", ["osub_active"], :name => "idx_learners_osub_active"
  add_index "learners", ["rworld"], :name => "idx_learners_rworld"
  add_index "learners", ["totale_active"], :name => "idx_learners_totale_active"
  add_index "learners", ["village_id"], :name => "idx_learners_village_id"

  create_table "levels", :force => true do |t|
    t.integer  "number",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "levels", ["number"], :name => "index_levels_on_number", :unique => true

  create_table "links", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "management_team_members", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "phone_cell"
    t.string   "phone_desk"
    t.string   "email"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.boolean  "hide",                                     :default => false
    t.integer  "position"
    t.text     "bio",                :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "image_file",         :limit => 2147483647
    t.boolean  "on_duty",                                  :default => false
    t.time     "available_start"
    t.time     "available_end"
  end

  create_table "ms_draft_data", :force => true do |t|
    t.binary   "data",            :limit => 16777215
    t.datetime "start_of_week"
    t.string   "lang_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_changed_by"
  end

  create_table "ms_error_messages", :force => true do |t|
    t.string   "language_identifier"
    t.text     "message"
    t.datetime "start_of_week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newly_created_coach_recurring_schedules", :id => false, :force => true do |t|
    t.integer "coach_recurring_schedule_id"
  end

  create_table "notification_message_dynamics", :force => true do |t|
    t.integer "notification_id"
    t.integer "msg_index"
    t.string  "name"
    t.string  "rel_obj_type"
    t.string  "rel_obj_attr"
  end

  add_index "notification_message_dynamics", ["notification_id"], :name => "index_notification_message_dynamics_on_notification_id"

  create_table "notification_recipients", :force => true do |t|
    t.integer "notification_id"
    t.string  "name"
    t.string  "rel_recipient_obj"
  end

  add_index "notification_recipients", ["notification_id"], :name => "index_notification_recipients_on_notification_id"

  create_table "notifications", :force => true do |t|
    t.integer "trigger_event_id"
    t.text    "message"
    t.string  "target_type"
  end

  add_index "notifications", ["trigger_event_id"], :name => "index_notifications_on_trigger_event_id"

  create_table "preference_settings", :force => true do |t|
    t.integer  "substitution_alerts_email"
    t.string   "substitution_alerts_email_type"
    t.string   "substitution_alerts_email_sending_schedule"
    t.integer  "substitution_alerts_sms"
    t.integer  "no_of_substitution_alerts_to_display"
    t.integer  "substitution_alerts_display_time"
    t.integer  "notifications_email"
    t.string   "notifications_email_type"
    t.string   "notifications_email_sending_schedule"
    t.integer  "calendar_notices_email"
    t.string   "calendar_notices_email_type"
    t.string   "calendar_notices_email_sending_schedule"
    t.integer  "session_alerts_display_time"
    t.string   "start_page"
    t.integer  "account_id"
    t.string   "default_language_for_master_scheduler"
    t.integer  "no_of_home_announcements"
    t.integer  "no_of_home_events"
    t.integer  "no_of_home_notifications"
    t.integer  "no_of_learner_dashboard_records"
    t.integer  "no_of_notifications_to_display"
    t.integer  "notifications_display_time"
    t.integer  "no_of_calendar_notices_to_display"
    t.integer  "calendar_notices_display_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "no_of_home_substitutions"
    t.integer  "daily_cap"
    t.integer  "mails_sent",                                 :default => 0
    t.integer  "coach_not_present_alert"
    t.integer  "substitution_policy_email"
    t.string   "substitution_policy_email_type"
    t.string   "substitution_policy_email_sending_schedule"
    t.integer  "timeoff_request_email"
    t.string   "timeoff_request_email_type"
  end

  create_table "preference_settings_backup_20111219_2012", :force => true do |t|
    t.integer  "substitution_alerts_email"
    t.string   "substitution_alerts_email_type"
    t.string   "substitution_alerts_email_sending_schedule"
    t.integer  "substitution_alerts_sms"
    t.string   "substitution_alerts_sms_sending_schedule"
    t.integer  "no_of_substitution_alerts_to_display"
    t.integer  "substitution_alerts_display_time"
    t.integer  "notifications_email"
    t.string   "notifications_email_type"
    t.string   "notifications_email_sending_schedule"
    t.integer  "notifications_sms"
    t.string   "notifications_sms_sending_schedule"
    t.integer  "calendar_notices_email"
    t.string   "calendar_notices_email_type"
    t.string   "calendar_notices_email_sending_schedule"
    t.integer  "calendar_notices_sms"
    t.string   "calendar_notices_sms_sending_schedule"
    t.integer  "session_alerts_display_time"
    t.string   "start_page"
    t.integer  "account_id"
    t.string   "default_language_for_master_scheduler"
    t.integer  "no_of_home_announcements"
    t.integer  "no_of_home_events"
    t.integer  "no_of_home_notifications"
    t.integer  "no_of_learner_dashboard_records"
    t.integer  "no_of_notifications_to_display"
    t.integer  "notifications_display_time"
    t.integer  "no_of_calendar_notices_to_display"
    t.integer  "calendar_notices_display_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "no_of_home_substitutions"
    t.integer  "daily_cap"
    t.integer  "mails_sent",                                 :default => 0
  end

  create_table "product_language_logs", :force => true do |t|
    t.integer  "support_user_id"
    t.string   "license_guid"
    t.string   "product_rights_guid"
    t.string   "previous_language"
    t.string   "changed_language"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "qualifications", :force => true do |t|
    t.integer  "coach_id"
    t.integer  "language_id"
    t.integer  "max_unit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dialect_id"
  end

  add_index "qualifications", ["coach_id"], :name => "index_qualifications_on_coach_id"
  add_index "qualifications", ["language_id"], :name => "index_qualifications_on_language_id"

  create_table "recent_created_coach_recurring_schedules", :id => false, :force => true do |t|
    t.integer "coach_recurring_schedule_id"
  end

  create_table "reflex_activities", :force => true do |t|
    t.integer  "coach_id",   :null => false
    t.datetime "timestamp",  :null => false
    t.string   "event",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reflex_activities", ["coach_id"], :name => "index_reflex_activities_on_coach_id"
  add_index "reflex_activities", ["timestamp", "coach_id", "event"], :name => "adding_composite_unique_index", :unique => true
  add_index "reflex_activities", ["timestamp"], :name => "index_reflex_activities_on_timestamp"

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_logger", :force => true do |t|
    t.string   "user_name",    :null => false
    t.string   "url",          :null => false
    t.datetime "time_zone",    :null => false
    t.string   "method",       :null => false
    t.datetime "request_time", :null => false
    t.string   "user_agent",   :null => false
    t.string   "ip_address",   :null => false
  end

  create_table "resources", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights_extension_logs", :force => true do |t|
    t.integer  "support_user_id"
    t.string   "license_guid"
    t.string   "reason"
    t.string   "extendable_guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "learner_id"
    t.string   "duration"
    t.datetime "extendable_created_at"
    t.datetime "extendable_ends_at"
    t.string   "action"
    t.datetime "updated_extendable_ends_at"
    t.string   "ticket_number"
  end

  create_table "roles", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "roles_tasks", :force => true do |t|
    t.integer "role_id", :null => false
    t.integer "task_id", :null => false
    t.boolean "read"
    t.boolean "write"
  end

  create_table "scheduler_metadata", :force => true do |t|
    t.boolean  "locked"
    t.string   "lang_identifier"
    t.integer  "total_sessions",                :default => 0
    t.integer  "completed_sessions",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_sessions_to_be_created",  :default => 0
    t.integer  "successfully_created_sessions", :default => 0
    t.integer  "error_sessions",                :default => 0
    t.datetime "start_of_week"
  end

  create_table "session_details", :force => true do |t|
    t.integer  "coach_session_id"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "session_metadata", :force => true do |t|
    t.integer "coach_session_id",                       :null => false
    t.boolean "teacher_confirmed",   :default => true
    t.integer "lessons"
    t.boolean "recurring",           :default => false
    t.string  "action"
    t.integer "new_coach_id"
    t.string  "cancellation_reason"
    t.integer "topic_id"
    t.text    "details"
    t.boolean "coach_reassigned"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shown_substitutions", :force => true do |t|
    t.integer  "coach_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_delivery_attempts", :force => true do |t|
    t.integer  "account_id"
    t.string   "mobile_number",                             :null => false
    t.string   "message_body"
    t.string   "api_response_successful",  :default => "0", :null => false
    t.string   "clickatell_msgid"
    t.string   "clickatell_error_code"
    t.string   "clickatell_error_message"
    t.string   "celltrust_msgid"
    t.string   "celltrust_error_code"
    t.string   "celltrust_error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffing_datas", :force => true do |t|
    t.datetime "slot_time"
    t.integer  "number_of_coaches",     :default => 0
    t.integer  "staffing_file_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffing_file_infos", :force => true do |t|
    t.datetime "start_of_the_week",                :null => false
    t.string   "file_name",                        :null => false
    t.integer  "manager_id",                       :null => false
    t.string   "status"
    t.integer  "records_created",   :default => 0
    t.string   "messages"
    t.binary   "file",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "substitutions", :force => true do |t|
    t.integer  "coach_id"
    t.integer  "grabber_coach_id"
    t.boolean  "grabbed"
    t.integer  "lang_id"
    t.integer  "coach_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "grabbed_at"
    t.boolean  "cancelled",        :default => false
    t.boolean  "was_reassigned",   :default => false
    t.string   "session_type",     :default => "normal"
    t.text     "reason"
  end

  add_index "substitutions", ["coach_id"], :name => "index_substitutions_on_coach_id"
  add_index "substitutions", ["coach_session_id"], :name => "index_substitutions_on_eschool_session_id"
  add_index "substitutions", ["grabber_coach_id"], :name => "index_substitutions_on_grabber_coach_id"

  create_table "support_languages", :force => true do |t|
    t.string   "name"
    t.string   "language_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_windows", :force => true do |t|
    t.string  "window_type"
    t.time    "start_time"
    t.time    "end_time"
    t.integer "start_wday",  :limit => 1
    t.integer "end_wday",    :limit => 1
  end

  create_table "system_notifications", :force => true do |t|
    t.integer  "notification_id"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.integer  "target_id"
    t.integer  "status",          :limit => 1, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "raw_message"
  end

  add_index "system_notifications", ["recipient_id", "recipient_type"], :name => "index_system_notifications_on_recipient_id_and_recipient_type"

  create_table "task_tracer", :force => true do |t|
    t.string   "task_name"
    t.boolean  "is_running_now",      :default => false
    t.datetime "last_successful_run"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string "name",    :null => false
    t.string "section"
    t.string "code"
  end

  create_table "temp_coach_recurring_schedules", :force => true do |t|
    t.integer  "coach_id",                          :null => false
    t.integer  "day_index",            :limit => 1, :null => false
    t.time     "start_time",                        :null => false
    t.datetime "recurring_start_date",              :null => false
    t.datetime "recurring_end_date"
    t.integer  "language_id",                       :null => false
    t.integer  "external_village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "temp_coach_recurring_schedules", ["language_id", "recurring_end_date"], :name => "idx_c_rec_sched_lang_end_date"

  create_table "temp_data", :force => true do |t|
    t.binary   "data",       :limit => 16777215
    t.boolean  "done"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "guid"
    t.string   "title"
    t.string   "description"
    t.string   "cefr_level"
    t.integer  "language"
    t.boolean  "selected"
    t.boolean  "removed",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "revision_id", :default => "NA"
  end

  create_table "trigger_events", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  add_index "trigger_events", ["name"], :name => "index_trigger_events_on_name"

  create_table "unavailable_despite_templates", :force => true do |t|
    t.integer  "coach_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "unavailability_type", :limit => 1, :default => 0
    t.text     "comments"
    t.integer  "approval_status",     :limit => 1, :default => 0
    t.integer  "coach_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "unavailable_despite_templates", ["ancestry"], :name => "index_unavailable_despite_templates_on_ancestry"
  add_index "unavailable_despite_templates", ["approval_status"], :name => "idx_unavailable_despite_template_approval_status"
  add_index "unavailable_despite_templates", ["coach_id"], :name => "idx_unavailable_despite_template_coach_id"
  add_index "unavailable_despite_templates", ["end_date"], :name => "idx_unavailable_despite_template_end_date"
  add_index "unavailable_despite_templates", ["start_date"], :name => "idx_unavailable_despite_template_start_date"

  create_table "uncap_learner_logs", :force => true do |t|
    t.integer  "support_user_id"
    t.string   "case_number",     :null => false
    t.string   "license_guid"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_actions", :force => true do |t|
    t.string   "user_name"
    t.string   "user_role"
    t.text     "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_languages", :force => true do |t|
    t.string   "user_mail_id"
    t.string   "language_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_update_execution_details", :force => true do |t|
    t.string   "user_update_identifier", :limit => 45
    t.integer  "last_processed_id"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

  add_index "user_update_execution_details", ["user_update_identifier"], :name => "index_user_update_execution_details_on_user_update_identifier"

  create_table "user_villages", :force => true do |t|
    t.string   "user_mail_id"
    t.string   "village_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "village_preferences", :force => true do |t|
    t.integer  "village_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
