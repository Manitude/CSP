class TMMLiveLanguage < Language
	
	def display_name
		return "RSA NED - Tutoring" if (identifier == 'TMM-NED-L')
		return "RSA ENG - Tutoring" if (identifier == 'TMM-ENG-L')
		return "RSA FRA - Tutoring" if (identifier == 'TMM-FRA-L')
		return "RSA DEU - Tutoring" if (identifier == 'TMM-DEU-L')
		return "RSA ITA - Tutoring" if (identifier == 'TMM-ITA-L')
		return "RSA ESP - Tutoring" if (identifier == 'TMM-ESP-L')
	end

	def display_short_name
		return "Dutch"  if (identifier == 'TMM-NED-L')
		return "English"  if (identifier == 'TMM-ENG-L')
		return "French"  if (identifier == 'TMM-FRA-L')
		return "German"  if (identifier == 'TMM-DEU-L')
		return "Italian"  if (identifier == 'TMM-ITA-L')
		return "Spanish"  if (identifier == 'TMM-ESP-L')
	end

	def display_name_without_type
		display_name.split(' -').first
	end

	def filter_name
		"RSA Live Tutoring"
	end
end