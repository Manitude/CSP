class AddSubstitutionPolicyEmailToPreferenceSettings < ActiveRecord::Migration
  def self.up
  	add_column :preference_settings, :substitution_policy_email, :integer
  	add_column :preference_settings, :substitution_policy_email_type, :string
  	add_column :preference_settings, :substitution_policy_email_sending_schedule, :string
  end

  def self.down
  	remove_column :preference_settings, :substitution_policy_email
  	remove_column :preference_settings, :substitution_policy_email_type
  	remove_column :preference_settings, :substitution_policy_email_sending_schedule
  end
end
