class CreateLanguageSchedulingThresholds < ActiveRecord::Migration
  def self.up
    create_table :language_scheduling_thresholds do |t|
      t.integer :language_id,:null => false
      t.integer :max_assignment, :default => 50,:null => false
      t.integer :max_grab, :default => 30,:null => false
      t.integer :hours_prior_to_sesssion_override, :default => 12,:null => false
      t.timestamps
    end

    languages = Language.find(:all).collect(&:id)
    languages.each do |lang_id|
        LanguageSchedulingThreshold.create({:language_id=>lang_id})
    end
  end

  def self.down
    drop_table :language_scheduling_thresholds
  end


end
