class StoreSubstitutionIds < ActiveRecord::Migration
  def self.up
    create_table :shown_substitutions , :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer :coach_id
      t.timestamps
    end
  end

  def self.down
    drop_table :shown_substitutions
  end
end
