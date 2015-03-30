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


class SupportHarrisonburgUser < Account
  def is_tier1_support_harrisonburg_user?
    true
  end
end
