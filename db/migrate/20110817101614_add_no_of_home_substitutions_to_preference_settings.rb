class AddNoOfHomeSubstitutionsToPreferenceSettings < ActiveRecord::Migration
  def self.up
    add_column :preference_settings, :no_of_home_substitutions, :integer
  end

  def self.down
    remove_column :preference_settings, :no_of_home_substitutions
  end
end
