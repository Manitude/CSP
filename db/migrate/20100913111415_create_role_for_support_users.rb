class CreateRoleForSupportUsers < ActiveRecord::Migration
  def self.up
    Role.create(:name => 'SupportUser');
    Role.create(:name => 'SupportLead');
  end

  def self.down
    execute %Q[delete from roles where name in ('SupportUser','SupportLead')]
  end
end
