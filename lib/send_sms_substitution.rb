class SendSmsSubstitution < Struct.new(:lang_id, :num , :session_type)
	
  def perform
    languages = coach_list = []
    
    if (session_type =='appointment' && lang_id.kind_of?(Array)) # is appointment:
      languages = Language.find_all_by_id(lang_id)
      languages.each do |language|
       coach_list << language.coaches
      end
      coach_list = coach_list.flatten.uniq{|coach| coach.id}
    elsif (session_type=='session') # if session
      coach_list = Language[lang_id].coaches
    end

    language_name = (session_type=='appointment') ? languages.last.display_name_without_type : Language[lang_id].display_name 
    session_type_string = (session_type=='appointment') ? 'appointment(s)' : 'session(s)'
    text = "#{language_name} has #{num} #{session_type_string} with sub needed right now. Please check the substitutions page in the Customer Success Portal."
    text = text[0..156]+'...' if text.size > 160

    coach_list.each do |coach|
      coach.send_sms(text) if coach.get_preference.substitution_alerts_sms == 1
    end

  end

end