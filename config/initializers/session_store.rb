if Rails.env.production?
	Rails.application.config.session_store :active_record_store, :key => 'coachportal_session', :domain=>:all
end