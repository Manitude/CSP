class AddIndexToLearnersSearchFields < ActiveRecord::Migration
  def self.up
    add_index :learners, :first_name, :name => "idx_learners_first_name"
    add_index :learners, :last_name, :name => "idx_learners_last_name"
    add_index :learners, :email, :name => "idx_learners_email"
    add_index :learners, :mobile_number, :name => "idx_learners_mobile_number"
    add_index :learners, :osub_active, :name => "idx_learners_osub_active"
    add_index :learners, :totale_active, :name => "idx_learners_totale_active"
    add_index :learners, :enterprise_license_active, :name => "idx_learners_enterprise_license_active"
    add_index :learners, :rworld, :name => "idx_learners_rworld"
  end

  def self.down
    remove_index :learners, :name => "idx_learners_user_source"
    remove_index :learners, :name => "idx_learners_enterprise_license_active"
    remove_index :learners, :name => "idx_learners_totale_active"
    remove_index :learners, :name => "idx_learners_osub_active"
    remove_index :learners, :name => "idx_learners_mobile_number"
    remove_index :learners, :name => "idx_learners_email"
    remove_index :learners, :name => "idx_learners_last_name"
    remove_index :learners, :name => "idx_learners_first_name"
  end
end
