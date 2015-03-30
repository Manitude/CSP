class TMMMichelinLanguage < Language
	
	def display_name
		return "Michelin French" if (identifier == 'TMM-MCH-L')
	end

	def display_short_name
		return "French"  if (identifier == 'TMM-MCH-L')
	end

	def display_name_without_type
		'RSA FRA'
	end

	def filter_name
		"Michelin"
	end

	#return 2 (ScreenSharingEndPoint) for RSA Michelin mode of contact
	def supersaas_session_type
		2
	end
end