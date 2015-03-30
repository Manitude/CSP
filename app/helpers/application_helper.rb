
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def app_title
    "Customer Success Portal"
  end

  def page_title
    @page_title ||= "#{controller.action_name.humanize.titleize}"
  end

  def get_text(text)
    text.blank? ? _("NA968230B3") : text.to_s.html_safe
  end

  def get_language_text(text)
    text.blank? ? _("NA968230B3") : Language[text].nil?? _("NA968230B3") : Language[text].display_name
  end

  def link_to_super_user
    s_user = session[:super_user]
    return '' unless s_user
    output = link_to("Sign in as #{s_user.user_name}", sign_in_as_super_user_path)
  end

  def session_types_list
    list = [["Session","session"],["Appointment","appointment"]]
    list.shift if coach_logged_in?
    list
  end

  def support_chat_link
    addendum = "language=en-US"
    addendum += "&email=#{CGI.escape(current_user.rs_email)}"
    addendum += "&firstName=#{CGI.escape(current_user_name)}"
    addendum += "&lastName="

    "http://rosettastone#{RosettaStone::ProductionDetection.could_be_on_production? ? "" : ".fullsb.cs9"}.force.com/liveeventprechat?#{addendum}"
  end

  def get_rel_time(time)
    return 'NIL' unless time
    time = time.to_time.in_time_zone('UTC')
    cur_time = Time.now.in_time_zone('UTC')
    rel_time = (cur_time - time).to_i
    return "#{rel_time} seconds ago" if rel_time < 60
    rel_time /= 60
    return "#{rel_time} minutes ago" if rel_time < 60
    rel_time /= 60
    return "#{rel_time} hours ago" if rel_time < 24
    return time.to_time.in_time_zone(current_user.time_zone).strftime("%I:%M, %d-%b-%Y")
  end

  def get_est_time_format(time)
    default_time = _("NA968230B3")
    begin
      time_obj = time.to_time.in_time_zone('Eastern Time (US & Canada)')
      default_time = time_obj.strftime("%m/%d/%y %I:%M:%S %p") unless time_obj.blank?
    rescue Exception => ex
    end
    default_time
  end

  def set_title(time)
    default_title = ""
    begin
      time_obj = time.to_time.utc
      default_title = "#{time_obj.strftime("%m/%d/%y %I:%M:%S %p UTC")} (#{time_ago_in_words(time_obj)} #{(Time.now.utc > time_obj) ? 'ago' : 'from now'})" unless time_obj.blank?
    rescue Exception => ex
    end
    default_title
  end


  def set_image_source(type)
    return "/images/success.png" if type
    "/images/failure.png"
  end

  def masked_string(value, trailing_unmasked_character_count = 4, leading_unmasked_character_count = 4)
    # HOLY CRAP value.mb_chars.last(n) DOES NOT WORK CORRECTLY with utf8 characters. use value.mb_chars[m...n] instead. good thing for tests!
    # UGH same with value.mb_chars.substr(n,m).  NOT COOL.
    value = value.to_s.mb_chars
    [
      h(value[0...leading_unmasked_character_count]),
      value[leading_unmasked_character_count...(-1 * trailing_unmasked_character_count)].to_s.mb_chars.gsub(/./, '&bull;'),
      h(value[(value.length - [0, [trailing_unmasked_character_count, value.length - leading_unmasked_character_count].min].max)...value.length]),
    ].join.html_safe
  end

  def masked_activation_id(activation_id)
    return "N/A" if activation_id.blank?
    return activation_id.to_s if activation_id.to_s.mb_chars.length < 14 # the smaller activation codes for ReFLEX should, for now, go through unmasked
    masked_string(activation_id, 2, 9)
  end

  def get_number(text)
    text.blank? ? "0" : text
  end

  def display_flash_content
    flash_content = [:error, :notice].map do |key|
      collection = flash[key].blank? ? [] : (flash[key].respond_to?(:map) ? flash[key] : [flash[key]])
      collection.map {|item| content_tag(:div, item, :class => key.to_s) }
    end
    raw flash_content
  end

  def link_to_launch(text, url, coach_session_id = 0)
    if url !~ /^javascript:/ # New link
      link_to_if url, text, "#", {:onclick => "#{url}"}
    else # old link
      #Do not remove. Ever. KLE always uses old style link hard-coded in coach_portal_controller
      link_to_if url, text, url
    end
  end

  def instance_name
    RosettaStone::InstanceDetection.instance_name
  end


  def get_generate_range
    range = get_time_range(params[:timeframe], params[:start_date], params[:end_date])
    render :text => "<b>Report Generated for:</b> #{TimeUtils.format_time(range[:from].to_time, "%B %d, %Y %I:%M %p")} <b>-</b> #{TimeUtils.format_time(range[:to].to_time, "%B %d, %Y %I:%M %p")}"
  end

  def get_time_range(timeframe, custom_from, custom_to)
    range = {:from => '', :to => ''}
    now = TimeUtils.time_in_user_zone
    today_start = now.beginning_of_day.utc
    tomorrow_start = now.beginning_of_day.tomorrow.utc
    case timeframe
    when 'Custom'
      range[:from] = TimeUtils.time_in_user_zone(custom_from).utc.to_s(:db)
      range[:to]   = TimeUtils.time_in_user_zone(custom_to).utc.to_s(:db)
    when 'Last month'
      range[:from] = (today_start - 1.month).to_s(:db)
      range[:to]   = (today_start - 1.minute).to_s(:db)
    when 'Last week'
      range[:from] = (today_start - 7.days).to_s(:db)
      range[:to]   = (today_start - 1.minute).to_s(:db)
    when 'Yesterday'
      range[:from] = (today_start - 1.day).to_s(:db)
      range[:to]   = (today_start - 1.minute).to_s(:db)
    when 'Today'
      range[:from] = (today_start).to_s(:db)
      range[:to]   = (tomorrow_start - 1.minute).to_s(:db)
    when 'Tomorrow'
      range[:from] = (tomorrow_start).to_s(:db)
      range[:to]   = (tomorrow_start + 1.day - 1.minute).to_s(:db)
    when 'Next Week'
      range[:from] = (tomorrow_start).to_s(:db)
      range[:to]   = (tomorrow_start + 7.days - 1.minute).to_s(:db)
    when 'Next Month'
      range[:from] = (tomorrow_start).to_s(:db)
      range[:to]   = (tomorrow_start + 1.month - 1.minute).to_s(:db)
    end
    range
  end

  def options_with_select(options = [], default_val = '')
    options.unshift(['-Select-', ''])
    options_for_select(options, default_val)
  end

  def options_for_seat(selected = nil, start_from = 1)
    start_from = start_from.to_i
    start_from = 2 if start_from == 1 && selected > 1
    start_from = 1 if start_from == 0
    options = (start_from..10).to_a
    options_for_select(options, selected)
  end

  def options_for_language(options = [])
    options.unshift(['All', -1 ])
    options
  end

  def options_for_level(selected = nil)
    options = (1..5).to_a.map{|l| [l,l]}
    options.unshift(['-Level-', "--" ])
    options_for_select(options,selected)
  end

  def options_for_unit(selected = nil)
    options = (1...21).to_a.map{|l| [l,l]}
    options.unshift(['-Unit-', "--" ])
    options_for_select(options,selected)
  end

  def options_for_time_selector(selected = nil)
    options = []
    base = Time.now.midnight
    24.times do
      options << base.strftime("%I:%M")
      base += 30.minutes
    end
    options_for_select(options,selected)
  end

  def options_for_lesson(selected = nil)
    options = [2,4].map{|l| [l,l]}
    options.unshift(['-Lesson-', "--" ])
    options_for_select(options,selected)
  end

  def options_for_all_languages(selected=nil)
    options = '<option value="all">All Languages</option>'
    all_lang = Language.all.sort_by(&:display_name)
    options << options_from_collection_for_select(all_lang, 'identifier', 'display_name', selected)
    options.html_safe
  end

  def options_for_language_type(selected_type)
    options = current_user.languages.collect(&:filter_name).uniq
    options_for_select(options,selected_type)
  end

  def options_for_languages(filter = false, selected = nil, lotus = true, show_aria_tmm = true, selected_type = nil )
    options = '<option value="">Select a Language</option>'
    options += '<option value="all">All Languages</option>' if filter
    all_lang = current_user.languages.sort_by(&:display_name)
    all_lang = all_lang.select {|l| l if FILTER_NAMES[selected_type].include?(l.type)} if selected_type
    all_lang.reject! { |lang| lang.is_lotus? } unless lotus
    all_lang.reject! { |lang| lang.is_aria? || lang.is_tmm? } unless show_aria_tmm
    options << options_from_collection_for_select(all_lang, 'identifier', 'display_name', selected)
    options.html_safe
  end

  def options_for_filter_languages(selected = nil, selected_type = nil )
    options = ''
    options = '<option value="">Select a Language</option>' if(selected_type!="Michelin")
    all_lang = current_user.languages.sort_by(&:display_name)
    all_lang = all_lang.select {|l| l if FILTER_NAMES[selected_type].include?(l.type)} if selected_type
    if selected_type.index('TMM') || selected_type.index('Michelin')
      options << options_from_collection_for_select(all_lang, 'identifier', 'display_short_name', selected)
    else
      options << options_from_collection_for_select(all_lang, 'identifier', 'display_name', selected)
    end
    options.html_safe
  end

    # Populate all languages / reject KLE for current time slot / reject AUS,AUK for session creation in bottom half hour / reject AUS,AUK in top half if bottom half has session
  def coach_languages(coach_id, selected = nil, include_select = false, include_all = true, totale = false, session_start_time = nil,aria = false, tmm_l = false, tmm_michelin = false, tmm_p = false, coach_scheduler_filter = false, include_reflex = false)
    coach = Coach.find_by_id(coach_id)
    languages = current_user.languages & coach.languages
    languages.reject!{|l| (l.identifier != selected) && l.is_totale? } if (totale && selected && Language[selected].is_totale?) || coach_logged_in? && !coach_scheduler_filter
    languages.reject!{|l| (l.identifier == "KLE")} if !include_reflex #reflex sunset
    if (session_start_time)
      languages.reject!{|l| (l.identifier == "KLE")} if(Time.now.utc > session_start_time || coach_logged_in?  && !coach_scheduler_filter) # to prevent KLE session creation for current time slot from coach scheduler or if coach logged in
      languages.reject!{|l| (l.identifier == "AUS" || l.identifier == "AUK")} if (aria || coach_logged_in?  && !coach_scheduler_filter) # to prevent Aria creation at half of an hour or prevent in top when there is session at bottom half hour or if coach logged in
      languages.reject!{|l| (l.is_tmm_live?)} if (tmm_l) && !coach.is_tmm? # to prevent TMM creation at half of an hour or prevent in top when there is session at bottom half hour
      languages.reject!{|l| (l.is_tmm_michelin?)} if (tmm_michelin) && !coach.is_tmm?
      languages.reject!{|l| (l.is_tmm_phone?)} if (tmm_p || Time.now.utc > session_start_time)
    end
    options = []
    languages.sort!{ |a,b| a.display_name <=> b.display_name }
    if languages.size > 1
      options << ['All Languages', 'all'] if include_all
      options << ['Select a language', 'all'] if include_select
    end
    options += languages.collect {|lang| [lang.display_name, lang.identifier] }
    options = options_for_select(options, selected)
  end

  def options_for_appointment_types(selected = nil)
    options = [['Select appointment type', 'all']]
    options += AppointmentType.active.sort_by(&:title).map{|a| [a.title,a.id] }
    options_for_select(options, selected)
  end

  def options_for_villages_for_scheduler(selected = nil, from_pop_up = true)
    options = Array.new
    options << '<option value="all">All Sessions</option>' if !from_pop_up
    options << '<option value=""'+ ((selected == '')? 'selected="selected"' : '') +'>No village</option>'

    villages = Community::Village.order("name")

    unless selected.nil?
      selected_village = []
      villages.each do |village|
          if (village.id == selected)
            selected_village = village
          end
      end
    end

    villages = filter_valid_villages(villages) # filters to only display the valid villages
    unless selected.nil?
      villages << selected_village
    end

    villages = villages.flatten.uniq.sort_by { |v| v.name.downcase }

    options << options_from_collection_for_select(villages, 'id', 'name', selected.to_i)
    options.join.html_safe
  end

  def options_for_villages(selected = nil, select_text = false, no_village_text = false)
    options = Array.new
    options << '<option value="">'+select_text+'</option>' if select_text
    options << '<option value="">'+no_village_text+'</option>' if no_village_text
    villages = Community::Village.order("name")
    villages = filter_valid_villages(villages) # filters to only display the valid villages

    options << options_from_collection_for_select(villages, 'id', 'name', selected && selected.to_i)
    options.join.html_safe
  end

  def options_for_lang_start_time_edit_schedule(start_time_array,selected = nil)
    options = Array.new
    options << ['All Classes starting :00',1] if start_time_array.include?(1)
    options << ['All Classes starting :15',2] if start_time_array.include?(2)
    options << ['All Classes starting :30',3] if start_time_array.include?(3)
    options << ['All Classes starting :45',4] if start_time_array.include?(4)
    options_for_select(options, selected)
  end

  def options_for_coaches(selected = nil, value_method = :id, text_method = :display_name)
    collection = @coaches || @coaches_for_language  || current_manager.coaches
    selected ||= @coach && @coach.id
    options = '<option value="">Select a Coach</option>'
    collection.sort!{|a,b| a.full_name.strip.downcase <=> b.full_name.strip.downcase}
    options << options_from_collection_for_select(collection, value_method, text_method, selected)
    options.html_safe
  end

  def options_for_coaches_for_scheduler(language)
    coaches = Coach.where(["active = ? and languages.identifier = ?", true, language]).includes(:languages).order("trim(full_name)")
    options = '<option value="">Coach Availability</option>'
    options << options_from_collection_for_select(coaches, :id, :display_name, "")
    options.html_safe
  end

  def options_for_coaches_in_ms(selected = nil, value_method = :id, text_method = :display_name)
    collection = @coaches || @coaches_for_language  || current_manager.coaches
    selected ||= @coach && @coach.id
    options = '<option value="">Coach Availability</option>'
    options << options_from_collection_for_select(collection, value_method, text_method, selected)
  end

  def options_for_aeb_topics(cefr_level, lang, selected = nil,initialOption = "Select")
    topics = [[initialOption,""]]
    topics.push([Topic.find_by_id(selected).title,selected]) if selected
    Topic.where("cefr_level = ? and language = ? and removed = 0 and selected = 1", cefr_level, lang.nil? ? nil : Language[lang].id).each do |t|
      topics.push([t.title, t.id])
    end
    options_for_select(topics.uniq, selected)
  end

  def options_for_lang(languages, selected = nil)
    collection =   languages.sort_by(&:display_name)
    options = '<option value="">Language</option>'
    options << options_from_collection_for_select(collection, :id, :display_name, selected)
    options.html_safe
    #options.sort
  end

  def options_for_lang_including_appointments(languages, appointment_languages, selected = nil)
    collection =   languages.sort_by(&:display_name)
    languages_array =collection.collect{|lang| [lang.display_name, lang.id]}
    languages_array += Language.group_appointment_languages(appointment_languages)
    languages_array = languages_array.sort_by{|l| l[0]}
    options = '<option value="">Language</option>'
    options << options_for_select(languages_array, selected)
    options.html_safe
    #options.sort
  end

  def options_for_lang_from_threshold_page(selected = nil,value_method = :id, text_method = :display_name)
    options = ""
    collection = @selection
    options = '<option value="--" selected="selected">Select a Language</option>'
    options << options_from_collection_for_select(collection,value_method, text_method,  selected)
  end

  def options_for_lang_for_mail(lang_array, selected = nil ,value_method = :identifier, text_method = :display_name)
    collection = lang_array
    options = '<option value="all" selected="selected" >All Languages</option>'
    options << options_from_collection_for_select(collection, value_method, text_method, selected)
    options.html_safe
  end

  def options_for_lang_for_sub_report(lang_array, selected = nil ,value_method = :id, text_method = :display_name)
    collection = lang_array
    appointment_languages = TMMLiveLanguage.all
    languages_array =collection.collect{|lang| [lang.display_name, lang.id]}
    languages_array += Language.group_appointment_languages(appointment_languages)
    languages_array=languages_array.sort_by{|l| l[0]}
    options = '<option value="--" selected="selected">Select a Language</option>'
    options << '<option value="">All Languages</option>'
    options << options_for_select(languages_array, selected)
    options.html_safe
  end

  def options_for_region(selected = nil, optional_text = true, value_method = :id, text_method = :name, region_or_hub_city = "Region")
    collection = Region.order("name")
    optional =  optional_text ? "(optional)" : ""
    options = "<option value=\"\" selected=\"selected\">Select a #{region_or_hub_city} #{optional}</option>"
    options << options_from_collection_for_select(collection, value_method, text_method, selected)
    options.html_safe
  end

  def options_for_duration_for_coach_report(selected = nil)
    duration_order = ["Select a Timeframe", "Last month", "Last week", "Yesterday", "Today", "Tomorrow", "Next Week", "Next Month", "Custom"]
    options = []
    duration_order.each_index do |i|
      options << duration_order[i]
    end
    options = options_for_select(options, selected)
  end

  def options_for_time_off_status(selected = nil)
    options = options_for_select(["Select Status (Optional)","Approved","Denied","Pending"], selected)
  end

  def options_for_aria(selected = nil,from = nil)
    options = []
    lang = Language.where("type = 'AriaLanguage'")
    if from == "report_page"
      options << '<option value="">All</option>'
    else
      options << '<option value="">-Language-</option>'
    end
    options << options_from_collection_for_select(lang, :id, :display_name, selected)
    options.join.html_safe
  end

  def options_for_duration_for_sub_report(selected = nil)
    options = options_for_select(["--Select--","All","Yesterday","Last week", "Last month", "Today", "Tomorrow", "Next Week", "Next Month", "Custom"], selected)
  end

  def options_for_duration_for_audit_logs(selected = nil)
    options = options_for_select(["All", "Today", "Yesterday", "Last week", "Last month", "Custom"], selected)
  end

  def options_for_duration_for_chat_history(selected = nil)
    options = options_for_select(["Select a Timeframe", "Today", "Yesterday", "Last week", "Last month", "Custom"], selected)
  end

  def options_for_grabbed_within(selected = nil)
    options = options_for_select(["One hour","2 hours","12 hours","24 hours", "36 hours", "48 hours", "72 hours" , "More than 3 days" , "Open","Show All"], selected)
  end

  def options_for_duration(selected = nil)
    options = options_for_select(["Today", "Tomorrow", "Upcoming Week", "Upcoming"], selected)
  end

  def options_for_coach(coaches, selected = nil, sub = false, dialect_lang = nil)
    collection = coaches.sort_by{|coach| coach.full_name.strip.downcase}
    options = [["Select a Coach",""]]
    options = [["Coach Requesting",""],["Extra Sessions","Extra Sessions"]] if sub
    if dialect_lang
     options.concat collection.map{|coach| [coach.full_name+" - #{coach.qualification_for_language(dialect_lang).dialect.name}", coach.id] }
    else
     options.concat collection.map{|coach| [coach.full_name, coach.id] }
    end
    options_for_select(options, selected)
  end

  def options_for_notification_range(selected)
    options_for_select(["Today", "Yesterday", "In the last 7 days", "In the last 30 days", "In the last 3 months", "In the last 6 months","Custom"], selected)
  end

  def options_for_coach_for_sub_report(coach_list , selected = nil , value_method = :id, text_method = :display_name, calling_method = true)
    collection = coach_list
    options =[]
    if calling_method
      options << '<option value="">All</option>'
      if selected == "Extra Sessions"
        options << '<option value="Extra Sessions" selected="selected">Extra Sessions</option>'
      else
        options << '<option value="Extra Sessions">Extra Sessions</option>'
      end
    else
      options << '<option value="">Select a Coach</option>'
    end
    options << options_from_collection_for_select(collection, value_method, text_method, selected)
    options.join.html_safe
  end

  def options_for_grabber_coach_for_sub_report(coach_list , selected = nil , value_method = :id, text_method = :display_name, calling_method = true)
    collection = coach_list
    options =[]
    options << '<option value="--">All</option>'
    if calling_method
      options << '<option value="">Any coach</option>'
    else
      options << '<option value="">Select a Coach</option>'
    end
    options << options_from_collection_for_select(collection, value_method, text_method, selected)
    options.join.html_safe
  end

  def options_for_managers(selected = nil, value_method = :id, text_method = :display_name)
    collection = @coach_managers
    selected = @coach_manager ? @coach_manager.id : current_manager.id
    options_from_collection_for_select(collection, value_method, text_method, selected)
  end

  def options_for_other_managers(selected = nil, value_method = :id, text_method = :display_name)
    collection = @other_managers
    options = '<option value="">-Select-</option>'
    options << options_from_collection_for_select(collection, value_method, text_method,selected)
    options.html_safe
  end

  def options_for_session_start_time(selected = '')
    options_for_select(LanguageConfiguration.options, selected)
  end

  def options_for_session_type(data)
    result = [["Select", "-1"]]
    result << ["Group", "0"] if data[:group_product_right] && data[:group_product_right] != "null"
    result << ["Solo", "1"]
    result
  end

  def reasonable_year_options(options = {})
    options.reverse_update(:start => 80, :end => 20)
    {
      :start_year => (Time.now.year - options[:start]),
      :end_year   => (Time.now.year - options[:end])
    }
  end

  def phone_format(ph_no)
    return "" if ph_no.blank?
    return ph_no #ph_no.first(3) + '.' + ph_no[3..5] + '.' + ph_no[6..-1] Commenting the format, since we are removing ph_no validation
  end

  def phone_code_format(ph_code)
    return "" if ph_code.blank?
    return ph_code + "-"
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields_for_qual(this)")
  end

  def difference_of_time_mmss(minuend_time, subtrahend_time)
    Time.at((minuend_time - subtrahend_time).to_i).utc.strftime("%M:%S")
  end

  def name_from_code(code, version = 2)
    ProductLanguages.display_name_from_code_and_version(code, version, :translation => false)
  end

  def facebox(*args, &block)
    if !args.last.is_a?(Hash) || args.last.fetch(:if, true)
      link_to *args, &block
    else
      block.call
    end
  end

  def wrap_long_string(text,max_width = 20)
    (text.length < max_width) ? text : text.scan(/.{1,#{max_width}}/).join("<wbr>")
  end

  def today_date
    Time.now.in_time_zone(TimeUtils.time_zone).strftime("%A %B %d,%Y")
  end

  def get_today_date
    today_date
  end

  def duration_in_24_hour_days(start_time,end_time)
    ((end_time - start_time)/(3600*24)).round(1)
  end

  def format_time_for_popup(time = nil)
    format_time(time, "%^a %m/%d/%y %I:%M%p")
  end

  def format_time(time = nil, format = '%B %d, %Y')
    TimeUtils.format_time(time, format)
  end

  def ps_show_count_is_not_zero?(type)
    current_user.get_preference.send(type) != 0
  end

  def get_timestamp(timestamp)
    default_timestamp = _("NA968230B3")
    default_timestamp = timestamp.to_time.strftime("%a %d %b %Y %I:%M %p") unless timestamp.blank?
    default_timestamp
  end

  def get_formatted_log_value(value)
    default_timestamp = _("NA968230B3")
    begin
      default_timestamp = value.to_time.strftime("%a %d %b %Y %I:%M %p")
    rescue
      default_timestamp = value unless value.blank?
    end
    default_timestamp
  end

  def get_titleized_name(value)
    default_val = _("NA968230B3")
    default_val = value.titleize unless value.blank?
    default_val
  end

  def check_mandatory
    if manager_logged_in? || coach_logged_in?
      return "*"
    else
      return ""
    end
  end

  def substitutions_content(sub)
    message = sub[:extra_session] ? "" : " requested a substitution"
    message << " for #{sub[:language]}"
    message << " appointment" if sub[:is_appointment]==true
    message << ", #{sub[:level_unit_lession]}" if sub[:level_unit_lession] != 'N/A'
    message << " starting #{format_time(sub[:subsitution_date], "%B %d, %Y, %I:%M %p")}"
    message << ", #{sub[:learners_signed_up]} Learner(s)" if sub[:learners_signed_up] != 'N/A'
    message
  end

  def calendar_date_select_tag( name, value = nil, options = {})
    options = {:class => 'jquery_datepicker'}.merge(options)
    value = options[:class] == "jquery_datepicker" ?   value.strftime("%B %-d,%Y") : value.strftime("%B %-d,%Y %I:%M %p") if value.is_a?(Time)
    text_field_tag(name, value, options)
  end

  def get_master_label(master_guid, license_guid)
    return "" if (master_guid.blank? || license_guid.blank?)
    (license_guid == master_guid) ? "(Master)" : ""
  end

  def get_formatted_type(type)
    return "" if type.blank?
    type.capitalize.gsub('Online_subscription','OSub')
  end

  def get_license_family_type?(type)
    return true if type=="family"
    false
  end

  def get_preferred_name(student)
    begin
      if student.preferred_name && !student.preferred_name.blank?
        return student.preferred_name
      else
        return "--"
      end
    rescue Exception => e
      return "--"
    end
  end

  def is_tosub_and_active_and_customer?(type, language_identifier, active_user, user_source_type)
    reflex_languages = ["KLE", "JLE", "CLE", "BLE"]
    (get_formatted_type(type) == "OSub") && (!reflex_languages.include?(language_identifier) ) && active_user && (user_source_type == "Community::User")
  end

  def get_classroom_type(number_of_seats, learner_count = nil)
    number_of_seats = number_of_seats.to_i
    learner_count ||= 0
    if(number_of_seats == 1)
      "Solo"
    elsif(number_of_seats == 4 && learner_count.to_i == 0)
      "Open"
    else
      "Group"
    end
  end

  def filter_valid_villages ( villages )
    disabled_villages    = VillagePreference.where("status='disabled'")
    disabled_village_ids = {}
    disabled_villages.each do |dis_village|
      disabled_village_ids[dis_village.village_id] = dis_village.village_id
    end

    villages.each do |village|
      villages.delete_if { |village| disabled_village_ids.include? village.id }
    end

    return villages;
  end

  private

  def highlight_search_result(text, query_hash)
    return if text.nil?
    @highlight_query ||= text_to_highlight(query_hash)#Memoize it to save future calls in the same request
    get_text(text.gsub(/(#{@highlight_query})/i,'<span class="highlight">\1</span>'))
  end

  def text_to_highlight(query_hash)
    allowable_params = [:query, :email, :name, :address]
    query = ""
    allowable_params.each {|allowable_param| query << " #{query_hash[allowable_param]}" if !query_hash[allowable_param].blank? }
    escape_chars = ["^", "$", "{", "}", "[", "]", "(", ")", ".", "*", "?", "<", ">", "-", "&"]
    escape_chars.each { |chars| query.gsub!(eval("/(\\#{chars})/"), '\\\\\1') }#Escape special characters in the string
    query.split(" ").join("|")
  end

  def pre
    link_to image_tag("/images/previous.png", :border => 0), {:controller=>"events",:action => "calendar", :date => @date.prev_month+1}, :remote => true
  end

  def nex
    link_to image_tag("/images/next.png", :border => 0), {:controller=>"events",:action => "calendar", :date => @date.next_month+1}, :remote => true
  end

  def prevm(day_array)
    link_to image_tag("/images/previous.png", :border => 0), {:controller=>"learners",:action => "my_calendar", :days=>day_array, :date => @date.prev_month+1}, :remote => true
  end

  def nextm(day_array)
    link_to image_tag("/images/next.png", :border => 0), {:controller=>"learners",:action => "my_calendar", :days=>day_array, :date => @date.next_month+1}, :remote => true
  end

  def event_texts
    Event.all.collect {|e| content_tag(:br, e.event_description)}
  end

  def tier1_navigation_items
    nav = []
    nav = [{:link_text => _('LearnersC3C4B6D0'),
            :selected_on => {'extranet/learners' => ['index']},
            :url_options => hash_for_learners_path}]
    nav << {:link_text => _('Learner_Support8B2DDAC2'),
            :selected_on => {'support_user_portal/licenses' => :all ,'support_user_portal/eschool_sessions' => :all },
            :url_options => hash_for_support_portal_home_path}
  end

  def currently_selected_tier1_nav_item
    found_nav = tier1_navigation_items.detect do |nav|
      nav[:selected_on].any? do |cont, actions|
        (params[:controller] == cont) && ((actions == :all) || actions.include?(params[:action]))
      end
    end
    found_nav ? found_nav : nil
  end

  def moderator_navigation_items
    nav = []
    nav = [{:link_text => 'Learners',
            :selected_on => {'extranet/learners' => ['index']},
            :url_options => hash_for_learners_path}]
    nav << {:link_text => 'Moderation',
            :selected_on => {'extranet/reports' => ['index']},
            :url_options => hash_for_reports_path }
  end

  def currently_selected_moderator_nav_item
    found_nav = moderator_navigation_items.detect do |nav|
      nav[:selected_on].any? do |cont, actions|
        (params[:controller] == cont) && ((actions == :all) || actions.include?(params[:action]))
      end
    end
    found_nav ? found_nav : nil
  end

  def default_navigation_items
    return @_default_nav if @_default_nav
    nav = []
    nav = [{:link_text => _('HomeD1E4A3EE'),
            :selected_on => {'extranet/homes' => ['index','audit_logs'], 'extranet/announcements' => :all, 'extranet/events' => :all, 'manager_portal' => ['notifications'], 'coach_portal' => ['notifications'], 'extranet/resources' => :all, 'extranet/links' => :all},
            :url_options => hash_for_homes_path,
            :subnav_items => get_homes_subnav }] unless tier1_user_logged_in? || led_user_logged_in? || community_moderator_logged_in? || admin_logged_in?
    if aria_coach_logged_in?
      nav << {:link_text => 'Sessions',
              :selected_on => {'coach_portal' => ['availability_template'], 'coach_scheduler' => ['my_schedule'], 'availability' => ['index']},
              :url_options => '/my_schedule',
              :subnav_items => [{:link_text => _('My_Schedule389A6531'),
                                 :controller => '/coach_scheduler',
                                 :action => 'my_schedule',
                                 :selected_on => ['my_schedule','availability_template']},
                                 {:link_text => _('Substitutions8BDAF8C'), :controller => '/substitution', :action => 'substitutions', :selected_on => ['substitutions']}
                               ]
              }

      nav << {:link_text => 'Studio Library',
              :selected_on => {'box_links' => :all},
              :url_options => hash_for_box_links_path,
              :subnav_items => []}
      nav << {:link_text => _('My_ProfileFE3EBF53'),
              :selected_on => {'coach_portal' => ['view_profile', 'edit_profile', 'preference_settings']},
              :url_options => hash_for_view_profile_path,
              :subnav_items => []}
      nav << {:link_text => 'Coach Roster',
              :selected_on => {'coach_roster' => ['coach_roster']},
              :url_options => coach_roster_path,
              :subnav_items => []}
      # nav << {:link_text => _('LearnersC3C4B6D0'), :selected_on => {'extranet/learners' => ['index', 'show', 'search_result'], 'support_user_portal/licenses' => ['license_info', 'show_learner_profile_and_license_information'], 'support_user_portal/eschool_sessions' => ['show']}, :url_options => hash_for_learners_path}
    elsif coach_logged_in?
      nav << {:link_text => 'Sessions',
              :selected_on => {'coach_portal' => ['availability_template'], 'substitution' => ['substitutions'], 'coach_scheduler' => ['my_schedule'], 'availability' => ['index']},
              :url_options => '/my_schedule',
              :subnav_items => [{:link_text => _('My_Schedule389A6531'),
                                 :controller => '/coach_scheduler',
                                 :action => 'my_schedule',
                                 :selected_on => ['my_schedule','availability_template']},
                                {:link_text => _('Substitutions8BDAF8C'), :controller => '/substitution', :action => 'substitutions', :selected_on => ['substitutions']},
                                {:link_text => _('Session_practiceCC65235F'),  :controller => 'http://studio.rosettastone.com/teachers/content_review', :action => '', :selected_on => ['show']}]
              }
      nav << {:link_text => 'Studio Library',
              :selected_on =>{'box_links' => :all},
              :url_options => hash_for_box_links_path,
              :subnav_items => []}
      nav << {:link_text => _('My_ProfileFE3EBF53'),
              :selected_on => {'coach_portal' => ['view_profile', 'edit_profile', 'preference_settings']},
              :url_options => hash_for_view_profile_path,
              :subnav_items => []}
      nav << {:link_text => 'Coach Roster',
              :selected_on => {'coach_roster' => ['coach_roster']},
              :url_options => coach_roster_path,
              :subnav_items => []}
      nav << {:link_text => _('LearnersC3C4B6D0'), :selected_on => {'extranet/learners' => ['index', 'show', 'search_result'], 'support_user_portal/licenses' => ['license_info', 'show_learner_profile_and_license_information'], 'support_user_portal/eschool_sessions' => ['show']}, :url_options => hash_for_learners_path}
    elsif admin_logged_in?
      nav << {
              :link_text => _('My_ProfileFE3EBF53'),
              :selected_on => {'support_user_portal/support_portal' => ['view_profile', 'edit_admin_profile']},
              :url_options => '/support_user_portal/view-profile'
              }
      nav << {
              :link_text => 'Admin Dashboard',
              :selected_on => {'extranet/homes' =>['admin_dashboard', 'audit_logs', 'track_users']},
              :url_options => '/homes/admin_dashboard'
             }
      nav << {
              :link_text => 'Scheduling Thresholds',
              :selected_on => {'scheduling_thresholds' =>['index']},
              :url_options => '/scheduling_thresholds'
             }
      nav << {
              :link_text => 'Application Configuration',
              :selected_on => {'application' =>['application_configuration']},
              :url_options => '/application_configuration'
             }
      nav << {
              :link_text => 'Application Status',
              :selected_on => {'application' =>['application_status']},
              :url_options => '/application-status'
             }
    elsif ( manager_logged_in?)
      nav << {:link_text => 'Sessions',
              :selected_on => {
                'manager_portal' => ['create_eschool_session', 'cancel_eschool_sessions', 'configurations', 'substitutions_report'],
                'schedules' => ['index','language_schedules'],
                'dashboard' => ['index'],
                'staffing' => ['view_report', 'show_staffing_file_info'],
                'scheduling_thresholds' =>['index'],
                'coach_scheduler' => ['index'],
                'availability' => ['index'],
                'substitution' => ['substitutions']
              },
              :url_options => schedules_path,
              :subnav_items => [{:link_text => _('Master_SchedulerA72F689E'), :controller => '/schedules', :action => 'index', :selected_on => ['index','language_schedules']},
                                {:link_text => _('Coach_SchedulesAA3CAA31'), :controller => '/coach_scheduler', :action => 'index', :selected_on => :all},
                                {:link_text =>  _('DashboardDE657D5B'), :controller => '/dashboard', :action => 'index', :selected_on => :all},
                                {:link_text => _('Substitutions8BDAF8C'), :controller => '/substitution', :action => 'substitutions', :selected_on => {'substitution' => ['substitutions'], 'manager_portal' => ['substitutions_report']},
                                 :has_child => true, :subnav_items => [{:link_text => 'Manage Substitutions',:controller => '/substitution', :action => 'substitutions',
                                                                        :selected_on => 'substitutions'},
                                                                       {:link_text => 'Substitutions Report', :controller => '/manager_portal', :action => 'substitutions_report', :selected_on => ['substitutions_report']}
                                                                       ]},


                                {:link_text => 'Staffing Model Reconciliation', :controller => '/staffing', :action => 'view_report', :selected_on => {'staffing' => ['view_report', 'show_staffing_file_info']},
                                 :has_child => true, :subnav_items => [{:link_text => 'View Report', :controller => '/staffing', :action => 'view_report', :selected_on => 'view_report'},
                                                                       {:link_text => 'Import Staffing Data', :controller => '/staffing', :action => 'show_staffing_file_info', :selected_on => 'show_staffing_file_info'}
                                                                       ]},
                                {:link_text => _('Session_practiceCC65235F'),  :controller => 'http://studio.rosettastone.com/teachers/content_review', :action => '', :selected_on => ['show']},
                                {:link_text => 'Scheduling Thresholds', :controller => '/scheduling_thresholds', :action => 'index', :selected_on => ['index']}]}
      nav << {:link_text => _('Coach_Management500B3C24'),
              :selected_on => {'coach' => 'create_coach', 'manager_portal' => [ 'view_coach_profiles', 'assign_coaches', 'coach_time_off'],'extranet/regions' => :all, 'report' => 'index', 'report/reflexes' => 'show' ,'report/reflexes' => 'show_eng'},
              :url_options => hash_for_view_coach_profiles_path,
              :subnav_items => [{:link_text => _('Create_a_Coach1597442F'), :controller => '/coach', :action => 'create_coach', :selected_on => ['create_coach']},
                                {:link_text => _('Assign_RegionsDC243CCB'), :controller => '/extranet/regions', :action => 'index', :selected_on => :all},
                                {:link_text => _('Assign_CoachesBA50525D'), :controller => '/manager_portal', :action => 'assign_coaches', :selected_on => ['assign_coaches']},
                                {:link_text => _('View_ProfilesB363E680'), :controller => '/manager_portal', :action => 'view_coach_profiles', :selected_on => ['view_coach_profiles']},
                                {:link_text => _('Activity_Report7A4AE917'), :controller => '/report', :action => 'index', :selected_on => ['index']},
                                {:link_text => 'ReFLEX Report', :controller => '/report/reflexes', :action => 'show', :has_child => true, :selected_on => {'report/reflexes' => ['show', 'show_eng']},
                                 :subnav_items => [{:link_text => "Advanced English", :controller => '/report/reflexes', :action => 'show', :selected_on => ['show']},
                                                   {:link_text => "All American English", :controller => '/report/reflexes', :action => 'show_eng', :selected_on => ['show_eng']}]},
                                {:link_text => 'Coach Time off', :controller => '/manager_portal', :action => 'coach_time_off', :selected_on => 'coach_time_off'}
                                ]}

      nav << {:link_text => 'Coach Roster',
              :selected_on => {'coach_roster' => ['coach_roster','edit_management_team']},
              :url_options => coach_roster_path,
              :subnav_items => [{:link_text => 'Edit Management Team', :controller => '/coach_roster', :action => 'edit_management_team', :selected_on => ['edit_management_team']}]}

      nav << {:link_text => 'Studio Library',
              :selected_on => {'box_links' => :all},
              :url_options => hash_for_box_links_path,
              :subnav_items => []}

      nav << {:link_text => _('Profile4EEA9393'),
              :selected_on => {'support_user_portal/support_portal' => ['view_profile', 'edit_profile', 'preference_settings']},
              :url_options => hash_for_view_support_profile_path}
      nav << {:link_text => _('LearnersC3C4B6D0'), :selected_on => {'extranet/learners' => ['index', 'show', 'search_result'], 'support_user_portal/licenses' => ['license_info', 'show_learner_profile_and_license_information'], 'support_user_portal/eschool_sessions' => ['show']}, :url_options => hash_for_learners_path}
      nav << {:link_text => 'Admin Dashboard', :selected_on => {'extranet/homes' => ['admin_dashboard']}, :url_options => home_admin_dashboard_path}
    elsif tier1_user_logged_in?
      nav << {:link_text => _('My_ProfileFE3EBF53'), :selected_on => {'support_user_portal/support_portal' => ['view_profile', 'edit_profile', 'preference_settings']}, :url_options => hash_for_view_support_profile_path}
      nav << {:link_text => _('LearnersC3C4B6D0'), :selected_on => {'extranet/learners' => ['index', 'show', 'search_result'], 'support_user_portal/licenses' => ['license_info', 'show_learner_profile_and_license_information'], 'support_user_portal/eschool_sessions' => ['show']}, :url_options => hash_for_learners_path}
      nav << {:link_text => 'Sessions',
              :selected_on => { 'dashboard' => ['index']},
              :url_options => hash_for_dashboard_path,
              :subnav_items => [{:link_text =>  _('DashboardDE657D5B'), :controller => '/dashboard', :action => 'index', :selected_on => :all}]}
    elsif led_user_logged_in?
      nav << {:link_text => 'Sessions',
              :selected_on => { 'dashboard' => ['index']},
              :url_options => hash_for_dashboard_path,
              :subnav_items => [{:link_text =>  _('DashboardDE657D5B'), :controller => '/dashboard', :action => 'index', :selected_on => :all}]}
      nav << {:link_text => _('My_ProfileFE3EBF53'),
              :selected_on => {'support_user_portal/support_portal' => ['view_profile', 'edit_profile', 'preference_settings']},
              :url_options => hash_for_view_support_profile_path}
    elsif community_moderator_logged_in?
      nav = [{:link_text => 'Learners',
              :selected_on => {'extranet/learners' => ['index']},
              :url_options => hash_for_learners_path}]
      nav << {:link_text => _('My_ProfileFE3EBF53'),
              :selected_on => {'support_user_portal/support_portal' => ['view_profile', 'edit_profile']},
              :url_options => hash_for_view_support_profile_path}
      nav << {:link_text => 'Sessions',
              :selected_on => { 'dashboard' => ['index']},
              :url_options => hash_for_dashboard_path,
              :subnav_items => [{:link_text =>  _('DashboardDE657D5B'), :controller => '/dashboard', :action => 'index', :selected_on => :all}]}
      nav << {:link_text => 'Moderation',
              :selected_on => {'extranet/reports' => ['index']},
              :url_options => hash_for_reports_path }
    end


    if (coach_logged_in?)|| (manager_logged_in?)
      nav << {:link_text => 'Files and Links',
              :selected_on => {'extranet/resources' => :all, 'extranet/links' => :all, 'extranet/content_review' => ['show']},
              :url_options => hash_for_resources_path,
              :subnav_items => [{:link_text => 'Coach Links',:controller => '/extranet/resources', :action => '',
                                 :selected_on => ['index', 'show', 'edit', 'new']},
                                {:link_text => 'Rosetta Links', :controller => '/extranet/links', :action => 'index', :selected_on => ['index', 'show', 'edit', 'new']}
                                ]} if false
    end
    if tier1_support_lead_logged_in?
      nav << {:link_text => 'View Coach Profiles',:selected_on => {'manager_portal' => [ 'view_coach_profiles']},:url_options => hash_for_view_coach_profiles_path}
    end
    if tier1_support_lead_logged_in? || tier1_support_user_logged_in? || tier1_support_harrisonburg_user_logged_in?
     nav << {:link_text => _('Reports3EA29ED9'),
              :subnav_items => [{:link_text => 'Product Rights',:controller => '/support_user_portal/licenses', :action => 'product_rights_modification_report', :selected_on => ['product_rights_modification_report'] },
                                {:link_text => 'Consumables',:controller => '/support_user_portal/licenses', :action => 'consumables_report', :selected_on => ['consumables_report'] },
                                {:link_text => 'Grandfathering',:controller => '/support_user_portal/licenses', :action => 'grandfathering_report', :selected_on => ['grandfathering_report'] }],
              :selected_on => {
                'support_user_portal/licenses' => %w(consumables_report product_rights_modification_report grandfathering_report)
              },
              :url_options => report_search_path
             }
    end

    if (tier1_support_harrisonburg_user_logged_in?) || (tier1_support_concierge_user_logged_in?) || (tier1_support_lead_logged_in?) || (community_moderator_logged_in?)
      nav << {:link_text => 'Rosetta Links',
              :selected_on => {'extranet/links' => ['index', 'show', 'edit', 'new']},
              :url_options => hash_for_links_path
              }
    end

    if tier1_support_concierge_user_logged_in?
      nav << {:link_text => 'Success Correspondence',
              :controller => 'http://stgsc1.lan.flt:8080/succor-impl-2.0/', :action => '',
              :selected_on => []
              }
    end

    #['','index', 'show', 'edit', 'new']
    if manager_logged_in?
      nav << {:link_text => _('ConfigurationsCE781201'),
              :selected_on => {
                'manager_portal' => ['manage_languages'], 'extranet/regions' => ['index', 'show', 'edit', 'new'],
                'village_preferences'  => ['index'], 'topics' => 'index',
                'appointment_types' => ['index']
                },
              :url_options => hash_for_manage_languages_path,
              :subnav_items => get_configuration_subnav }
    end
    @_default_nav = nav
  end

  def get_configuration_subnav
    configuration_subnav = []
    configuration_subnav << {:link_text => _('Languages_ManagedE6B1D042'), :controller => '/manager_portal', :action => 'manage_languages', :selected_on => ['manage_languages']}
    configuration_subnav << {:link_text => 'Villages', :controller => '/village_preferences', :action => 'index', :selected_on => ['index']} #  if admin_logged_in?
    configuration_subnav << {:link_text => 'AEB Topics Report', :controller => '/topics', :action => 'index', :selected_on => 'index'}
    configuration_subnav << {:link_text => 'Appointment Types', :controller => '/appointment_types', :action => 'index', :selected_on => ['index']} #  if admin_logged_in?
    configuration_subnav
  end

  def get_homes_subnav
    homes_sub_nav = []
    if coach_logged_in?
      homes_sub_nav << {:link_text => _('NotificationsD37EFB26'), :controller => '/coach_portal', :action => 'notifications', :selected_on => ['notifications']}
    end
    homes_sub_nav << {:link_text => _('NotificationsD37EFB26'), :controller => '/manager_portal',
                      :action => 'notifications', :selected_on => :all, :url_options => "manager-notifications"} if manager_logged_in?
    homes_sub_nav << {:link_text => _('AnnouncementsBC3C6168'), :controller => '/extranet/announcements', :action => 'index', :selected_on => :all}
    homes_sub_nav << {:link_text => _('Events542B527C'), :controller => '/extranet/events', :action => 'index', :selected_on => :all}
    homes_sub_nav << {:link_text => 'Files and Links',
                      :selected_on => {'extranet/resources' => :all, 'extranet/links' => :all}, :has_child => true,
                      :controller => '/extranet/resources', :action => 'index',
                      :subnav_items => [{:link_text => 'Coach Links',:controller => '/extranet/resources', :action => 'index',
                                         :selected_on => ['index', 'show', 'edit', 'new']},
                                        {:link_text => 'Rosetta Links', :controller => '/extranet/links', :action => 'index', :selected_on => ['index', 'show', 'edit', 'new']}

                                        ]}
    homes_sub_nav
  end

  def currently_selected_default_nav_item
    found_nav = default_navigation_items.detect do |nav|
      nav[:selected_on].any? do |cont, actions|
        (params[:controller] == cont) && ((actions == :all) || actions.include?(params[:action]))
      end
    end
    found_nav ? found_nav : nil
  end

  def currently_selected_default_sub_nav_item
    selected = []
    subnav = currently_selected_default_nav_item[:subnav_items]
    selected = subnav.detect do |s|
      s.any? do
        if s[:has_child].nil?
          (s[:controller] == '/' + params[:controller]) && ( s[:selected_on] ? ((s[:selected_on] == :all) || s[:selected_on].include?(params[:action])) : false)
        elsif s[:has_child] == true
          s[:selected_on].any? do |cont, actions|
            (params[:controller] == cont) && ((actions == :all) || actions.include?(params[:action]))
          end
        end
      end
    end if subnav
    selected
  end

  def currently_selected?(item)
    item && (item[:controller] == '/' + params[:controller]) && item[:selected_on] && ((item[:selected_on] == :all) || item[:selected_on].include?(params[:action]))
  end

  def get_region_id(support_user)
    return _("NA968230B3") if support_user.blank?
    Region.find(support_user).name
  end

  def get_mobile_number(user_id)
    (!user_id.blank? && (user = Account.find_by_id(user_id)) && !user.mobile_phone.blank?)? user.mobile_phone : _("Mobile_Phone_NADC15EC65")
  end

  def options_for_schedule(immediate = false)
    return {"Immediately" => "IMMEDIATELY"} if immediate
    COMMON_SCHEDULE_TYPES.sort
  end

  def options_for_substitution_policy_alert()
    SUBSTITUTION_POLICY_ALERT_TYPES.sort
  end

  def options_for_start_page
    manager_logged_in? ? COACH_MANAGER_START_PAGES.sort : coach_logged_in? ? current_coach.is_aria? ? ARIA_COACH_START_PAGES.sort : COACH_START_PAGES.sort : SUPPORT_USER_LEAD_START_PAGES.sort
  end

  def options_for_emails
    COMMON_EMAIL_TYPES.sort
  end

  def options_for_count
    COMMON_DISPLAY_COUNT.sort
  end

  def options_for_count_substitutions
    COMMON_DISPLAY_COUNT_SUBSTITUTIONS.sort
  end

  def options_for_dashboard_display_count
    DASHBOARD_RECORDS_COUNT.sort
  end

  def options_for_substitution_display_count
    SUBSTITUTION_DISPLAY_COUNT.sort
  end

  def options_for_substitution_alert_display_time
    SUBSTITUTION_DISPLAY_TIMES
  end

  def options_for_session_alert_display_time
    SESSION_ALERT_DISPLAY_TIMES.sort
  end

  def options_for_no_coach_session_alert_time
    ALERT_SCHEDULE_FOR_SESSION_WITH_NO_COACH.sort
  end

  def options_for_coach_session_language_unit(selected = nil)
    options = (1...5).to_a.map{|l| [l,l]}
    options.unshift(['-Unit-', "--" ])
    options_for_select(options,selected)
  end

  def escape_single_quotes(string_value)
    string_value && string_value.gsub(/[']/, '\\\\\'')
  end

  def link_to_or_text_with_style(condition, style_for_text, name, options, html_options)
    condition ? link_to(name, options, html_options) : "<span style='"+"#{style_for_text}"+"'>#{name}</span>"
  end

  def link_to_function_or_text_with_style(condition, style_for_text, name, *args, &block)
    condition ? link_to_function(name, *args, &block) : "<span style='"+"#{style_for_text}"+"'>#{name}</span>"
  end

  def link_to_learner_profile(link_text, learner)
    if can_view_license_link?
      link_to(link_text, "/view_learner/#{learner.guid}")
    else
      link_to(link_text, learner)
    end
  end

  def can_view_license_link?
    tier1_support_user_logged_in? || tier1_support_harrisonburg_user_logged_in? || tier1_support_lead_logged_in? || tier1_support_concierge_user_logged_in?
  end

  def show_na_if_error(hash, key)
    return "N/A" if hash == "Error" || hash.nil?
    hash[key]
  end

  def license_details_un_available?(details, creation_account)
    !creation_account || details == "Error" || details == nil
  end

  def get_master_label_value(details, creation_account)
    license_details_un_available?(details, creation_account) ? "" : get_master_label(creation_account["master_license_guid"],details["guid"])
  end

  def convert_to_minutes_and_seconds(seconds)
  # convert_to_minutes_and_seconds(125.00) => "2m 5s"
    seconds = seconds.to_f.round.to_i
    return "0s" if seconds <= 0
    return "#{seconds}s" if seconds < 60
    minutes = (seconds/60).to_i
    seconds_remaining = (seconds%60)
    return "#{minutes}m" if seconds_remaining == 0
    return "#{minutes}m #{seconds_remaining}s"
  end
  def get_correct_end_time_to_add_extension(end_date)
    end_date = Time.now.beginning_of_day if (end_date < Time.now.beginning_of_day)
    return end_date
  end
  # populates the dropdown to show CEFR level; CSP-886
  def options_for_cefr(selected = nil, source = nil)
    options = ["B1","B2","C1"]
    value = (source == "All") ? "All" : "--"
    options.unshift([source, value]) unless source.nil?
    options_for_select(options,selected)
  end

  # populates the dropdown to show no of seats; CSP-886
  def options_for_aria_seats(selected = nil)
    options = [1,6]
    options.unshift(['-Select-', "--" ])
    options_for_select(options,selected)
  end

  def alert_is_active
     Alert.display_active_topic
  end

  # execute a block with a different format (ex: an html partial while in a json request)
  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end

end
