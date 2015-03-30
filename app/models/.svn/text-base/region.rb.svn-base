# == Schema Information
#
# Table name: regions
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

# == Schema Information
#
# Table name: regions
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Region < ActiveRecord::Base
  audit_logged
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_format_of  :name, :with => /^[a-zA-Z\-\ ]*?$/, :message => " should contain only alphabets and hyphen"
  has_many :announcements
  has_many :events
  has_many :coaches, :order => 'trim(full_name)'

  class << self
    def all_sorted_by_name
      Region.all.sort_by(&:name)
    end

    def options
      all_sorted_by_name.map {|l| [l.name.to_s, l.id] }
    end
  end
end
