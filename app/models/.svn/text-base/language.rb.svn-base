# == Schema Information
#
# Table name: languages
#
#  id               :integer(4)      not null, primary key
#  identifier       :string(255)     not null
#  created_at       :datetime
#  updated_at       :datetime
#  last_pushed_week :datetime        default(Tue Oct 04 16:25:22 UTC 2011)
#

class Language < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger
  validates_uniqueness_of :identifier

  has_many :qualifications, :dependent => :destroy
  has_many :dialects,       :dependent => :destroy
  has_many :coaches,        :through   => :qualifications, :conditions => 'max_unit > 0 and active = 1', :order => 'trim(full_name)', :select => ((Account.column_names - ['photo_file']).map { |column_name| "`accounts`.`#{column_name}`"})
  has_many :managers,       :through   => :qualifications, :conditions => 'max_unit is NULL'

  def self.group_appointment_languages(app_languages)
    lang_map = {
      "TMM-NED-L" => [Language["TMM-NED-L"],Language["TMM-NED-P"]],
      "TMM-ENG-L" => [Language["TMM-ENG-L"],Language["TMM-ENG-P"]],
      "TMM-FRA-L" => [Language["TMM-FRA-L"],Language["TMM-FRA-P"],Language["TMM-MCH-L"]],
      "TMM-DEU-L" => [Language["TMM-DEU-L"],Language["TMM-DEU-P"]],
      "TMM-ITA-L" => [Language["TMM-ITA-L"],Language["TMM-ITA-P"]],
      "TMM-ESP-L" => [Language["TMM-ESP-L"],Language["TMM-ESP-P"]]
    }
    ret=[]
    app_languages.each do |app_lang|
      lang_map.each do |k,v|
        ret << [Language[k].display_name_without_type + ' - Appointment',Language[k].id.to_s+"-A"] if v.include?(app_lang)
      end
    end
    ret.uniq
  end

  def self.fetch_same_group_appointment_languages(app_lang_id)
    app_lang = Language.find(app_lang_id)
    lang_map = {
      "TMM-NED-L" => [Language["TMM-NED-L"],Language["TMM-NED-P"]],
      "TMM-ENG-L" => [Language["TMM-ENG-L"],Language["TMM-ENG-P"]],
      "TMM-FRA-L" => [Language["TMM-FRA-L"],Language["TMM-FRA-P"],Language["TMM-MCH-L"]],
      "TMM-DEU-L" => [Language["TMM-DEU-L"],Language["TMM-DEU-P"]],
      "TMM-ITA-L" => [Language["TMM-ITA-L"],Language["TMM-ITA-P"]],
      "TMM-ESP-L" => [Language["TMM-ESP-L"],Language["TMM-ESP-P"]]
    }
    ret=[]
    lang_map.each do |k,v|
      ret << v if (v.include?(app_lang))
    end
    ret.uniq.flatten
  end

  def not_pushed?(datetime)
    start_of_week = TimeUtils.beginning_of_week(datetime)
    (last_pushed_week < start_of_week)? start_of_week : nil
  end

  def update_last_pushed_week(datetime)
    start_of_week = not_pushed?(datetime)
    update_attribute(:last_pushed_week, start_of_week) if start_of_week
  end

  def filter_name
    "TOTALe/ReFLEX"
  end

  def is_lotus?
    is_a?(ReflexLanguage)
  end

  def is_aria?
    is_a?(AriaLanguage)
  end

  def is_totale?
    is_a?(TotaleLanguage)
  end

  def is_tmm?
    is_a?(TMMPhoneLanguage) || is_a?(TMMLiveLanguage) || is_a?(TMMMichelinLanguage)
  end

  def is_tmm_phone?
    is_a?(TMMPhoneLanguage)
  end

  def is_tmm_live?
    is_a?(TMMLiveLanguage)
  end

  def is_tmm_michelin?
    is_a?(TMMMichelinLanguage)
  end

  def is_one_hour?
    duration == 60
  end

  def is_supersaas?
     is_aria? || is_tmm_michelin? || is_tmm_phone?
  end

  def duration_in_seconds
    duration.minutes
  end

  def display_name_without_type
    identifier
  end

  #return 0 (undefined) mode of contact for non applicable languages(non-RSA)
  def supersaas_session_type
    0
  end

  def alias_id
    return "#{Language["TMM-FRA-L"].id}-A" if ["TMM-FRA-L","TMM-FRA-P","TMM-MCH-L"].include?(identifier)
    return "#{Language["TMM-ENG-L"].id}-A" if ["TMM-ENG-L","TMM-ENG-P"].include?(identifier)
    return "#{Language["TMM-ITA-L"].id}-A" if ["TMM-ITA-L","TMM-ITA-P"].include?(identifier)
    return "#{Language["TMM-ESP-L"].id}-A" if ["TMM-ESP-L","TMM-ESP-P"].include?(identifier)
    return "#{Language["TMM-DEU-L"].id}-A" if ["TMM-DEU-L","TMM-DEU-P"].include?(identifier)
    return "#{Language["TMM-NED-L"].id}-A" if ["TMM-NED-L","TMM-NED-P"].include?(identifier)
  end

  class << self
    def all_sorted_by_name
      all.sort_by(&:display_name)
    end

    def non_aria_sorted_by_name
      non_aria.sort_by(&:display_name)
    end

    def [](id_or_identifier)
      where(["id = ? OR identifier = ?", id_or_identifier, id_or_identifier]).last
    end

    def options
      langs = all_sorted_by_name.map {|l| [l.display_name.to_s, l.id]}
      #reject michelin because it is dependent on TMM Live French
      langs.delete(["Michelin French",Language.find_by_identifier("TMM-MCH-L").id])
      langs
    end

    def lang_options(aria = false)
      language_obj(aria).sort_by(&:display_name).map{|l| [l.display_name.to_s, l.id]}
    end

    def language_obj(aria = false)
      where(aria ? "type = 'AriaLanguage'" : "type !='AriaLanguage'")
    end

    def options_with_identifiers
      all.sort_by(&:display_name).map {|l| [l.display_name.to_s, l.identifier] }
    end

    def options_with_identifiers_for_pll(languages_to_remove)
      [["Select a language", ""]] + where("identifier NOT IN (#{languages_to_remove})").sort_by(&:display_name).map {|l| [l.display_name.to_s, l.identifier] }
    end

    def non_aria
      language_obj(false)
    end

  end

  def display_name
   ProductLanguages.display_name_from_code_and_version(identifier, 3, :translation => false)
  end

  def sort_display_name
    lang = display_name
    {"English (American)" => "Eng (American)", "Spanish (Latin America)" => "Spanish (LA)", "Spanish (Spain)" => "Spanish (SP)", "Filipino (Tagalog)" => "Filipino"}[lang] || lang
  end

  def has_levels_4_and_5?
    ProductLanguages.has_level_4_and_5?(iso_code)
  end

  def max_level
    has_levels_4_and_5? ? 5 : 3
  end

  def max_unit
    max_level * UNITS_PER_LEVEL
  end

  def iso_code
    ProductLanguages.iso_code_for(identifier)
  end

  def self.lotus_languages
    ReflexLanguage.all
  end

  def self.session_languages
    @session_languages = Array.new
    @session_languages << %w(All All)
    @session_languages << %w(KLE KLE)
    @session_languages << %w(JLE JLE)
    @session_languages << ['Advanced English', 'ADE']
    @session_languages << ['All - AEB ', 'AEB']
    @session_languages << ['AEB US', 'AUS']
    @session_languages << ['AEB UK', 'AUK']
   # @session_languages << ['All - Exclude Advanced English', 'All - Exclude Advanced English']
    all.each do |lang|
      @session_languages << [lang.display_name, lang.identifier] if lang.is_totale?
    end
    @session_languages.sort! { |first_array, second_array| first_array[0].downcase <=> second_array[0].downcase }
  end

  def locked?
    SchedulerMetadata.where(:lang_identifier => identifier,  :locked => true ).last || nil
  end

  def eschool?
    is_totale?
  end

  def super_saas?
    is_supersaas?
  end

end
