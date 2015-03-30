class RemoveDateFromSubstitutions < ActiveRecord::Migration
  def self.up
    remove_column :substitutions, :substitution_date
  end

  def self.down
    add_column :substitutions, :substitution_date, :datetime
  end
end
