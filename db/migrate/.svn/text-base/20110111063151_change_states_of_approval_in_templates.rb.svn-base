class ChangeStatesOfApprovalInTemplates < ActiveRecord::Migration
  def self.up
    #global constants changed for STATES_OF_APPROVAL
    # 0-Draft 1-Approved
    CoachAvailabilityTemplate.find_all_by_approval_status([STATES_OF_APPROVAL.index('Draft'),STATES_OF_APPROVAL.index('Resubmitted for approval')]).each do |availability_template|
      availability_template.update_attribute(:approval_status,STATES_OF_APPROVAL.index('Waiting for approval'))#approval status moved to 0 . STATES_OF_APPROVAL=0-Draft(Changed)
      end
     CoachAvailabilityTemplate.find_all_by_approval_status(STATES_OF_APPROVAL.index('Approved with changes')).each do |availability_template|
      availability_template.update_attribute(:approval_status,STATES_OF_APPROVAL.index('Approved'))#approval status moved to 1 . STATES_OF_APPROVAL=1-Approved
      end
  end

  def self.down
    #Since there are changes in the Global constants and no means to separate the approval_status no down method available.
  end
end
