# == Schema Information
#
# Table name: villages
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)     not null
#  description       :text(65535)     
#  created_at        :datetime        
#  updated_at        :datetime        
#  public            :boolean(1)      not null
#  parent_village_id :integer(4)      
#  active            :boolean(1)      default(TRUE), not null
#

module Community
  class Village < Base
    def self.display_name(id)
      village = self.find_by_id(id)
      village.name if village
    end
  end
end
