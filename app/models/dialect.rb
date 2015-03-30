class Dialect < ActiveRecord::Base
	belongs_to :language, :class_name => "Language", :foreign_key => 'language_id'
	has_many :qualifications, :foreign_key => 'dialect_id'
	class << self
		def options(lang_id)
				where("language_id = ?", lang_id).map {|d| [d.name.to_s, d.id] }
  	end
  end
end
