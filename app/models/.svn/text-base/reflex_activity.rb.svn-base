class ReflexActivity < ActiveRecord::Base
	
	validates_uniqueness_of :timestamp, :scope =>[:coach_id, :event]
	
	def self.for_coaches(coaches, start_time, end_time)
		ReflexActivity.all(:conditions => ['coach_id in(?) and timestamp >= ? and timestamp <= ?', coaches, start_time, end_time], :order => 'timestamp');
	end
	
	def self.last_login_attempts(coach_id, size = 5)
		timestamp = TimeUtils.current_slot + 30.minutes
		result = []
		while result.size < size
			init_event = ReflexActivity.where('coach_id = ? and event = "coach_initialized" and timestamp < ? ',coach_id,timestamp).order('timestamp desc').first
			break if init_event.blank?
			following_event = init_event.next_event
			timestamp = init_event.timestamp
			next if (following_event && following_event.event == "coach_resumed")
			result << init_event.timestamp
		end	
		result
	end	
	
	def next_event
		ReflexActivity.where('coach_id = ? and timestamp >= ? and id > ?',coach_id,timestamp,id).order('timestamp desc').last
	end	

end
