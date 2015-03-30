class Alert < ActiveRecord::Base

	def self.display_active_topic()
		where("active = 1").last
	end

	def activate!
		update_attribute(:active , 1)
	end

	def deactivate!
		update_attribute(:active , 0)
	end

end
