class AddDelayedJobFailureMailRecipientsToGlobalSettings < ActiveRecord::Migration
  def self.up
  	execute("insert into global_settings (attribute_name,attribute_value,description)values('delayed_job_failure_email_recipients', 'rs.success.all@rosttastone.com, micklan@rosettastone.com, mgadkari@rosettastone.com', 'People to whom the delayed job not picked up alert will be sent.');")
  end

  def self.down
  	execute("DELETE FROM global_settings WHERE attribute_name = 'delayed_job_failure_email_recipients';")
  end
end
