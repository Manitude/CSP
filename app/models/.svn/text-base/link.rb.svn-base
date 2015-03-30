# == Schema Information
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     
#  url        :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

# == Schema Information
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Link < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  validates_presence_of :name, :url
  validates_format_of  :name, :with => /^[a-z0-9A-Z_ (\&)-?\/,'%$"@#!~`@^{}\[\]*&]*?$/
  validates_format_of :url, :with =>/^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

end
