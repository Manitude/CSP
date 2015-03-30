# == Schema Information
#
# Table name: notification_message_dynamics
#
#  id              :integer(4)      not null, primary key
#  notification_id :integer(4)      
#  msg_index       :integer(4)      
#  name            :string(255)     
#  rel_obj_type    :string(255)     
#  rel_obj_attr    :string(255)     
#
class NotificationMessageDynamic < ActiveRecord::Base
  audit_logged
  belongs_to :notification

  def notification_recepient_name
    self.notification.recipients.first.name
  end

  DATETIME_COLS = ['substitution_date', 'start_date', 'end_date']

  # generate the message string based on a target object
  def get_msg_str(target_obj, email = false)
    msg_obj = target_obj.send(self.rel_obj_type || "myself")
    msg_str = msg_obj.send(self.rel_obj_attr)
    if msg_str.respond_to?('strftime')
      format = DATETIME_COLS.include?(self.rel_obj_attr)? "%B %d, %Y %l:%M %p" : "%m/%d/%Y"
      msg_str = TimeUtils.format_time(msg_str, format)
    end
    msg_str = msg_str.gsub("KLE", "Advanced English") if self.rel_obj_type == "language"
    begin
      if self.name == "Coach Name"
        if notification_recepient_name == "Coach"
          msg_str = "<b>"+msg_str+"</b>"
        else
          msg_str = "<a href = '#{email ? "http://coachportal.rosettastone.com" : ""}/view-coach-profiles?coach_id=#{msg_obj.id.to_s}'>"+msg_str+"</a>"
        end
      elsif self.name == "Template Name"
        msg_str = "<a href = '#{email ? "http://coachportal.rosettastone.com" : ""}/availability/#{msg_obj.coach.id.to_s}/#{target_obj.id}'>"+msg_str+"</a>"
      else
        if notification_recepient_name == "Coach"
          msg_str = "<b>"+msg_str+"</b>"
        end
      end
    rescue Exception => e
      
    end
    msg_str += " "
  end

end
