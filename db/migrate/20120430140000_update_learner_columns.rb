class UpdateLearnerColumns < ActiveRecord::Migration

  def self.up
    remove_column   :learners, :mobile_number_at_activation, :preferred_name, :state_province, :city, :username
  end
  
  def self.down
    add_column        :learners, :mobile_number_at_activation, :string
    add_column        :learners, :preferred_name, :string
    add_column        :learners, :state_province, :string
    add_column        :learners, :city, :string
    add_column        :learners, :username, :string
  end
end
