class CreateUncapLearnerLogs < ActiveRecord::Migration
  def self.up
    create_table :uncap_learner_logs do |t|
      t.integer :support_user_id
      t.string :case_number, :null => false
      t.string :license_guid
      t.string :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :uncap_learner_logs
  end
end
