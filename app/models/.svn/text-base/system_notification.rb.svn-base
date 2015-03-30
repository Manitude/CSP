# == Schema Information
#
# Table name: system_notifications
#
#  id              :integer(4)      not null, primary key
#  notification_id :integer(4)
#  recipient_id    :integer(4)
#  recipient_type  :string(255)
#  target_id       :integer(4)
#  status          :integer(1)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  raw_message     :string(255)
#

class SystemNotification < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger
  # include AuthenticatedSystem
  include ApplicationHelper
  belongs_to :notification
  belongs_to :recipient, :polymorphic => true

  delegate :target_type, :to => :notification, :allow_nil => true

  scope :unread, :conditions => { :status => 0 }

  def mark_as_read
    self.update_attribute(:status, 1)
  end

  def read?
    self.status == 1
  end

  # frame the message dynamically based on the related data models
  def message(email = false)
    if @msg.blank?
      @msg = ""
      if raw_message
        @msg = raw_message # If raw_message exists, just return it
      else
        unless target_object.is_a?(UnavailableDespiteTemplate) && [3].include?(target_object.approval_status)
          unless ((Ambient.current_user && Ambient.current_user.is_manager?) && target_object.is_a?(UnavailableDespiteTemplate) && (target_object.approval_status == 2))
            begin
              notif, target_obj  = self.notification, self.target_object
              @msg, index_offset = notif.message.dup, 0
              notif.message_dynamics.each do |msg_dynm|
                cur_offset  = msg_dynm.msg_index + index_offset
                dyn_msg_str = msg_dynm.get_msg_str(target_obj, email)
                @msg.insert(cur_offset, dyn_msg_str)
                # msg_index has to vary based on the length of the dynamic string
                index_offset += dyn_msg_str.length
              end
              @msg += "<i>  Reason: </i>#{target_object.comments} " if require_cta_links?
            rescue Exception => e
              @msg = ""
            end
          end
        end
      end
    end
    @msg.html_safe
  end

  # kind of polymorphic association
  def target_object
    @tar ||= (self.target_type ? (self.target_type.constantize.find_by_id(self.target_id) || self) : self)
  end

  def coach_id
    target_object.coach_id unless  target_object.is_a?(SystemNotification)
  end

  def require_cta_links?
    recipient.is_manager? && target_object.is_a?(UnavailableDespiteTemplate) && target_object.unavailability_type == 0 && target_object.approval_status == 0
  end

  def cta_links
    require_cta_links? ? ((target_object.end_date.utc > Time.now.utc) ? "<a href='javascript:void(0);' class='approve_timeoff'>Approve</a> | <a href='javascript:void(0);' class='approve_timeoff'>Deny</a>" : "Approve | Deny").html_safe : ""
  end

  def creation_time
    TimeUtils.format_time(created_at, '%m.%d.%Y %I:%M%p')
  end

  def rel_date
    date    = created_at.strftime('%B %e, %Y')
    utc_now = Time.now.utc
    return 'Today' if date == utc_now.strftime('%B %e, %Y')
    return 'Yesterday' if date == (utc_now - 1.day).strftime('%B %e, %Y')
    return date
  end

end
