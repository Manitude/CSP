class AriaLanguage < Language
	
	def display_name
		return "AEB US" if (identifier == 'AUS') 
		return "AEB UK" if (identifier == 'AUK')
	end

	def filter_name
		"AEB"
	end
end