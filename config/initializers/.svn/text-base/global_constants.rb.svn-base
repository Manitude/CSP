# All constants go here
FILTER_NAMES = { "Michelin" => ["TMMMichelinLanguage"], "TOTALe/ReFLEX" => ["TotaleLanguage","ReflexLanguage"], "AEB" => ["AriaLanguage"], "RSA Live Tutoring"  => ["TMMLiveLanguage"], "RSA Phone Lessons" => ["TMMPhoneLanguage"]}
TOPICS_LEARNING_LANG_CODE = {"en-US" => "AUS", "en-GB" => "AUK"}
SUPER_SAAS_SCHEDULE_NAME = {
  "AUS" => "Advanced_English_US",
  "AUK" => "Advanced_English_UK",
  "AUSG" => "Advanced_English_US_Group",
  "AUKG" => "Advanced_English_UK_Group",
  "TMM-MCH-L" => "RSA_MICHELIN",
  "TMM-ENG-P" => "RSA_ENGLISH",
  "TMM-NED-P" => "RSA_DUTCH",
  "TMM-FRA-P" => "RSA_FRENCH",
  "TMM-DEU-P" => "RSA_GERMAN",
  "TMM-ITA-P" => "RSA_ITALIAN",
  "TMM-ESP-P" => "RSA_SPANISH"
}
EMERGENCY_SESSION_LIMITATION = {:aria => 0.5}
DAYS_IN_A_WEEK = (0..6).to_a
QUARTER_HOURS_IN_A_DAY = (0..95).to_a
HALF_HOURS_IN_A_DAY = (0..47).to_a
HOURS_IN_A_DAY = (0..23).to_a
d = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
START_OF_THE_WEEK = 'Sunday' # Switch to 'Sunday' to start the week on Sunday
WEEKDAY_NAMES = (START_OF_THE_WEEK == 'Monday') ? (d.push d.shift) : d
AVAILABILITY_STATUSES = ['Available', 'Scheduled', 'Unavailable']
COACH_OR_MANAGER = ['coach', 'coach_manager']
STATES_OF_APPROVAL = ['Draft' , 'Approved' ]
TEMPLATE_STATUS = ['Draft' , 'Approved' ]
SESSION_LENGTH_IN_SECS = 3600
HALF_HOUR_SESSION_LENGTH_IN_SECS = 1800
APPROVAL_STATUS = ['Pending', 'Approved', 'Denied', 'Edited','Cancelled']
STATUS_FOR_TIME_OFF_REPORT = {"Pending" => 0, "Approved" => 1, "Denied" => 2}
UNAVAILABILITY_TYPE = ['Time off', 'Substitute Requested','Substitute Triggered', 'Back Early', 'Auto Cancelled', 'Reassigned']
SESSION_START_TIME_MAPPING = {1 => '00:00', 2 => '15:00', 3 => '30:00', 4 => '45:00'}
MAX_LEVEL_TAUGHT = 5
UNITS_PER_LEVEL = 4
MAX_UNITS_TAUGHT = UNITS_PER_LEVEL * MAX_LEVEL_TAUGHT
UNITS_COLLECTION = (1..MAX_UNITS_TAUGHT).to_a
DEFAULT_TIME_ZONE = 'America/New_York'
TIME_LIMIT_FOR_AVAILABILITY_MODIFICATION = 2.weeks.seconds
N = 4 #Weeks we should be looking in the history in Master Scheduler.
DEFAULT_NUMBER_OF_SEATS = 4
MAX_WEEKS_TO_BE_PUSHED_AT_ONCE = 6

#The default return type when any of these unfortunate things happen
SESSIONS_NOT_CREATED = SESSION_COULD_NOT_BE_SUBSTITUTED = 1
COACH_PROFILE_COULD_NOT_BE_CREATED_OR_UPDATED = 1

#Custom Messages used in the application
MSG_MANAGER_ASSIGN_SUBSTITUIONS_FAILURE = 'This Session has just got a substitute. Kindly refresh the page'
MSG_COACH_SUBSTITUIONS_SUCCESS = 'You are now scheduled to substitute for this session.'
MSG_COACH_SUBSTITUIONS_FAILURE = 'You have a session at this time slot'
MSG_MANAGER_CANCELLED_SESSION_SUCCESS = 'You successfully cancelled this session'
MSG_MANAGER_CANCELLED_SESSION_FAILURE = 'We are currently experiencing system downtime issues. Please try back later.'

MSG_MANAGER_REASSIGN_SUBSTITUIONS_SUCCESS = 'You successfully re-assigned this session'
MSG_MANAGER_REASSIGN_SUBSTITUIONS_CHOKE = 'This Coach is already scheduled for this date/time. Please select another Coach.'
MSG_MANAGER_REASSIGN_SUBSTITUIONS_ALREADY_GRABBED = 'This session has been grabbed already.'
MSG_MANAGER_REASSIGN_SUBSTITUIONS_ALREADY_CANCELED = 'This session has been canceled already.'
MSG_MANAGER_REASSIGN_SUBSTITUIONS_ALREADY_REASSIGNED = 'This session has been reassigned already.'

MAX_SUBSTITUION_CUTOFF_HOUR = 48
MS_BLOCK_SIZE = 100
SESSIONS_PER_PAGE_FROM_ESCHOOL =100
TIME_RANGE_BLOCK_SIZE = 4
BLOCK_SIZE_FOR_CANCELLATION = 40

# This Constant is used for validation
EXTENDED_SUBSTITUTE_REQUEST_TIME = 29.minutes

TIME_FRAME = ["0","00","15","30","45"]
LOTUS_REAL_TIME_DATA_REFRESH_TIME = 30.seconds
SUBSTITUTION_DATA_REFRESH_TIME = 30.seconds

COACH_START_PAGES             = {
  "Home"                      => "HOME",
  "Announcements"             => "ANNOUNCEMENTS",
  "Events"                    => "EVENTS",
  "Notifications"             => "COACH_NOTIFICATIONS",
  "Substitutions"             => "COACH_SUBSTITUTIONS",
  "My Schedule"               => "CALENDAR"}

ARIA_COACH_START_PAGES        =  {
  "Home"                      => "HOME",
  "Announcements"             => "ANNOUNCEMENTS",
  "Events"                    => "EVENTS",
  "Notifications"             => "COACH_NOTIFICATIONS",
  "Substitutions"             => "COACH_SUBSTITUTIONS",
  "My Schedule"               => "CALENDAR"}


COACH_MANAGER_START_PAGES     = {
  "Home"                      => "HOME",
  "Announcements"             => "ANNOUNCEMENTS",
  "Events"                    => "EVENTS",
  "Notifications"             => "CM_NOTIFICATIONS",
  "Dashboard"                 => "DASHBOARD",
  "Substitutions"             => "CM_SUBSTITUTIONS",
  "Master Scheduler"          => "CM_MS"}

SUPPORT_USER_LEAD_START_PAGES = {
  "Profile"                   => "VIEW_SUPPORT_PROFILE",
  "Learner Search"            => "LEARNERS_SEARCH",
  "Dashboard"                 => "DASHBOARD"}


START_PAGE_URLS               = {
  "COACH_NOTIFICATIONS"       => "notifications_url",
  "COACH_SUBSTITUTIONS"       => "substitutions_url",
  "CM_NOTIFICATIONS"          => "manager_notifications_url",
  "CM_SUBSTITUTIONS"          => "substitutions_url",
  "CM_MS"                     => "schedules_url",
  "CALENDAR"                  => "my_schedule_url",
  "ANNOUNCEMENTS"             => "announcements_url",
  "EVENTS"                    => "events_url",
  "LEARNERS_SEARCH"           => "learners_url",
  "DASHBOARD"                 => "dashboard_url",
  "VIEW_SUPPORT_PROFILE"      => "view_support_profile_url",
  "HOME"                      => "homes_url"}

COMMON_SCHEDULE_TYPES         = {"Immediately" => "IMMEDIATELY","Hourly" => "HOURLY","Daily" => "DAILY"}
SUBSTITUTION_POLICY_ALERT_TYPES = {"Daily" => "DAILY","Weekly" => "WEEKLY","Monthly" => "MONTHLY"}
COMMON_EMAIL_TYPES            = {"Personal" => "PER", "Rosetta" => "RS"}
COMMON_DISPLAY_COUNT          = {0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5}
COMMON_DISPLAY_COUNT_SUBSTITUTIONS = {0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10}
DASHBOARD_RECORDS_COUNT       = {5 => 5, 10 => 10, 15 => 15}
SUBSTITUTION_DISPLAY_COUNT    = {0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5}
ALERT_SCHEDULE_FOR_SESSION_WITH_NO_COACH = {2 => 2, 4 => 4, 24 => 24}

# Creating hash for substitutions alert display.
sub_display_hash              = {}
options={"2 hours" => 2.hours, "24 hours" => 24.hours, "2 days" => 2.days.seconds, "3 days" => 3.days.seconds, "one week" => 1.week.seconds}
options.each{|key,time| sub_display_hash[key] = time}
SUBSTITUTION_DISPLAY_TIMES    = sub_display_hash

# Creating hash for sessions alert display.
session_display_hash         = {}
(5..30).collect{|time| session_display_hash[time] = time}
SESSION_ALERT_DISPLAY_TIMES  = session_display_hash

#Learner related ones being refactored to Global constants
USER_SOURCE_TYPES = %W{community/user rs_manager/user}.freeze
#Has to store the user's user_source_type as integer'
SOURCE_TYPE_INDEXED = { "Community::User" => 1, "RsManager::User" => 3}.freeze
#Store the user_subscription_type as an integer for bitwise comparision later. Similar to chmod on unix.
SUBSCRIPTION_TYPES = { :TOTALe => 4, :RWorld => 2, :OSub => 1 }
UPDATE_IDENTIFIER = {:profile => "profile", :license => "license", :license_identifier => "license_identifier", :product_right => "product_right", :village_id_update => "village_id_update", :remove_duplicate_learner => "remove_duplicate_learner", :synch_eschool => "synch_eschool_data"}
BATCH_SIZE = { :profile_update => 1000, :users_initial_insert => 5000}
FEEDBACK_MESSAGE = ["", "Needs Improvement", "Average", "Good", "Very good", "Outstanding"]
COACH_SESSION_STATUS = {"Created Locally" => 0, "Created in Eschool" =>1}# For Reflex it should always be 1
#for aria sessions, using 0 as a value to identify sessions whose slot id is not present in CSP

TOTAL_SESSION_COUNT_LIMIT_FOR_COACH = 30
GRABBED_SESSION_COUNT_LIMIT_FOR_COACH = 10

#Color codes for ReFlex Staffing Reconciliation Report
SCHEDULED_UNDER_PROJECTION = {'1-3' => '#E6EFB9','4-6' => '#CAE19A','7 or more' => '#B0D89E'}
SCHEDULED_TO_PROJECTION = {'0' => '#FEF3DA'}
SCHEDULED_ABOVE_PROJECTION = {'1-3' => '#F8F49B','4-6' => '#FDC588','7 or more' => '#F79C7B'}
DEFAULT_LESSON_VALUE = 4
TEACH_LANGUAGE = {
  "TMM-DEU-P" => "DE-DE",
  "TMM-ENG-P" => "EN-US",
  "TMM-ESP-P" => "ES-ES",
  "TMM-FRA-P" => "FR-FR",
  "TMM-ITA-P" => "IT-IT",
  "TMM-NED-P" => "NL-NL",
  "TMM-MCH-L" => "FR-FR_MICHELIN"
}
ContactType = {
  0 => "Undefined",
  1 => "PhoneNumber",
  2 => "ScreenSharingEndPoint"
}

FALSE_COACH_EMAIL = 'tutor.tbd@gmail.com'