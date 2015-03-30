# == Schema Information
#
# Table name: scheduler_metadata
#
#  id                 :integer(4)      not null, primary key
#  locked             :boolean(1)      
#  lang_identifier    :string(255)     
#  total_sessions     :integer(4)      default(0)
#  completed_sessions :integer(4)      default(0)
#  start_of_week	  :datetime
#  created_at         :datetime        
#  updated_at         :datetime        
#

class SchedulerMetadata < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  set_table_name 'scheduler_metadata'
  
  def language
  	@lang ||=Language.find_by_identifier(lang_identifier)
  end

  def weeks_to_be_pushed
    unpushed_weeks = []
    till_the_week = TimeUtils.beginning_of_week_for_user(start_of_week)
    week_start = TimeUtils.beginning_of_week_for_user
    while week_start <= till_the_week
      unpushed_weeks << week_start.utc
      week_start += 1.week
    end
    unpushed_weeks
  end

  def update_sessions_count
    sessions_count = {:create_new => 0, :create_recurring => 0, :edit => 0, :cancel => 0}
    weeks_to_be_pushed.each do |start_of_week|
      end_of_week = TimeUtils.end_of_week(start_of_week)
      sessions_count[:create_new] += LocalSession.for_language_and_action(language.id, 'create', start_of_week, end_of_week).size
      sessions_count[:cancel] += LocalSession.for_language_and_action(language.id, 'cancel', start_of_week, end_of_week).size
      sessions_count[:edit] += LocalSession.for_language_and_action(language.id, 'edit_one', start_of_week,end_of_week).size
      sessions_count[:edit] += LocalSession.for_language_and_action(language.id, 'edit_all', start_of_week,end_of_week).size
      sessions_count[:create_recurring] += CoachRecurringSchedule.fetch_for(start_of_week, end_of_week, language.id).size
    end
    sessions_to_be_created = sessions_count[:create_new] + sessions_count[:create_recurring]
    update_attributes({"total_sessions" => (sessions_to_be_created + sessions_count[:cancel] + sessions_count[:edit]), "total_sessions_to_be_created" => sessions_to_be_created})
  end

  def update_completed_count(count)
    update_attribute(:completed_sessions, completed_sessions + count)
  end
  
end
