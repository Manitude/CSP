# == Schema Information
#
# Table name: user_session_logs
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)      not null
#  language_id        :integer(4)      not null
#  paid               :boolean(1)      not null
#  session_start_time :datetime        not null
#  last_activity_time :datetime        not null
#  ip_address         :string(255)     not null
#  logout_type        :string(0)       not null
#  user_agent         :string(255)     
#  accept_language    :string(255)     default(""), not null
#

module Community

  class UserSessionLog < Base
    belongs_to :user, :class_name => "Community::User"
  end

end
