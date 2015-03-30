class TMMPhoneLanguage < Language

	def display_name
		return "RSA NED - Phone"  if (identifier == 'TMM-NED-P')
		return "RSA ENG - Phone"  if (identifier == 'TMM-ENG-P')
		return "RSA FRA - Phone"  if (identifier == 'TMM-FRA-P')
		return "RSA DEU - Phone"  if (identifier == 'TMM-DEU-P')
		return "RSA ITA - Phone"  if (identifier == 'TMM-ITA-P')
		return "RSA ESP - Phone"  if (identifier == 'TMM-ESP-P')
	end

	def display_short_name
		return "Dutch"  if (identifier == 'TMM-NED-P')
		return "English"  if (identifier == 'TMM-ENG-P')
		return "French"  if (identifier == 'TMM-FRA-P')
		return "German"  if (identifier == 'TMM-DEU-P')
		return "Italian"  if (identifier == 'TMM-ITA-P')
		return "Spanish"  if (identifier == 'TMM-ESP-P')
	end

	def display_name_without_type
		display_name.split(' -').first
	end

	def filter_name
		"RSA Phone Lessons"
	end

	#return 1 (PhoneNumber) for RSA phone mode of contact
	def supersaas_session_type
		1
	end
end