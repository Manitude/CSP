module Extranet::LearnersHelper

  def sort_by_language_name(array_with_language_codes)
    array_with_language_names = []
    [array_with_language_codes].flatten.each do |lang|
      language_hash = {"language_name" => name_from_code(lang["language_code"]), "time_spent" => lang["time_spent"] }
      array_with_language_names << language_hash
    end
    array_with_language_names.sort_by {|lang| lang["language_name"]}
  end

  # Returns -- if none of the valuesare there
  # Returns the value that exists if only one of them exists
  # Returns both the values separated by "/" if both exist
  def format_tech_feedack_value(str_val ,int_val)
    str_val && int_val ? str_val.to_s + " / " + int_val.to_s : str_val ? str_val : int_val ? int_val : '--'
  end

  def get_session_rating(val)
    r = ''
    if !val.class.eql? String and !val.ratings.class.eql? String
      val.ratings.rating.detect{|x| r = x.int_value if x.label == "tech_rating"}  if val.ratings.rating.collect(&:label).include? "tech_rating"
      r = val.session_rating  if r.blank? && val.attributes.include?('session_rating')
    else
      r = 'N/A'
    end
    r
  end


  def feedback_hash_formation(feedback_for_session)
    feedback_hash = {}
    feedback_for_session.each do |fb|
      label_key = fb.label.match("follow") ? "followup" : fb.label
      feedback_hash[label_key] = {}
      feedback_hash[label_key] = fb
    end
    feedback_hash
  end

  def coach_found_in_csp(coach_id)
    coach = Coach[coach_id]
    return true if coach
    false
  end

  def options_for_languages_with_identifiers(selected = nil)
    options = [['All', 'all'],['Advanced English','ADE']]
    ProductLanguages.reflex_language_codes.each{|lang| options << [lang,lang]}
    options += TotaleLanguage.options_with_identifiers
    options = options_for_select(options, selected)
end

  def options_for_villages_learners(selected = nil)
    options = [['All', 'all'],['No Village', '-1']]
    villages = Community::Village.select("id,name").order("name")
    villages = filter_valid_villages(villages) # filters to only display the valid villages 
    options += villages.map {|l| [l.name, l.id.to_s] }
    options = options_for_select(options, selected)
  end

  def options_for_chat_type(selected = nil)
options = [['All', ''],['Private Conversation','JabberConversation'],['Public Conversation','PublicConversation'],['ChatLog Conversation','ChatLogConversation'],['Studio Conversation','StudioConversation']]
options = options_for_select(options, selected)
  end

end

