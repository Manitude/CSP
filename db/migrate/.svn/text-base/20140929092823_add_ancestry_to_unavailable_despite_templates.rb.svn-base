class AddAncestryToUnavailableDespiteTemplates < ActiveRecord::Migration
  def self.up
    add_column :unavailable_despite_templates, :ancestry, :string
    add_index :unavailable_despite_templates, :ancestry
  end

  def self.down
    remove_index :unavailable_despite_templates, :ancestry
    remove_column :unavailable_despite_templates, :ancestry
  end
end
