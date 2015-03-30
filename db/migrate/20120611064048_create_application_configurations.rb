class CreateApplicationConfigurations < ActiveRecord::Migration
  def self.up
    create_table :application_configurations do |t|
      t.string :setting_type
      t.string :value
      t.string :data_type
      t.string :display_name
      t.timestamps
    end

    ApplicationConfiguration.create({:setting_type => 'ok_to_send_sms', :display_name=> 'Send SMS', :value => 'Enable', :data_type => 'boolean'})
    ApplicationConfiguration.create({:setting_type => 'enable_clickatell', :display_name=> 'Clickatell', :value => 'Enable', :data_type => 'boolean'})
    ApplicationConfiguration.create({:setting_type => 'enable_celltrust', :display_name=> 'Celltrust', :value => 'Enable', :data_type => 'boolean'})
    ApplicationConfiguration.create({:setting_type => 'total_dashboard_row_count', :display_name=> 'Row Count In Dahsboard', :value => '100', :data_type => 'integer'})
  end

  def self.down
    drop_table :application_configurations
  end
end
