# == Schema Information
#
# Table name: product_language_logs
#
#  id                  :integer(4)      not null, primary key
#  support_user_id     :integer(4)      
#  license_guid        :string(255)     
#  product_rights_guid :string(255)     
#  previous_language   :string(255)     
#  changed_language    :string(255)     
#  reason              :text(65535)     
#  created_at          :datetime        
#  updated_at          :datetime        
#

class ProductLanguageLog < ActiveRecord::Base
  validate do |pll|
    pll.errors.add(:base, "New language can't be blank") if pll.changed_language.blank?
    pll.errors.add(:base, "Reason can't be blank") if pll.reason.blank? || pll.reason == "Please enter reason for language change"
  end
end
