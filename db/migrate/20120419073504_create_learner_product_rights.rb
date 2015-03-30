class CreateLearnerProductRights < ActiveRecord::Migration
  def self.up
    create_table :learner_product_rights do |t|
      t.integer :learner_id
      t.string  :language_identifier
      t.string  :activation_id
      t.string  :product_guid, :unique => true
    end
  end

  def self.down
    drop_table :learner_product_rights
  end
end
