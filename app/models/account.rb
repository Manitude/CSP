# == Schema Information
#
# Table name: accounts
#
#  id                         :integer(4)      not null, primary key
#  user_name                  :string(255)
#  full_name                  :string(255)
#  preferred_name             :string(255)
#  rs_email                   :string(255)
#  personal_email             :string(255)
#  skype_id                   :string(255)
#  primary_phone              :string(255)
#  secondary_phone            :string(255)
#  birth_date                 :date
#  hire_date                  :date
#  bio                        :text(65535)
#  manager_notes              :text(65535)
#  active                     :boolean(1)      default(TRUE), not null
#  manager_id                 :integer(4)
#  created_at                 :datetime
#  updated_at                 :datetime
#  type                       :string(255)
#  region_id                  :integer(4)
#  next_session_alert_in      :integer(3)
#  last_logout                :datetime
#  country                    :string(255)
#  native_language            :string(255)
#  other_languages            :string(255)
#  address                    :string(255)
#  lotus_qualified            :boolean(1)      default(TRUE)
#  next_substitution_alert_in :integer(10)     default(24)
#  mobile_phone               :string(255)
#  is_supervisor              :boolean(1)
#  mobile_country_code        :string(255)
#  aim_id                     :string(255)
#  primary_country_code       :string(255)
#
class Account < ActiveRecord::Base

  attr_accessor_with_default :time_zone, 'Eastern Time (US & Canada)'
  audit_logged :audit_logger_class => CustomAuditLogger
  has_many   :qualifications, :dependent  => :destroy, :foreign_key => :coach_id
  has_many   :languages, :through => :qualifications, :foreign_key => :coach_id
  has_many   :system_notifications, :order => 'created_at DESC', :as => 'recipient', :dependent => :destroy, :foreign_key => :coach_id ,  :conditions => ['created_at >= ?', (Time.now.utc - 30.days)]
  has_one    :preference_setting, :dependent  => :destroy

  has_many :uncap_learner_logs, :foreign_key => 'support_user_id'

  validates :user_name, :uniqueness => true
  validate :hire_date_not_in_future, :email_validations, :check_mandatory_fields, :good_phone_numbers, :validate_mobile_country_code, :validate_primary_country_code
  validate :validate_special_characters_for_user_name, :on => :create

  laziness_lookup_attribute :id # defines Account[some_id]

  scope :active, :conditions => {:active => true}
  scope :subscribed_to_coach_not_present_alert, :include => :preference_setting, :conditions => {'preference_settings.coach_not_present_alert' => 1}

  accepts_nested_attributes_for :qualifications, :allow_destroy => true

  has_attached_file :photo, :storage => :database, :url =>'/users/photos/:id/:filename' if column_names.include?("photo_file")
  validate :check_image_content_type
  validate :check_image_file_size

  default_scope select((column_names - ['photo_file']).map { |column_name| "`#{table_name}`.`#{column_name}`"})

  include CoachViewHelperMethods

  def get_preference
    if self.preference_setting.nil?
       default_start_page = is_coach? ? COACH_START_PAGES["My Schedule"] : (is_manager? ? COACH_MANAGER_START_PAGES["Master Scheduler"] : COACH_MANAGER_START_PAGES["Dashboard"])
       options = {}
       options[:start_page] = default_start_page
       options[:substitution_alerts_display_time] = SUBSTITUTION_DISPLAY_TIMES["24 hours"]
       options[:no_of_substitution_alerts_to_display] = SUBSTITUTION_DISPLAY_COUNT[5]
       options[:no_of_home_announcements] = COMMON_DISPLAY_COUNT[5]
       options[:no_of_home_events] = COMMON_DISPLAY_COUNT[5]
       options[:no_of_home_notifications] = COMMON_DISPLAY_COUNT[5]
       options[:no_of_home_substitutions] = COMMON_DISPLAY_COUNT[5]
       options[:substitution_alerts_email_sending_schedule] = COMMON_SCHEDULE_TYPES["Immediately"]
       options[:substitution_alerts_email_type] = COMMON_EMAIL_TYPES["Personal"]
       options[:notifications_email_sending_schedule] = COMMON_SCHEDULE_TYPES["Immediately"]
       options[:notifications_email_type] = COMMON_EMAIL_TYPES["Personal"]
       options[:calendar_notices_email_sending_schedule] = COMMON_SCHEDULE_TYPES["Immediately"]
       options[:calendar_notices_email_type] = COMMON_EMAIL_TYPES["Personal"]
       options[:session_alerts_display_time] = SESSION_ALERT_DISPLAY_TIMES[10] if is_coach?
       options[:substitution_alerts_sms] = 1 if is_coach?
    end
    self.preference_setting ||= PreferenceSetting.new(options)
  end

  def is_tier1_support_user?
    is_a?SupportUser
  end

  def is_tier1_support_lead?
    is_a?SupportLead
  end

  def is_led_user?
    is_a?LedUser
  end

  def is_tier1_support_harrisonburg_user?
    is_a?SupportHarrisonburgUser
  end

  def is_tier1_support_concierge_user?
    is_a?SupportConciergeUser
  end

  def is_manager?
    is_a?CoachManager
  end

  def is_coach?
    is_a?Coach
  end

  def is_admin?
    is_a?Admin
  end

  # THIS METHODS HAS TO BE MODIFIED AFTER A NEW ROLE HAS BEEN ASSIGNED FOR THE API
  # def is_THATUSER?
  #   is_a?THATUSER
  # end

  def is_community_moderator?
    is_a?CommunityModerator
  end

  def account_type
    read_attribute(:type).constantize
  end

  def all_language_identifier
    @lang_identifier ||= Language.all_sorted_by_name.collect(&:identifier)
  end

  def system_notifications_not_reassigned_or_grabbed(limit = true)
    notification_query = "SELECT *
                          FROM system_notifications
                          WHERE
                            recipient_id = #{self.id}
                            AND created_at >= '#{(Time.now- 30.days).to_s(:db)}'
                            AND (
                                  raw_message like 'Your requested time off from%has been denied%'
                                  OR raw_message like 'Your%Session on%has been cancelled%'
                                  OR notification_id NOT IN (select id from trigger_events where name in ('SUBSTITUTION_GRABBED','MANUALLY_REASSIGNED','SESSION_CANCELLED','SUBSTITUTE_REQUESTED'))
                                )
                          ORDER BY created_at DESC"
    notifications = SystemNotification.find_by_sql(notification_query).select{|notification| !notification.message.blank?}
    notifications = notifications.slice(0, get_preference.no_of_home_notifications) if limit
    notifications
  end

  def system_notifications_reassigned_or_grabbed(limit)
    substitution_query = "SELECT *
                          FROM system_notifications
                          WHERE
                            recipient_id = #{self.id}
                            AND created_at >= '#{(Time.now- 30.days).to_s(:db)}'
                            AND (
                                  raw_message like 'You have been assigned%'
                                  OR notification_id IN (select id from trigger_events where name in ('SUBSTITUTION_GRABBED','MANUALLY_REASSIGNED','SESSION_CANCELLED'))
                                )
                            ORDER BY created_at DESC"
    SystemNotification.find_by_sql(substitution_query).select{|notification| !notification.message.blank?}.slice(0, limit)
  end

  def manage_substitutions(duration = nil, coach_id = nil, language_id = nil)
    substitutions = Hash.new{|hash, key| hash[key] = []}
    villages = Hash[Community::Village.all.collect{|v| [v.id, v.name]}]
    qualified_lang = self.languages.map(&:identifier)
    eligible_lang = fetch_eligible_languages(self.languages).collect(&:identifier)
    all_substitutions = Substitution.for_language(eligible_lang, duration)
    all_substitutions.reject! { |sub| (eligible_lang - qualified_lang).include?(sub.coach_session.language_identifier) && !sub.coach_session.appointment? }
    substitutions[:appointment_langs] = all_substitutions.collect{|sub| sub.language if sub.coach_session.appointment?}.compact.uniq
    substitutions[:coach] = all_substitutions.collect{|sub| sub.coach}.compact.uniq
    if duration
      unless coach_id.blank?
        if coach_id == "Extra Sessions"
          all_substitutions = all_substitutions.select{|sub| sub.coach.blank?}
        else
          all_substitutions = all_substitutions.select{|sub| sub.coach_id.to_s == coach_id}
        end
      end
      if language_id && (language_id==language_id.to_i.to_s)
        all_substitutions = all_substitutions.select{|sub| (sub.language.id.to_s == language_id) && !sub.coach_session.appointment? } unless language_id.blank?
      elsif language_id
        all_substitutions = all_substitutions.select{|sub| (sub.language.alias_id.to_s == language_id) && sub.coach_session.appointment? } unless language_id.blank?
      end
    else
      max_subs = get_preference.no_of_home_substitutions
    end
    eschool_session_ids = all_substitutions.collect{|sub| sub.coach_session.eschool_session_id if sub.coach_session.totale?}.compact.uniq
    eschool_sessions = ExternalHandler::HandleSession.find_sessions(TotaleLanguage.first, {:ids => eschool_session_ids}) unless eschool_session_ids.blank?
    bulk_sessions = {}
    eschool_sessions.collect do |es|
      bulk_sessions[es.eschool_session_id] = es
    end if !eschool_sessions.blank?
    all_substitutions.each do |sub|
      sub_requested_session = sub.coach_session
      next if(sub_requested_session.supersaas? && sub_requested_session.supersaas_session.blank?) #Skip the sub record if the sessions is an aria session and the corresponsing supersaas session is not found
      if !sub_requested_session.is_extra_session? || !is_coach? || !is_excluded?(sub_requested_session)
        sub_requested_session.sess = bulk_sessions[sub_requested_session.eschool_session_id.to_s]
        sub_hash = sub.to_hash
        sub_hash[:is_appointment] = sub.coach_session.appointment?
        if is_coach?
          next if (grab_disable = !can_grab?(sub))
          sub_hash[:grab_disable] = grab_disable
        end
        if sub_requested_session.sess
          village = villages[sub_requested_session.sess.external_village_id.to_i]
          sub_hash[:village] = village if village
        end
        substitutions[:data] << sub_hash
        substitutions[:lang] << sub.language unless sub.coach_session.appointment? # collect languages of all substitutions except appointments for substitution page language filter;
      end
      break if max_subs == substitutions[:data].size
    end

    if is_coach?
      beginning_of_week = TimeUtils.beginning_of_week
      8.times do |n|
        n_weeks_from_now = beginning_of_week + n.weeks
        substitutions[:weeks_exceeded_in_threshold] << n_weeks_from_now if threshold_reached?(n_weeks_from_now).detect{|x| x===true}
      end
    end
    substitutions[:lang].uniq!
    substitutions
  end

  def system_notifications_in_last_day
    self.system_notifications.select{ |notification| !notification.message.blank? && notification.created_at >= (Time.now.utc - 1.day)}
  end

  def system_notifications_in_last_hour
    self.system_notifications.select{ |notification| !notification.message.blank? && notification.created_at >= (Time.now.utc - 1.hour)}
  end

  def account_type_label
    read_attribute(:type).to_s.downcase
  end

  def add_qualifications_for(lang_id)
    self.qualifications.create(:language_id => lang_id, :max_unit => nil) #Max Unit is nil for manager
  end

  def tzone
    time_zone
  end

  def email
    rs_email
  end

  def tzone_sort
    Time.now.in_time_zone(time_zone).strftime("%Z")
  end

  # Returns the time zone difference (WRT UTC) in hours. Diff between coach's time zone and UTC.
  # Ex: Returns 5.5 for coach's time zone = IST, 0.0 for UTC
  def offset
    self.utc_offset(Time.zone.now)/3600.0
  end

  def utc_offset(date)
    date.in_time_zone(self.tzone).utc_offset
  end

  def find_by_region_and_language(type, limit = nil)
    if is_coach?
      languages = [-1]
      languages += qualifications.collect(&:language_id)
      regions = [-1]
      regions << region_id if region
      condition = ["language_id in (?) and region_id in (?)", languages, regions]
    end
    type.camelize.constantize.future.where(condition).limit(limit)
  end

  def announcements(home_page = true)
    limit = get_preference.send("no_of_home_announcements") if home_page
    find_by_region_and_language("announcement", limit)
  end

  def events(home_page = true)
    limit = get_preference.send("no_of_home_events") if home_page
    find_by_region_and_language("event", limit)
  end

  def method_missing(method_id, *args)
    if match = matches_dynamic_permission_check?(method_id)
      permission_type,task = tokenize_roles(match.captures.first)
      role = Role.find_by_name("All")

      if self.is_community_moderator? || (permission_type == 'read' and role.tasks.collect(&:code).include? task ) || (self.is_coach? and Task.find_by_code(task).section == "Coach Profile")
        return true
      else
        role = Role.find_by_name(self.read_attribute(:type))
        if role && role.tasks.collect(&:code).include?(task)
          type = RolesTask.find_by_role_id_and_task_id(role.id,Task.find_by_code(task).id)
          return true if ( type.read && permission_type == 'read' ) || ( type.write && permission_type == 'write')
        end
      end
      return false
    else
      super
    end
  end

  def native_language
    self['native_language'] || "en-US"
  end

  def translated_attributes
    {:full_name => _("Full_Name82853947"), :primary_phone => _("Primary_Phone599295E5"),
      :rs_email => _("RS_Email87C179A3"), :personal_email => _("Personal_Email491AD2AA"),
      :native_language => _("Native_LanguageC5185796"),
      :secondary_phone => _("Secondary_PhoneEB85EC35"), :mobile_phone => "Mobile Phone",
      :mobile_country_code => "Mobile Country Code", :primary_country_code => "Primary Country Code", :ad_name => "AD Name"}
  end

  def mandatory_fields
    [:full_name, :primary_phone, :rs_email , :primary_country_code, :user_name ]
  end

  def mobile_number_with_country_code
    mobile_country_code && mobile_phone && (mobile_country_code + mobile_phone)
  end

  def has_international_mobile_number?
    mobile_country_code.to_s != '1'
  end

def send_sms(message, resending_activation_code = false)
    return logger.info('SMS delivery disabled by configuration.  See application configurations') unless ::Sms.ok_to_send_messages?
    begin
      raise "Invalid mobile or country code for #{user_name}"  unless valid_mobile_phone? and valid_mobile_country_code?
      ::Sms.send_message(self, message, resending_activation_code)
    rescue Clickatell::API::Error
      logger.debug("API error caught and supressed")
    rescue Exception => e
      HoptoadNotifier.notify(Exception.new("SMS has not been sent to the user #{user_name} with the mobile number #{mobile_phone} because #{e.message}"))
    end
  end

  def test_send_sms(message, resending_activation_code = false)
    if ::Sms.ok_to_send_messages?
      begin
          ::Sms.send_message(self, message, resending_activation_code) #proper send
          mob_num = self.mobile_number_with_country_code
          self.mobile_phone.gsub!(/\d/, '0')
          ::Sms.send_message(self, message, resending_activation_code) #make api to throw error
          self.mobile_phone = mob_num
          raise "App generated error"
      rescue Exception => e
        HoptoadNotifier.notify(e)
      end
    else
      logger.debug("SMS delivery disabled by configuration.  See site_settings.yml")
      true
    end
  end


  # def self.find_all_active_coaches(lang_identifier)
  #     This method is moved to coach model, If anyone sees it in future, please delete this commented method
  # end

  def self.email_recipients(type, language_id = nil,region_id = nil)
    language    = Language[language_id]
    region      = Region.find_by_id(region_id)
    condition   = "accounts.active = 1 AND preference_settings.#{type} = 1 AND preference_settings.#{type}_sending_schedule = 'IMMEDIATELY' AND (preference_settings.daily_cap IS NULL OR preference_settings.daily_cap > preference_settings.mails_sent)"
    condition  += " and qualifications.language_id = '#{language.id}'" if language.present?
    condition  += " and accounts.region_id = '#{region_id}'" if region.present?
    ids = []
    emails = []
    where(condition).joins(:qualifications).includes(:preference_setting).each do |user|
      ids << user.id
      emails << ((user.get_preference.send(type+'_type') == "PER")? user.personal_email : user.rs_email)
    end
    ActiveRecord::Base.connection.execute("UPDATE preference_settings SET mails_sent = mails_sent + 1 WHERE account_id IN (#{ids.join(",")})") if ids.any?
    emails.uniq
  end

  def get_preferred_mail_id_by_type(type)
    mail_id_type = get_preference.prefered_mail_id_type(type)
    (mail_id_type == "PER")? personal_email : rs_email if mail_id_type
  end

  private

  def fetch_eligible_languages(qualified_lang)
    eligible_lang = []
    qualified_lang.each do |lang|
      if lang.identifier.start_with?("TMM")
        eligible_lang = eligible_lang | Language.fetch_same_group_appointment_languages(Language[lang].alias_id.split('-').first)
      else
        eligible_lang << lang
      end
    end
    eligible_lang
  end

  def hire_date_not_in_future
    errors.add(:hire_date, "cannot be in the future.") if self.hire_date && self.hire_date > Date.today
  end

  def good_phone_numbers
    [:primary_phone, :secondary_phone, :mobile_phone].each do |phone_type|
      phone_no = self.send(phone_type)
      if !phone_no.blank? && !(phone_no.gsub(/[^0-9]/, "") =~ /^\d{10}$/)
        errors.add(translated_attributes[phone_type], _("must_be_10_digits_and_entered_in_the_following_forC93C3BB"))
      elsif !phone_no.blank? && phone_no.match(/^[a-zA-Z0-9]*$/).nil?
        errors.add(translated_attributes[phone_type]," cannot contain spaces or special characters")
      elsif !phone_no.blank? && phone_no.gsub(/[^0-9]/, "") =~ /^\d{10}$/
        self[phone_type] = phone_no.gsub(/[^0-9]/, "")
      end
    end
  end

  def validate_mobile_country_code
    if mobile_country_code.blank? && !mobile_phone.blank?
      errors.add(translated_attributes[:mobile_country_code], _("cant_be_blank5710A027"))
    elsif !mobile_country_code.blank? && (!(mobile_country_code =~ /\A[+-]?\d+\Z/) || mobile_country_code =~ %r{^[+-]?0+$} )# require integer, can't be all zeros
      errors.add(translated_attributes[:mobile_country_code], "must be number")
    elsif sanitized_mobile_country_code.length > 5;
      errors.add(translated_attributes[:mobile_country_code], "should not exceed 5 digits")
    end
  end

  def validate_primary_country_code
    if !primary_country_code.blank? && (!(primary_country_code =~ /\A[+-]?\d+\Z/) || primary_country_code =~ %r{^[+-]?0+$} )# require integer, can't be all zeros
      errors.add(translated_attributes[:primary_country_code], "must be number")
    elsif sanitized_primary_country_code.length > 5;
      errors.add(translated_attributes[:primary_country_code], "should not exceed 5 digits")
    end
  end

  def email_validations
    [:rs_email, :personal_email].each do |attr|
      email = self.send(attr)
      errors.add translated_attributes[attr], _("is_invalid98D57F74") if !email.blank? && !RosettaStone::VALID_EMAIL_REGEX.match(email)
    end
    if !self.rs_email.blank?
      users = Account.where(["rs_email = ? and id != ?", self.rs_email, self.id])
      errors.add(translated_attributes[:rs_email], _("has_already_been_taken3059C68E")) if users.any?
    end
  end

  def check_mandatory_fields
   if self.type == 'Coach' ||  self.type == 'CoachManager'
    lang_ids = self.qualifications.collect(&:language_id)
    fields = mandatory_fields
    if self.type == 'Coach'
     fields << :preferred_name unless lang_ids.select{|s| s == Language["AUS"].id || s == Language["AUK"].id}.empty?
    end
    fields.each do |attr|
      value = self.send(attr)
      errors.add attr.to_s, _("cant_be_blank5710A027") if value.blank?
    end
   end
  end


  def validate_special_characters_for_user_name
    errors[:base] << "#{translated_attributes[:ad_name]} cannot contain special characters or white spaces." if self.user_name && self.user_name.match(/^[a-zA-Z0-9]*$/).nil?
  end

  def matches_dynamic_permission_check?(method_id)
    /^can?#{'_'}([a-zA-Z]\w*)\?$/.match(method_id.to_s)
  end

  def tokenize_roles(string_to_split)
    string_to_split.split(/_/,2)
  end

  # note: the Sms class also sanitizes before sending to clickatell - it strips leading zeros from the country code as well
  def sanitize_phone_numbers
    self.mobile_phone = mobile_phone && sanitized_mobile_number
    self.mobile_country_code = mobile_country_code && sanitized_mobile_country_code
  end

  def sanitized_mobile_number
    strip_non_digits_and_leading_zeros(mobile_phone)
  end

  def sanitized_contact_phone_number
    strip_non_digits_and_leading_zeros(contact_phone_number)
  end

  def sanitized_mobile_country_code
    strip_non_digits_and_leading_zeros(mobile_country_code)
  end

  def sanitized_primary_country_code
    strip_non_digits_and_leading_zeros(primary_country_code)
  end

  def sanitized_contact_phone_country_code
    strip_non_digits_and_leading_zeros(contact_phone_country_code)
  end

  def strip_non_digits_and_leading_zeros(number)
    # only digits, kill leading zeros
    number.to_s.gsub(/\D/, '').sub(%r{^0+}, '')
  end

  def valid_mobile_country_code?
    #if number is blank or mobile code cannot cross 5 digits or must contain only digits or all digits are zero
    !mobile_country_code.blank? && !(mobile_country_code.length >5) && !(mobile_country_code =~ /\A\d+\Z/).nil? && (mobile_country_code =~ /\A[0]+\Z/).nil?
  end

  def valid_mobile_phone?
    #if number is blank or must contain only ten digits or all numbers are zero
    !mobile_phone.blank? && !(mobile_phone =~ /\A\d{10}\Z/).nil? && (mobile_phone =~ /\A[0]+\Z/).nil?
  end

  def check_image_content_type
   if(self.photo_content_type.present? && !(['image/jpeg', 'image/gif','image/png'].include?(self.photo_content_type)))
    errors.add_to_base("Profile image must be in either .jpeg, .png, or .gif format")
   end
  end

  def check_image_file_size
   if (self.photo_file_size.present? && !(self.photo_file_size <= 100.kilobytes))
    errors.add(:base, "Profile image must not exceed 100Kb.")
   end
  end

end
