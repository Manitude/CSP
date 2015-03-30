class AddRowToGlobalSettings < ActiveRecord::Migration
  def self.up
  	execute("insert into global_settings (attribute_name,attribute_value,description)values('on_duty_text_message','Enter Text','Text Message to be displayed on Studio Team On Duty Pop Up');")
  end

  def self.down
    execute("DELETE FROM global_settings WHERE attribute_name = 'on_duty_text_message';")
  end
end
