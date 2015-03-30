# == Schema Information
#
# Table name: user_villages
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  village_id :integer(4)      not null
#  created_at :datetime        
#  updated_at :datetime        
#

module Community

  class UserVillages < Base
    belongs_to :user, :class_name => "User"
    belongs_to :village, :class_name => "Village"
  end

end

