# == Schema Information
#
# Table name: users
#
#  id                                :integer(4)      not null, primary key
#  email                             :string(255)     not null
#  salt                              :string(40)      
#  created_at                        :datetime        
#  updated_at                        :datetime        
#  remember_token                    :string(255)     
#  remember_token_expires_at         :datetime        
#  activation_code                   :string(40)      
#  activated_at                      :datetime        
#  first_name                        :string(255)     
#  last_name                         :string(255)     
#  flickr_alias                      :string(255)     
#  gender                            :string(255)     
#  disabled                          :boolean(1)      
#  guid                              :string(255)     
#  selected_language_id              :integer(4)      
#  launch_token                      :string(255)     
#  avatar_file                       :string(255)     
#  mobile_number                     :string(255)     
#  country_iso                       :integer(4)      
#  has_seen_arena_demo               :boolean(1)      
#  preferred_name                    :string(255)     
#  birth_date                        :date            
#  state_province                    :string(255)     
#  city                              :string(255)     
#  time_zone                         :string(255)     default(""), not null
#  mobile_number_at_activation       :string(255)     
#  mobile_country_code               :string(255)     
#  pera_pera                         :boolean(1)      not null
#  mobile_country_code_at_activation :string(255)     
#  accepted_terms_date               :datetime        
#  accepted_terms                    :boolean(1)      not null
#  simbio_language_id                :integer(4)      
#  notify_via_sms                    :boolean(1)      not null
#  week_start                        :string(255)     default("sunday")
#  last_viewed_locale                :string(255)     default("en-US"), not null
#  speech_logging_enabled            :boolean(1)      not null
#  practice_both_englishes           :boolean(1)      default(TRUE), not null
#  practice_both_spanishes           :boolean(1)      default(TRUE), not null
#  address_line_1                    :string(255)     
#  address_line_2                    :string(255)     
#  postal_code                       :string(255)     
#  contact_phone_country_code        :string(255)     
#  contact_phone_number              :string(255)     
#  user_agent                        :string(255)     
#  creation_account_identifier       :string(255)     
#  facebook_access_token             :string(255)     
#  sync_to_facebook                  :boolean(1)      
#  achievements_checked_at           :datetime        default(Tue Dec 07 17:44:52 UTC 2010), not null
#  support_language_iso              :string(255)     
#  vetted                            :boolean(1)      not null
#  kid_validated                     :boolean(1)      
#  last_viewed_site                  :string(255)     
#  parent_has_accepted_terms         :boolean(1)      
#  parent_user_id                    :integer(4)      
#  village_id                        :integer(4)      
#

module Community
  class User < Base

    has_many :user_session_logs, :class_name => "Community::UserSessionLog"
    belongs_to :simbio_language, :class_name => "Community::Language"
    belongs_to :selected_language, :class_name => "Community::Language"

    # Gives the equivalent learner object
    def user
      Learner.find_by_guid(guid)
    end

    def name
      "#{first_name} #{last_name}"
    end

    def address_info
      "#{state_province}, #{city}"
    end

    def country
      if rs_country = RosettaStone::Country.find_by_iso_code(country_iso)
        rs_country.country_code
      end
    end

    def age
      birth_date ? ((Time.now - birth_date.to_time) / 1.year).to_i : nil
    end

    def get_birth_date
      calculated_age = age
      (calculated_age && calculated_age > 13 ) ? (birth_date.strftime("%m-%d-%Y")) : nil
    end

    def avatar(type = :large)
      file_name = self.avatar_file.blank? ? "profile_photo.gif" : File.join("avatars", type.to_s, self.avatar_file)
      File.join("http://totale.rosettastone.com", "images", file_name)
    end

    def self.find_by_license_identifier(license_identifier)
      find_by_email(license_identifier)
    end

    def simbio_language_identifier
      simbio_language.identifier if simbio_language
    end

    def selected_language_identifier
      selected_language.identifier if selected_language
    end
    
    def license_identifier
      email
    end

  end
end
