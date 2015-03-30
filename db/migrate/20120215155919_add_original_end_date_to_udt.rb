class AddOriginalEndDateToUdt < ActiveRecord::Migration
  def self.up
    add_column :unavailable_despite_templates, :original_end_date, :datetime
  end

  def self.down
    remove_column :unavailable_despite_templates, :original_end_date
  end
end
