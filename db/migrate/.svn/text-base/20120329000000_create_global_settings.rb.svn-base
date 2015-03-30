class CreateGlobalSettings < ActiveRecord::Migration
  def self.up
    create_table :global_settings do |t|
      t.string  :attribute_name
      t.string  :attribute_value
      t.string  :description
    end

    GlobalSetting.create(:attribute_name => 'minutes_before_session_for_triggering_sms_alert', :attribute_value => '5',
      :description => 'Minutes before sessions are scheduled to start, check and see if coaches are present. For each coach not present, send an SMS to all CMs and Coach Supervisors')
    GlobalSetting.create(:attribute_name => 'average_learner_wait_time_threshold', :attribute_value => '2',
      :description => 'Threshold for average learner wait time in minutes. When the wait time crosses the limit, alert CMs by sending SMS')
    GlobalSetting.create(:attribute_name => 'learner_coach_ratio_threshold', :attribute_value => '3',
      :description => 'Threshold for value of Learners in Skills/Rehearsal divided by Total Coaches in Player. If Learners:Coaches exceeds this ratio or there are no coaches in the player, fire the alert')
    GlobalSetting.create(:attribute_name => 'minutes_before_not_to_send_additional_sms', :attribute_value => '30',
      :description => 'Duration of time in minutes not to send an additional SMS after the first SMS is sent')

  end

  def self.down
    drop_table :global_settings
  end
end
