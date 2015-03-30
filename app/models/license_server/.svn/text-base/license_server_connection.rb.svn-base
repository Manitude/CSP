module LicenseServer
	class LicenseServerConnection < ActiveRecord::Base
    self.abstract_class = true
		establish_connection "license_server_#{Rails.env}"
	end
end
