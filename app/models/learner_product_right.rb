class LearnerProductRight < ActiveRecord::Base
  belongs_to :learner
  def get_learner_guid
  	self.learner.guid
  end	
end
