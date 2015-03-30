class AddIndexesForMasterScheduler < ActiveRecord::Migration

  def self.up
    add_index :coach_recurring_schedules, [:language_id, :recurring_end_date], :name => "idx_c_rec_sched_lang_end_date"
    add_index :coach_availability_templates, [:deleted, :status, :language_start_time], :name => "idx_cat_del_stat_lng_st_time"
  end

  def self.down
    remove_index :coach_availability_templates, :name => "idx_cat_del_stat_lng_st_time"
    remove_index :coach_recurring_schedules, :name => "idx_c_rec_sched_lang_end_date"
  end

end

