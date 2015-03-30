require File.dirname(__FILE__) + '/../utils/dashboard_utils'

module DashboardHelper
  
  def options_for_time_frame
    options_for_select(DashboardUtils.future_time_frames + DashboardUtils.past_time_frames, 'Live Now')
  end

  def options_for_session_language
    session_languages = Language.session_languages
    session_languages.shift
    options_for_select(session_languages, 'All') #reflex sunset
  end

  def options_for_support_language
    options_for_select(SupportLanguage.supported_languages, 'None')
  end
  
  def get_translations
    {
      :Assist => _("AssistA64282B8"),
      :Paused => _("Pause165BBDE9")
    }.to_json
  end

end
