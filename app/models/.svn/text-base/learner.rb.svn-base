# == Schema Information
#
# Table name: learners
#
#  id                           :integer(4)      not null, primary key
#  first_name                   :string(255)     
#  last_name                    :string(255)     
#  email                        :string(255)     
#  mobile_number                :string(255)     
#  guid                         :string(255)     
#  user_source_type             :string(255)     
#  totale                       :boolean(1)      
#  rworld                       :boolean(1)      
#  osub                         :boolean(1)      
#  osub_active                  :boolean(1)      
#  totale_active                :boolean(1)      
#  enterprise_license_active    :boolean(1)      
#  parature_customer            :boolean(1)      
#  previous_license_identifiers :text(65535)     
#  created_at                   :datetime        
#  updated_at                   :datetime        
#  village_id                   :integer(4)

require 'active_licensing/product_rights'
require File.dirname(__FILE__) +'/../utils/learner/learner_mapper'

class TableNotEmptyError < StandardError; end

class Learner < ActiveRecord::Base

  include ActiveLicensing::ProductRights
  include BafflingApi

  include Licensing::UserExtension

  delegate :license_identifier, :to => :user_source
  has_many :learner_product_rights
  
  class << self

    #Gets the updated / new users across all the models in USER_SOURCE_TYPES and adds to the local user table
    def update_profile_info
      last_updated_time = UserUpdateExecutionDetail.last_updated_time(UPDATE_IDENTIFIER[:profile])
      logger.info "Last updated time from user execution deatil : #{last_updated_time}"
      UserUpdateExecutionDetail.record_time(UPDATE_IDENTIFIER[:profile]) do
        USER_SOURCE_TYPES.map do |user_source_type|
          logger.info "Processing for User source type : #{user_source_type}"
          update_profile_per_source_type(user_source_type, last_updated_time)
        end # USER_SOURCE_TYPES array loop ends
      end
    end  # Method ends

    #Periodically run to update the learner product rights details
    def update_product_rights_detail
      last_updated_time = UserUpdateExecutionDetail.last_updated_time(UPDATE_IDENTIFIER[:product_right])
      logger.info "Last updated time from user execution deatil : #{last_updated_time}"
      UserUpdateExecutionDetail.record_time(UPDATE_IDENTIFIER[:product_right]) do
        update_learner_product_rights_detail(last_updated_time)
      end
    end

    # remove duplicate records
    def remove_duplication_of_records
      UserUpdateExecutionDetail.record_time(UPDATE_IDENTIFIER[:remove_duplicate_learner]) do
        count, options = 0, {:select => "id, guid", :group => "guid", :having => "count(guid) > 1"}
        ActiveRecord::Base.connection.uncached do
          self.find_in_batches(options) do |learners|
            count = count + learners.size
            learners.each do |learner|
              learners = self.find(:all, :conditions => ["guid = ?", learner.guid], :order => "updated_at DESC")
              viper_learners = learners.select { |learner|  learner.user_source_type == "RsManager::User"}
              learners[0].update_attributes(:user_source_type => "RsManager::User") if viper_learners.size > 0
              ids = learners.collect { |lr| lr.id }
              ids.delete_at(0)
              Learner.delete(ids)
            end
            puts "#{count} duplicate learners removed at #{Time.now}."
          end
        end
      end
    end
    
    #populate village id of learners from community, required only once
    def initial_population_of_village_id
      UserUpdateExecutionDetail.record_time(UPDATE_IDENTIFIER[:village_id_update]) do
        options = {:conditions => "user_source_type = 'Community::User' and village_id is null"}
        ActiveRecord::Base.connection.uncached do
          count, total_count = 0, self.count(options)
          self.find_in_batches(options) do |learners|
            count = count + learners.size
            learners.each do |learner|
              source_user = Community::User.find_by_guid(learner.guid)
              learner.update_attribute('village_id', source_user.village_id) if source_user && source_user.village_id
            end
            puts "#{(count/total_count.to_f).round(4)*100}% village id updated at #{Time.now}."
          end
        end
      end
    end
    
    #Periodically run to update the license info
    def update_license_info
      last_updated_time = UserUpdateExecutionDetail.last_execution_time(UPDATE_IDENTIFIER[:license])
      UserUpdateExecutionDetail.record_time(UPDATE_IDENTIFIER[:license]) do
        license_identifiers = Learner.recently_expired_or_created_licenses(last_updated_time)
        if license_identifiers
          users = license_identifiers.map { |license_identifier| find_user_by_license_identifier(license_identifier)  }.compact
          users.map(&:update_license_meta_data)
        end
      end
    end

    def update_license_identifiers_change_info
      last_processed_id = UserUpdateExecutionDetail.last_processed_id(UPDATE_IDENTIFIER[:license_identifier])
      UserUpdateExecutionDetail.record_time(UPDATE_IDENTIFIER[:license_identifier]) do
        baffler_response = Learner.recently_updated_license_identifiers(last_processed_id)
        guids = baffler_response["guid"] || []
        users = Learner.find_all_by_guid(guids)
        users.map do |user|
          user.update_attribute(:previous_license_identifiers, user.license_identifier_history[:previous_identifier].join(","))
          user.id
        end
        UserUpdateExecutionDetail.last_execution_for(UPDATE_IDENTIFIER[:license_identifier]).update_attribute(:last_processed_id, baffler_response["last_audit_log_record_id"].to_i)
      end
    end

    def find_user_by_license_identifier(license_identifier)
      user_source =
        if RsManager::User.rs_manager_license_identifier?(license_identifier)
        RsManager::User.find_by_license_identifier(license_identifier)
      else
        Community::User.find_by_license_identifier(license_identifier)
      end
      user_source.user
    rescue
      Rails.logger.error "No user corresponding to the identifier: #{license_identifier}"
      nil
    end

  end  # Public level class methods ends

  def update_license_meta_data
    if !self.load_license_details["active"]
      self.totale_active, self.osub_active, self.enterprise_license_active = false, false, false
      self.rworld = community_user?
    else
      if enterprise_user?
        self.enterprise_license_active = !get_usable_product_rights.blank?
      else
        #self.totale => Is used to know that the user was once a totale
        #self.totale_active => Is used to determine if the totale license is active or not
        if is_totale_user?
          self.totale, self.totale_active = true, true
        else
          self.totale_active = false
        end

        #self.osub => Is used to know that the user was once an osub
        #self.osub_active => Is used to determine if the osub license is active or not
        if is_osub_user?
          self.osub, self.osub_active = true, true
        else
          self.osub_active = false
        end

        self.rworld = community_user? && get_usable_product_rights.blank?
      end
    end
    self.save
    self.id
  end

  def name
    "#{first_name} #{last_name}"
  end

  def get_product_details
    result = {}
    language_display_name = {}
    projected_through = {}
    max = 0
    previous_language = ''
    prights = ls_api.license.product_rights(:guid => guid).reject{ |a| a["product_family"]=="eschool_one_on_one_sessions"}
    if(!prights.blank?)
      product = prights.select{|a| a["usable"]}
      product.each do | pr |
        if (pr["product_identifier"] != previous_language)
          if pr["product_family"] == "lotus"
             language_display_name[pr["product_identifier"]] = "REFLEX "
             projected_through[pr["product_identifier"]] = pr["ends_at"]
             previous_language = pr["product_identifier"]
          elsif language_display_name[pr["product_identifier"]].blank?
            product_language = Language.find_by_identifier(pr["product_identifier"])
            language_name = product_language ? product_language.display_name : pr["product_identifier"].to_s
            unless pr["product_version"] == "2"
              unless pr["content_ranges"].blank?
                language_display_name[pr["product_identifier"]] = language_name + '/' + pr["product_version"] + Learner.level_display_from_units(pr["content_ranges"][0]["min_unit"].to_i,pr["content_ranges"][0]["max_unit"].to_i)
              else
                max = ['ESP','FRA', 'DEU', 'ITA', 'ESC'].include?(pr["product_identifier"])? 20 : 12
                language_display_name[pr["product_identifier"]] = language_name + '/' + pr["product_version"] + Learner.level_display_from_units(1,max)
              end  
            else
              language_display_name[pr["product_identifier"]] = language_name + '/' + pr["product_version"]
            end
            projected_through[pr["product_identifier"]] = pr["ends_at"]
            previous_language = pr["product_identifier"]
          end  
        end
      end  
    end 
    result[:language_display_name] = language_display_name
    result[:projected_through] = projected_through
    result
  end 

  def self.level_display_from_units(min,max)
    return "" if (min == 0 && max == 0)
    name = " - Level "
    if max-min < 4
      name += (max/4).to_s
    else
      name += ((min/4) + 1).to_s + "-"
      name += (max/4).to_s
    end
  end

  def first_name
    read_attribute(:first_name) || ""
  end

  def last_name
    read_attribute(:last_name) || ""
  end

  def user_source
    return @user if @user
    @user = Community::User.find_by_guid(guid)
    @user = RsManager::User.find_by_guid(guid) if viper_user? && @user.nil?
  end

  def activated_at
    user_source.activated_at if is_source_community?
  end

  def birth_date
    user_source.get_birth_date if is_source_community?
  end

  def age
    user_source.age if is_source_community?
  end

  def gender
    user_source.gender if is_source_community?
  end

  def time_zone
    user_source.time_zone if is_source_community?
  end

  def preferred_name
    user_source.preferred_name if is_source_community?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def state_province
    user_source.state_province if is_source_community?
  end

  def city
    user_source.city if is_source_community?
  end

  def mobile_number_at_activation
    user_source.mobile_number_at_activation if is_source_community?
  end

  def username
    user_source.username if is_source_viper?
  end

  def country
    if is_source_community? && !user_source.country.blank?
      country_details = RosettaStone::Country.find_by_country_code(user_source.country)
      I18n.translate(country_details.translation_key) if country_details
    end
  end

  def totale_languages_display_name
    totale_languages.collect { |lang_code| name_from_code(lang_code) }.to_sentence
  end

  def rworld_languages
    if is_source_community?
      user_lang = UserLanguage.find_by_user_mail_id(email)
      if user_lang && !user_lang.language_identifier.blank?
        language_competencies = user_lang.language_identifier.split(',')
        language_competencies.select{ |lang| !ProductLanguages.reflex_language_codes.include?(lang) && lang != user_source.simbio_language_identifier && !totale_languages.include?(lang)}
      end
    end
  end

  def rworld_display_name
    rworld_languages.collect { |lang_code| name_from_code(lang_code) }.to_sentence if !rworld_languages.blank?
  end

  def simbio
    name_from_code(user_source.simbio_language_identifier) if is_source_community?
  end

  def reflex
    "Advanced English (#{reflex_languages.join(',')})" if reflex_languages.size > 0
  end

  def can_show_course_info?
    !baffler_course_tracking_info.blank? && !baffler_course_tracking_info["progressed_languages"].blank?
  end

  def can_show_studio_info?
    totale_languages.size > 0
  end

  def can_show_reflex_conversation?
    reflex_languages.size > 0
  end

  def number_of_completed_reflex_sessions
    Eschool::Student.get_completed_reflex_sessions_count_for_learner(guid) if reflex_languages.length > 0
  end
  
  def totale_languages
    languages - reflex_languages
  end

  def reflex_languages
    ProductLanguages.reflex_language_codes & languages
  end

  def simbio_language_identifier
    user_source.simbio_language_identifier if is_source_community?
  end

  def selected_language_identifier
    user_source.selected_language_identifier if is_source_community?
  end

  def user_session_log
    is_source_community? ? user_source.user_session_logs : []
  end
    
  def address_info
    addr_info = []
    addr_info << state_province if !state_province.blank?
    addr_info << city if !city.blank?
    addr_info.join(',')
  end

  def village_name
    Community::Village.display_name(village_id) if village_id
  end

  def languages
    if @lang.blank?
      begin
        @lang = RosettaStone::ActiveLicensing::Base.instance.license.product_rights(:guid => guid).collect {|dd| dd["product_identifier"]}.uniq
      rescue
        @lang = learner_product_rights.collect{|lpr| lpr.language_identifier}.uniq
      end
    end
    @lang
  end
    
  def type
    (user_source_type == "Community::User") ? "Community" : "Viper"
  end

  def learner_type
    (user_source_type == "Community::User") ? "Consumer" : "Institutional"
  end

  def is_source_community?
    user_source && user_source.class.to_s == "Community::User"
  end

  def is_source_viper?
    user_source && user_source.class.to_s == "RsManager::User"
  end
  
  def subscriptions
    subscriptions_arr = []
    if totale?
      subscriptions_arr << (totale_active? ? "TOTALe Active" : "TOTALe Inactive")
    end
    if osub?
      subscriptions_arr << (osub_active? ? "OSub Active" : "Osub Inactive")
    end
    subscriptions_arr << "RWorld" if rworld?
    subscriptions_arr << (enterprise_license_active? ? "Active" : "Inactive") if enterprise_user?
    subscriptions_arr
  end

  def community_user?
    user_source_type == "Community::User"
  end

  def viper_user?
    user_source_type == "RsManager::User"
  end

  def enterprise_user?
    viper_user?
  end

  def get_skipped_session
    skipped_count = 0
    if studio_history && !studio_history.eschool_sessions.blank?
      studio_history.eschool_sessions.each do |es|
        skipped_count += 1 if es.attended != "true" && es.cancelled != "true" && (es.start_time.to_time < Time.now.utc)
      end
    end
    skipped_count
  end

  def future_sessions(language_identifier = nil)
    return [] if session_summary.blank?
    return session_summary.future_sessions if language_identifier.blank?
    session_summary.future_sessions.select{|session| session.language == language_identifier}
  end

  def as_student
    session_summary
  end
  
  def session_summary
    @student ||= Eschool::Learner.sessions_summary(guid)
  end

  def studio_history
    @studio_history ||= Eschool::Learner.studio_history(guid)
  end

  # please pass product_rights = RosettaStone::ActiveLicensing::Base.instance.license.product_rights(:guid =>license_guid)
  def self.is_grandfathered(product_rights)
    product_hash = {}
    product_rights.each do |product|
      if product_hash[product['product_identifier']]
        product_hash[product['product_identifier']] << product['product_family']
      else
        product_hash[product['product_identifier']] = [product['product_family']]
      end
    end
    product_hash.each do |key,value|
      if value.include?("eschool_group_sessions")
        product_hash[key] = false
      else
        product_hash[key] = true
      end
    end
    product_hash
  end
  def self.all_product_hash(product_rights)
    product_hash = {}
    product_rights_hash={}
    product_rights_array = []
    product_rights.each do |pr|
      if product_hash[pr['product_identifier']]
       product_hash[pr['product_identifier']][pr['product_family']] = pr['guid']
      else
        product_hash[pr['product_identifier']] = {pr['product_family'] => pr['guid'] }
      end
      (product_rights_array << pr["guid"]) if (pr['product_family'] == "eschool_group_sessions" || pr['product_family'] == "eschool_one_on_one_sessions")
    end
    extensions_for_product_rights = all_extensions_for_prodcut_rights(product_rights_array)
    all_consumables_for_product_rights(product_rights_array)
    product_rights_hash
    product_hash
  end

  def self.all_extensions_for_prodcut_rights(product_rights_array)
    extensions = ls_api.multicall do
      product_rights_array.each do |pr|
        product_right.extensions(:guid => pr)
      end
    end
  end

  def self.all_consumables_for_product_rights(product_rights_array)
    consumable_hash = {}
    product_right_consumable_hash = {}
    product_rights_consumables_usable = ls_api.multicall do
      product_rights_array.each do |pr|
        product_right.projected_consumables(:product_right_guid => pr)
      end
    end

    product_rights_consumables_usable_not_usable = ls_api.multicall do
      product_rights_array.each do |pr|
        product_right.consumables(:product_right_guid => pr)
      end
    end
      product_rights_consumables_usable.each do |usable|

      end
      product_rights_consumables_usable_not_usable.each do |both_usable_not_usable|
       if product_right_consumable_hash[pr]
         product_right_consumable_hash[pr] << both_usable_not_usable[:response]
       else
         product_right_consumable_hash[pr] = both_usable_not_usable[:response]
       end
      end
  end

  def self.get_consumable_details
    
  end
  # please pass product_rights = RosettaStone::ActiveLicensing::Base.instance.license.product_rights(:guid =>license_guid)
  def self.add_to_session(product_rights)
    product_rights_hash = {}
    begin
      consumable_product_rights = product_rights.collect{|pr| pr["guid"] if (pr['product_family'] == "eschool_group_sessions" || pr['product_family'] == "eschool_one_on_one_sessions")}.compact
      if(consumable_product_rights.any?)
        product_rights_consumables = ls_api.multicall do
          consumable_product_rights.each do |pr|
            product_right.projected_consumables(:product_right_guid => pr)
          end
        end
        product_rights_consumables.each_with_index do |product,index|
          if(product[:response].any?)
            product_rights_hash[consumable_product_rights[index]] = true
          else
            product_rights_hash[consumable_product_rights[index]] = false
          end
        end
      end
      product_rights_hash
    rescue Exception => e
      HoptoadNotifier.notify(e)
    end
  end

  def self.construct_add_to_session(product_rights,identifier = nil)
    if identifier
      product_rights = product_rights.select{|pr| pr["product_identifier"] == identifier}
    end
    product_rights_consumables = add_to_session(product_rights)
    product_hash = {}
    product_rights.each do |product|
      if product_hash[product['product_identifier']]
        product_hash[product['product_identifier']] << product
      else
        product_hash[product['product_identifier']] = [product]
      end
    end
    product_hash.each do |key,value|
      product_hash[key] = false
      studio = value.detect{|pr| pr["product_family"] == "eschool"}
      if studio && studio["usable"]
        pr_family = value.collect{ |pr| pr["product_family"] }.include?("eschool_group_sessions")
        if(pr_family)
          pr_array = value.collect{ |pr| pr["guid"] } & product_rights_consumables.keys
          if (pr_array).any?
            pr_array.each do |pr|
              product_hash[key] ||= product_rights_consumables[pr]
            end
          else
            product_hash[key] = true
          end
        else
           product_hash[key] = true
        end
      end
    end
    product_hash
  end
  
  protected

  def self.update_learner_product_rights_detail(last_updated_time)
    query = "select product_id, license_id, guid, activation_id from product_rights"
    query += " where created_at >= '#{last_updated_time.to_s(:db)}'" if last_updated_time
    ActiveRecord::Base.connection.uncached do
     count = 0
      LicenseServer::ProductRight.find_by_sql([query,last_updated_time]).each do |product_right|
        count = count + 1
          license = LicenseServer::License.find_by_id(product_right.license_id)
          learner = Learner.find_by_guid(license.guid) if license
          if learner
            product = LicenseServer::Product.find_by_id(product_right.product_id)
            learner_product_right = LearnerProductRight.find_or_create_by_product_guid(product_right.guid)
            learner_product_right.update_attributes({:learner_id => learner.id, :activation_id => product_right.activation_id, :language_identifier => product.identifier})
          end
      end
      puts "#{count} product rights created/updated at #{Time.now}."
    end
  end

  #Updates the user from the source type for the given date range and retuns an id of the updated records.
  def self.update_profile_per_source_type(user_source_type, last_updated_time)
    model = user_source_type.camelize.constantize
    options = last_updated_time.nil? ? {}: {:conditions => ["updated_at > ?", last_updated_time]}
    ActiveRecord::Base.connection.uncached do
      count, total_count = 0, model.count(options)
      model.find_in_batches(options) do |source_users|
        count = count + source_users.size
        source_users.each do |source_user|
          learner = self.find_or_create_by_guid(source_user.guid)
          options = LearnerMapper.map_attributes(source_user, learner.user_source_type)
          learner.update_attributes(options)
        end
        puts "#{(count/total_count.to_f).round(4)*100}% #{user_source_type} fetched at #{Time.now}."
      end
    end
  end

  def user_type
    return SOURCE_TYPE_INDEXED[self.user_source_type]
  end

  def name_from_code(code, version = 2)
    ProductLanguages.display_name_from_code_and_version(code, version, :translation => false)
  end

  def self.ls_api
    RosettaStone::ActiveLicensing::Base.instance
  end
end

