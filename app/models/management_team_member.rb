class ManagementTeamMember < ActiveRecord::Base
	audit_logged :audit_logger_class => CustomAuditLogger 

	validates_presence_of :name
	validates_presence_of :email
	validates(:bio, :length => {:maximum => 1000})
	has_attached_file :image, :storage => :database, :url =>'/management/photos/:id/:filename'
	validate :check_image_content_type
	validate :check_image_file_size

	default_scope select((column_names - ['image_file']).map { |column_name| "`#{table_name}`.`#{column_name}`"})

	def check_image_content_type
		if(self.image_content_type.present? && !['image/jpeg', 'image/gif','image/png','image/tiff'].include?(self.image_content_type))
			errors.add_to_base("Profile image must be in either .jpeg, .png, .gif or .tiff format.")
		end
	end 

	def check_image_file_size
		if (self.image_file_size.present? && !(self.image_file_size < 100.kilobytes))
			errors.add_to_base("Profile image must not exceed 100Kb.")
		end
	end 
end