class AddDefaultValuesToAppointmentTypes < ActiveRecord::Migration
  def self.up
  	AppointmentType.create :title => "E.ON. Evaluation" 
  	AppointmentType.create :title => "Konica Evaluation"
  end

  def self.down
  	AppointmentType.destroy_all
  end
end
