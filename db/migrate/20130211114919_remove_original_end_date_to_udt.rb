class RemoveOriginalEndDateToUdt < ActiveRecord::Migration
  def self.up
    remove_column :unavailable_despite_templates, :original_end_date
  end

  def self.down
    add_column :unavailable_despite_templates, :original_end_date, :datetime
  end
end
