class AddLearnerIdToRightsExtensionLog < ActiveRecord::Migration
  def self.up
    add_column :rights_extension_logs, :learner_id, :int
  end

  def self.down
    remove_column :rights_extension_logs, :learner_id
  end
end
