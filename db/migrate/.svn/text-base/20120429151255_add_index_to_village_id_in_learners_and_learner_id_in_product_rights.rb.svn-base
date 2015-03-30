class AddIndexToVillageIdInLearnersAndLearnerIdInProductRights < ActiveRecord::Migration
  def self.up
  	add_index :learners, :village_id, :name => 'idx_learners_village_id'
  	add_index :learner_product_rights, :learner_id, :name => 'idx_product_rights_learner_id'
    add_index :learner_product_rights, :language_identifier, :name => 'idx_product_rights_language'
    add_index :learner_product_rights, :activation_id, :name => 'idx_product_rights_activation_id'
    add_index :learner_product_rights, :product_guid, :name => 'idx_product_rights_product_guid'
  end

  def self.down
  	remove_index :learner_product_rights, :name => 'idx_product_rights_learner_id'
  	remove_index :learners, :name => 'idx_learners_village_id'
    remove_index :learner_product_rights, :name => 'idx_product_rights_language'
    remove_index :learner_product_rights, :name => 'idx_product_rights_activation_id'
    remove_index :learner_product_rights, :name => 'idx_product_rights_product_guid'
  end
end
