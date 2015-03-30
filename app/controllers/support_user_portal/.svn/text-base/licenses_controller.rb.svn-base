require 'interface/lcdb'
class SupportUserPortal::LicensesController < ApplicationController

  include LCDBIface

  before_filter :get_learners, :only => [:show_learner_profile_and_license_information, :license_info, :view_access_log, :studio_history, :course_info_details, :community_audit_logs, :add_or_remove_extension]

  def show_learner_profile_and_license_information
    self.page_title = "Learner Profile - " +  @learner.name
    begin
      @details = ls_api.license.details(:guid => params[:license_guid])
      @creation_account = ls_api.creation_account.details(:creation_account_guid => @details["creation_account_guid"])
    rescue Exception => ex
      @details = "Error"
      @error   = "License information not available for the given identifier/ GUID."
      HoptoadNotifier.notify(ex)
    end
  end


  def license_info
    begin
      if !params[:license_guid].blank?
        @details = ls_api.license.details(:guid => params[:license_guid])
        @prights = ls_api.license.product_rights(:guid => params[:license_guid])
      elsif !params[:license_identifier].blank?
        @details = ls_api.license.details(:license => params[:license_identifier])
        @prights = ls_api.license.product_rights(:license => params[:license_identifier])
      end
      grandfather_info_for_products = Learner.is_grandfathered(@prights)
      @creation_account = ls_api.creation_account.details(:creation_account_guid => @details["creation_account_guid"])
      page_title        = "License Information for "
      page_title       += @learner.name if @learner
      self.page_title   = page_title
      @cr_array         = []
      @cr_hash          = {}
      reflex_language_array = ['JLE', 'KLE', 'BLE', 'CLE']
      community_user = Community::User.find_by_guid(params[:license_guid])
      @village = community_user && community_user.village_id ? community_user.village_id : "None"
      active_language = community_user.selected_language["identifier"] if community_user && community_user.selected_language
      # add_to_session = Learner.construct_add_to_session(@prights,active_language)
      @prights.each do |product|
        if Language.find_by_identifier(reflex_language_array.include?(product['product_identifier']) ? 'KLE' : product['product_identifier'])
          is_grandfathered = grandfather_info_for_products[product["product_identifier"]]
          found   = false
          cr_hash = {}
          @cr_array.each do |existing_cr|
            if existing_cr[:language] == product["product_identifier"] && existing_cr[:version] == product["product_version"]
              cr_hash = existing_cr
              found   = true
              break;
            end
          end
          if !found
            ext_details       = ls_api.product_right.extensions(:guid => product["guid"])
            ext_details_count = ext_details ? ext_details.length : 0
            active_language_flag = ((active_language == product["product_identifier"]) && !(@prights.detect {|pr| (pr["product_identifier"] == active_language and pr["product_family"] == "eschool") }).blank?)
            cr_hash           = {
              :language           => product["product_identifier"],
              :version            => product["product_version"],
              :family             => product["product_family"],
              :valid_through      => product["unextended_ends_at"],
              :projected_through  => product["ends_at"],
              :product_right_guid => product["guid"], # it denotes product rights' guid
              :usable             => product["usable"],
              :ext_count          => ext_details_count,
              :created_at         => product["created_at"],
              :flag               => active_language_flag,
              :consumables_flag   => !active_language_flag,
              :previous_languages => get_product_language_logs(product["guid"]),
              :having_futute_session => @learner.future_sessions(product["product_identifier"]).size > 0
            }

            if product["product_family"]      == "lotus"
              cr_hash[:lotus_guid]            = product["guid"]
              cr_hash[:cr_array_for_display]  = [{:language_display_name => "REFLEX",
                  :activation_id          => ext_details_count > 0 ? ext_details[ext_details_count - 1]["activation_id"] : "N/A"
                }]
              @cr_array << cr_hash
            else
              cr_hash[:cr_array_for_display] = []
              populate_product_guid_and_validity(cr_hash, product)
              solo_product_rights = @prights.find {|p| p["product_family"] == "eschool_one_on_one_sessions" && p["product_identifier"] == product["product_identifier"]}
              group_product_rights = @prights.find {|p| p["product_family"] == "eschool_group_sessions" && p["product_identifier"] == product["product_identifier"] }
              extensions = (product["product_family"] == "eschool_group_sessions") ? ext_details : ls_api.product_right.extensions(:guid => group_product_rights["guid"]) if group_product_rights
              if (solo_product_rights or group_product_rights)
                solo_product_right_guid = solo_product_rights['guid'] if solo_product_rights
                group_product_right_guid = group_product_rights['guid'] if group_product_rights
                group_starts_at = group_product_rights['starts_at'] if group_product_rights
                group_valid_through = group_product_rights['unextended_ends_at'] if group_product_rights
                solo_starts_at = solo_product_rights['starts_at'] if solo_product_rights
                solo_valid_through = solo_product_rights['unextended_ends_at'] if solo_product_rights
                cr_hash[:consumables_for_all_extensions] = create_consumables_array(extensions, is_grandfathered, solo_product_right_guid, group_product_right_guid, group_starts_at, group_valid_through, solo_starts_at, solo_valid_through)
                cr_hash[:additional_sessions] = AddConsumableLog.find_added_consumables([solo_product_right_guid, group_product_right_guid, (extensions ? extensions.collect {|e| e['guid']} : []) ].compact.flatten!)
              end

              if product["product_family"] == "eschool_one_on_one_sessions" or product["product_family"] == "eschool_group_sessions"
                upcoming_sessions = @learner.future_sessions(product["product_identifier"])
                upcoming_sessions = upcoming_sessions.each  do |session|
                  session.attributes["session_time"] = DateTime.strptime(session.attributes["on"], "%Y-%m-%d %H:%M:%S %z")
                end
                cr_hash[:upcoming_sessions] = upcoming_sessions
                session_details = fetch_session_details_of_learner(product, cr_hash[:upcoming_sessions], cr_hash[:consumables_for_all_extensions])
                cr_hash[:consumables_for_all_extensions] = session_details[0]
                cr_hash[:solo_available_from] = session_details[1] if session_details[1]
                cr_hash[:group_available_from] = session_details[2] if session_details[2]
                cr_hash[:consumables] = cr_hash[:consumables_for_all_extensions].find {|c| c[:show]}
              end

              unless product["product_version"] == "2"
                if ['ESP','FRA', 'DEU', 'ITA', 'ESC'].include?(product["product_identifier"])
                  max = 20
                else
                  max = 12
                end
                unless @cr_hash.has_key?(product["product_identifier"])
                  cr_array_temp = Array.new(max+1)
                  @cr_hash[product["product_identifier"]] = cr_array_temp
                end
                temp_array = @cr_hash[product["product_identifier"]]
                unless product["content_ranges"].blank?
                  product["content_ranges"].each do |cr|
                    cr_details = {
                      :language_display_name => Language[product["product_identifier"]].display_name + '/' + product["product_version"] + Learner.level_display_from_units(cr["min_unit"].to_i,cr["max_unit"].to_i),
                      :activation_id => cr["activation_id"].blank? ? (ext_details_count > 0 ? ext_details[ext_details_count - 1]["activation_id"] : "N/A") : cr["activation_id"]
                    }
                    cr_hash[:cr_array_for_display] << cr_details
                    for i in cr["min_unit"].to_i..cr["max_unit"].to_i do
                      temp_array[i] = true
                    end
                  end
                else
                  cr_details = {
                    :language_display_name => Language[product["product_identifier"]].display_name + '/' + product["product_version"] + Learner.level_display_from_units(1,max),
                    :activation_id         => ext_details_count > 0 ? ext_details[ext_details_count - 1]["activation_id"] : "N/A"
                  }
                  cr_hash[:cr_array_for_display] << cr_details
                  temp_array.each{|ele,i| temp_array[i] = true}
                end
              else
                cr_details = {
                  :language_display_name => Language[product["product_identifier"]].display_name + '/' + product["product_version"],
                  :activation_id         => ext_details_count > 0 ? ext_details[ext_details_count - 1]["activation_id"] : "N/A"
                }
                cr_hash[:cr_array_for_display] << cr_details
              end
              @cr_array << cr_hash
            end
          else
            populate_product_guid_and_validity(cr_hash, product)
            if product["product_family"] == "eschool_one_on_one_sessions" or product["product_family"] == "eschool_group_sessions"
              unless cr_hash[:upcoming_sessions]
                upcoming_sessions = @learner.future_sessions(product["product_identifier"])
                upcoming_sessions = upcoming_sessions.each  do |session|
                  session.attributes["session_time"] = DateTime.strptime(session.attributes["on"], "%Y-%m-%d %H:%M:%S %z")
                end
                cr_hash[:upcoming_sessions] = upcoming_sessions.sort_by {|session| session.attributes['session_time']}
              end
              session_details = fetch_session_details_of_learner(product, cr_hash[:upcoming_sessions], cr_hash[:consumables_for_all_extensions])
              cr_hash[:consumables_for_all_extensions] = session_details[0]
              cr_hash[:solo_available_from] = session_details[1] if session_details[1]
              cr_hash[:group_available_from] = session_details[2] if session_details[2]
              cr_hash[:consumables] = cr_hash[:consumables_for_all_extensions].find {|c| c[:show]}
            end
          end
        end
      end
      #Sort by created at
      @cr_array = @cr_array.sort_by{|ele| ele[:created_at]}.reverse
      @learners_languages = []
      @cr_array.each do |cr|
        @learners_languages << "'" +cr[:language] + "'"
      end
      @learners_languages = @learners_languages.join(',')
      @cr_array.collect do |cr_hash|
        language_display_name = cr_hash[:cr_array_for_display].collect{|cr| cr[:language_display_name]}.first
        tosub_product = tosub_products(language_display_name, get_formatted_type(@creation_account["type"]))
        cr_hash[:enable_activation_id] = true
        cr_hash[:enable_add_or_remove_extension] = true
        if tosub_product
          cr_hash[:enable_activation_id] = true
          cr_hash[:enable_add_or_remove_extension] = true
        end
        if cr_hash[:flag] and cr_hash[:group_guid]
          cr_hash[:flag] = !(cr_hash[:solo_available_from] or cr_hash[:group_available_from]).blank?
        end
      end

    rescue Exception => ex
      @details = "Error"
      @error   = "License information not available for the given identifier/ GUID."
      HoptoadNotifier.notify(ex)
      render :text => "<br/>#{@error}" and return
    end
    render :partial => 'license_info'
  end

  def show_consumable_form
    render :partial => "support_user_portal/licenses/consumable_form", :locals => {:data => params}
  end

  def add_consumable
    license_guid = params[:license_guid]
    session_type = params[:session_type]
    pooler_type = (session_type != '0')? 'ProductRight' : params[:pooler_type]
    consumable_add_count = params[:number_of_sessions].to_i
    product = params[:language]
    ends_at = params[:end_date].to_time.to_i
    pooler_guid = session_type == '0' ? params[:group_product_right] : params[:solo_product_right]
    reason = (params[:reason] == "Other") ? params[:other_reason] : params[:reason]
    rollover_count = session_type == '0' ? 0 : nil
    begin
      if (session_type == '1')
        pooler_guid = handle_solo_pr_rights(pooler_guid,(params[:craccount_type] == "family"), (pooler_guid.length < 5))
      end
      added_consumable = ls_api.consumable.add(:pooler_type => pooler_type, :pooler_guid => pooler_guid, :remaining_rollover_count => rollover_count, :count => consumable_add_count,
                                                :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json )
      if added_consumable
        AddConsumableLog.create(:support_user_id => current_user.id,
          :license_guid => license_guid,
          :reason => reason,
          :consumable_type => (session_type == '0' ? 'Group' : 'Solo'),
          :case_number => params[:case_number],
          :action => params[:action_performed],
          :number_of_sessions => consumable_add_count,
          :pooler_guid => pooler_guid,
          :pooler_type => pooler_type)
        flash[:notice] = "Consumable added successfully"
        redirect_to "/view_learner/#{license_guid}"
      else
        flash[:error] = "Consumable could not be added"
        redirect_to "/view_learner/#{license_guid}"
      end
    rescue Exception => ex
      flash[:error] = ex.message
      redirect_to "/view_learner/#{license_guid}"
    end
  end

  def show_uncap_learner_form
    render :partial => "support_user_portal/licenses/uncap_learner_form", :locals => {:data => params}
  end

  def uncap_learner
    reason = params[:reason]
    case_number = params[:case_number]
    prod_right_guid = params[:group_product_right]
    license_guid = params[:license_guid]
    begin
      ls_api.product_right.remove_by_guid(:guid => prod_right_guid,
                                          :extra_audit_log_information => {"user_id"=>current_user.id,
                                                                           "user_name"=>current_user.user_name}.to_json
                                         ) if prod_right_guid
      UncapLearnerLog.create(:support_user_id => current_user.id,
          :case_number => case_number,
          :license_guid => license_guid,
          :reason => reason)
      flash[:notice] = "Learner has been uncapped successfully"
    rescue
      flash[:notice] = "Something went wrong. Please try again later."
    end
    redirect_to "/view_learner/#{license_guid}"
  end

  def handle_solo_pr_rights(solo_guid, family_learner = false, add_solo = false)
    #if learner is family learner and doesnt have solo rights,
    #first add solo into his available product rights then add solo rights
    if(family_learner && add_solo)
      license_details = ls_api.license.details(:guid => params[:license_guid])
      ls_api.creation_account.add_available_product(:creation_account_guid => license_details["creation_account_guid"],:product => params[:language],:version => "3", :family => "eschool_one_on_one_sessions",
                                                    :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
    end
    #this part adds the actual solo PR
    if add_solo
      added_pr_right = ls_api.license.add_product_right(:guid => params[:license_guid], :family => "eschool_one_on_one_sessions", :version => '3', :product => params[:language], :ends_at => Time.now.to_i,
                                                        :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
      solo_guid = added_pr_right["guid"]
    end
    solo_right = ls_api.product_right.details(:guid => solo_guid)
    ls_api.license.extend_product_right(:product_right_guid => solo_guid,:ends_at => (Time.now+20.years).to_i,
                                        :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json) if (((solo_right["ends_at"]-Time.now)/1.year) < 15)
    return solo_guid
  end

  def view_all_consumables
    render :partial => "support_user_portal/licenses/view_all_consumables", :locals => {:language => params[:language],:end_date => params[:end_date]}
  end

  def granted_additional_sessions
    render :partial => "support_user_portal/licenses/granted_additional_sessions",
      :locals => {:end_date => params[:end_date], :language => params[:language], :solo_expire_date => params[:solo_expire_date], :group_expire_date => params[:group_expire_date], :group_product_right => params[:group_product_right], :solo_product_right => params[:solo_product_right], :license_guid => params[:license_guid]}
  end

  def remove_learner_from_session
    session_time = params[:on].to_time
    learner_email = params[:email]
    level = params[:level]
    language = params[:language]
    village = params[:village]
    eschool_sessions = ExternalHandler::HandleSession.find_upcoming_sessions_for_language_and_levels_without_pagination(language, {:level_string => level, :start_date => session_time - 1.hour, :end_date => session_time + 1.hour, :page_num => 1, :village_ids => (village == "None" ? [] : [village]), :number_of_seats => (1..10).entries})
    eschool_session = eschool_sessions.eschool_sessions.detect {|session| (session.teacher == params[:coach] and session.start_time.to_time == session_time)}
    if eschool_session
      result_set = ExternalHandler::HandleSession.find_registered_and_unregistered_learners_for_session(TotaleLanguage.first, {:session_id => eschool_session.session_id, :class_id => eschool_session.eschool_class_id, :email => learner_email})
      attendance = result_set.attributes['attendances'].detect {|a| a.email == learner_email}
      result = ExternalHandler::HandleSession.remove_student_from_session(TotaleLanguage.first, {:attendance_id => attendance.attributes["attendance_id"]}) if attendance
      if result
        response = XmlSimple.xml_in(result.body, 'KeyAttr'=>'response')
        if response["status"][0] == 'OK'
          render :status => 200, :text => response["message"][0].capitalize
        else
          render :status => 405, :text => ERRORCodes[response["message"][0]] ? ERRORCodes[response["message"][0]].capitalize : response["message"][0].capitalize
        end
      else
        render :status => 500, :text => "Something went wrong, Please report this problem."
      end
    else
      render :status => 405, :text => "Couldn't find session."
    end
  end

  def licenses_hierarchy
    @prights = ls_api.license.product_rights(:guid => params[:license_guid])
    activation_ids = []
    @prights.each do |product_rights|
      product_rights["content_ranges"].each do |content_ranges|
        activation_ids << content_ranges["activation_id"] unless content_ranges["activation_id"].nil?
      end
    end
    activation_ids.uniq!
    learner_identifier_and_guids = []
    unless activation_ids.blank?
      all_rights = ls_api.multicall do
        activation_ids.each do |activation_id|
          product_right.find_by_activation_id(:activation_id => activation_id)
        end
      end
    end
    all_rights.each do |all_rights|
      all_rights[:response].each do |product_rights|
        learner = Learner.find_by_guid(product_rights["license"]["guid"])
        name  = learner.blank? ? "Unknown" : learner.name
        learner_identifier_and_guids << ["/view_learner/"+product_rights["license"]["guid"], product_rights["license"]["identifier"], product_rights["license"]["guid"], name]
      end
    end
    learner_identifier_and_guids.uniq!
    @family_tree = {
      params[:family_name] => learner_identifier_and_guids
    }
    render :template => "support_user_portal/licenses/license_hierarchy", :layout => false
  end

  def activate_deactivate_license
    begin
      if params[:active] == "false"
        response = ls_api.license.reactivate(:guid => params[:guid], :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
      elsif params[:active] == "true"
        response = ls_api.license.deactivate(:guid => params[:guid], :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
      end
      render :json => {:isSuccessful => response ? true : false}
    rescue Exception => e
      render :json => {:isSuccessful => false}
    end
  end

  #License Methods
  def ls_api
    RosettaStone::ActiveLicensing::Base.instance
  end

  def view_extension_details
    @license_guid       = params[:license_guid]
    @license_identifier = params[:license_identifier]
    @product_identifier = params[:language]
    @product_version    = params[:version]
    @pr_guid            = params[:pr_guid]
    @original_end_date  = params[:original_end_date]
    @group_guid = params[:group_guid]
    @enable_extensions = params[:enable_extension] == 'true' ? true : false

    begin
      @ext_details = []
      @ext_details = ls_api.product_right.extensions(:guid => @pr_guid)
    rescue Exception => ex
      redirect_to "/view_learner/#{params[:license_guid]}"
    end
    render :partial => 'view_extension_details'
  end

  def tosub_products(language_display_name, creation_account_type)
    (language_display_name != "REFLEX" && creation_account_type == "OSub") ? true : false
  end

  def view_access_log
    redirect_to :controller => "extranet/learners", :action => "show", :id => @learner.id, :view_access => "true"
  end

  def studio_history
    render :template  => "support_user_portal/learner_access_logs/learner_studio_history", :locals => {:student => @learner.studio_history}
  end


  def course_info_details
    @baffler_course_tracking_info = @learner.baffler_course_tracking_info(params[:lang])
    @baffler_path_scores = @learner.baffler_path_scores_for_language_and_level(params[:lang], params[:level])
    render :template => "support_user_portal/learner_access_logs/course_info_detail"
  end

  def community_audit_logs
    render :template  => "support_user_portal/learner_access_logs/community_learner_audit_log_history", :locals => { :audit_logs => @learner.community_learner_audit_logs }
  end

  def show_extension_form

    @license_guid        = params[:license_guid]
    @license_identifier  = params[:license_identifier]
    @product_identifier  = params[:language]
    @product_version     = params[:version]
    @pr_guid             = params[:pr_guid]
    @original_end_date   = params[:original_end_date]
    @group_guid          = params[:group_guid]
    @usable_extensions   = ls_api.product_right.extensions(:guid => @pr_guid).select{|ext| ext["extended_at"].blank?}.size
    @expired_license     = @original_end_date.to_time < Time.now
    render :template =>'/support_user_portal/licenses/extension_form', :layout => false

  end

  def add_or_remove_extension
    #need to get guid,type,claim_by(for now this is 1 year from current date),duration,reason,activation_id?
    #need to store current_user,license_identifier, reason,extension_guid,create & update- current time stamp
    #no need created by date- not used
    @license_guid = params[:license_guid]
    @product_identifier = params[:language]
    @product_version = params[:product_version]
    @license_identifier = params[:license_identifier]
    pr = ls_api.license.product_rights(:guid => @license_guid, :product => @product_identifier, :version =>  @product_version)
    solo_prights = pr.select{|p| p["product_family"] == "eschool_one_on_one_sessions"}.first
    @prights = pr.reject{|p| p["product_family"] == "eschool_one_on_one_sessions"}
    reason = (params[:reason] == "Other") ? params[:other_reason] : params[:reason]
    if params[:add_time] == "false"
      begin
        @prights.each do |pr|
            ext_to_burn = ls_api.product_right.extensions(:guid => pr["guid"]).select{|ext| ext["extended_at"].blank?}.sort_by{|ex| ex["created_at"]}
            count = (params[:remove_duration] == "All") ? ext_to_burn.size : params[:remove_duration].to_i
            durations_hash = {"d" => 0,"m" => 0}
            count.times do
              ls_api.extension.remove_by_guid(:guid => ext_to_burn.last["guid"],
                                              :extra_audit_log_information => {"user_id"=>current_user.id,
                                                                           "user_name"=>current_user.user_name}.to_json)
              removed_ext = ext_to_burn.pop
              durations_hash[removed_ext["duration"].last] += removed_ext["duration"][0..-2].to_i
            end
            duration  = "-" << ("#{durations_hash['m']}m" if durations_hash['m'] != 0 ).to_s << ("#{durations_hash['d']}d" if durations_hash['d'] != 0 ).to_s
            new_end_date_utc = pr["ends_at"].to_datetime - (durations_hash["m"].months + durations_hash["d"].days )
            if (params[:remove_duration] == "All")
              new_end_date_utc = Time.now.utc
              ls_api.license.extend_product_right(:guid => @license_guid, :product => @product_identifier, :version => @product_version, :family => pr["product_family"],:ends_at => new_end_date_utc.to_i,
                                                  :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
              duration = "-#{(pr["ends_at"].utc.to_date - Time.now.utc.to_date).to_i}d"
            end
            RightsExtensionLog.create(:support_user_id => current_user.id,
              :license_guid => @license_guid,
              :extendable_guid => pr["guid"],
              :reason => reason,
              :learner_id => @learner.id,
              :extendable_created_at => pr["created_at"].to_datetime,
              :extendable_ends_at    => pr["ends_at"].to_datetime,
              :action => 'REMOVE_RIGHTS',
              :duration => duration,
              :ticket_number => params[:ticket_number],
              :updated_extendable_ends_at => new_end_date_utc) if response
        end
        flash[:notice] = "Successfully removed the online rights."
        redirect_to "/view_learner/#{@license_guid}"
      rescue Exception => ex
        HoptoadNotifier.notify(ex)
        flash[:error] = "Sorry. Unable to remove online access. Please try again later."
        redirect_to "/view_learner/#{@license_guid}"
      end

    else
      begin
        flash[:notice] = ""
        flash[:error] = ""
        consumable_count = 0
        if solo_prights
          #handles and adds solo PR and extends date
          response = handle_solo_pr_rights(solo_prights["guid"])
          RightsExtensionLog.create(:support_user_id => current_user.id,
                :license_guid           => @license_guid,
                :extendable_guid        => solo_prights["guid"],
                :reason                 => reason,
                :learner_id             => @learner.id,
                :extendable_created_at  => solo_prights["created_at"].to_datetime,
                :extendable_ends_at     => solo_prights["ends_at"].to_datetime,
                :duration               => "20y",
                :ticket_number          => params[:ticket_number],
                :action                 => 'ADD_TIME') if response
        end
 #add solo consumables if required
        if (params[:solo_consumable_count] != "0" && @product_version != "1")
            solo_guid = solo_prights.try(:[],"guid")
            if !solo_guid
              license_details = ls_api.license.details(:guid => @license_guid)
              creation_account_details = ls_api.creation_account.details(:creation_account_guid => license_details["creation_account_guid"])
              solo_guid = handle_solo_pr_rights(nil,(creation_account_details["type"] == "family"),true)
            end
            added_consumable = ls_api.consumable.add(:pooler_type => "ProductRight", :pooler_guid => solo_guid, :count => params[:solo_consumable_count].to_i,
                                                     :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
            if added_consumable
              AddConsumableLog.create(:support_user_id => current_user.id,
                :license_guid => @license_guid,
                :reason => reason,
                :consumable_type => 'Solo',
                :case_number => params[:ticket_number],
                :action =>"Add",
                :number_of_sessions => params[:solo_consumable_count].to_i,
                :pooler_guid => solo_guid,
                :pooler_type => "ProductRight")
              flash[:notice] << "Solo consumables were added and "
            else
              flash[:error] << "Solo consumables could not be added. "
            end
        end
        #dealing with other prights
        group_consumable_count = params[:group_consumable_count].to_i
        # solo_consumable_count = params[:solo_consumable_count].to_i
        @prights.each do |pr|
            if(params[:add_duration].last == "d")
              response = ls_api.extension.add(:extendable_guid => pr["guid"], :extendable_type => "ProductRight", :duration => params[:add_duration], :claim_by => (Time.now + 3.years).to_i,
                                              :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
              if( pr["product_family"] == "eschool_group_sessions" && params[:group_consumable_count] != "0")
                consumables_response = ls_api.consumable.add(:remaining_rollover_count => 0, :pooler_guid => response["guid"],:pooler_type => "Extension",:count => params[:group_consumable_count].to_i, :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json) if (params[:group_consumable_count] != "0")
                consumable_count = params[:group_consumable_count].to_i
              end
            elsif(params[:add_duration].last == "m")
              extension_count = params[:add_duration][0..-2].to_i
              user_data = current_user
              response = ls_api.multicall do
                extension_count.times do
                  extension.add(:extendable_guid => pr["guid"], :extendable_type => "ProductRight", :duration => "1m", :claim_by => (Time.now + 3.years).to_i,
                                :extra_audit_log_information => {"user_id"=>user_data.id, "user_name"=>user_data.user_name}.to_json)
                end
              end
              added_extensions = response.collect{|s| s[:response]["guid"] }
              if ( pr["product_family"] == "eschool_group_sessions" && params[:group_consumable_count] != "0")
                consumables_response = ls_api.multicall do
                  added_extensions.each do |guid|
                    consumable.add(:remaining_rollover_count => 0, :pooler_guid => guid,:pooler_type => "Extension",:count => group_consumable_count,
                                    :extra_audit_log_information => {"user_id"=>user_data.id, "user_name"=>user_data.user_name}.to_json)
                  end
                end
                consumable_count = group_consumable_count*extension_count
              end
            end
            if consumables_response
                AddConsumableLog.create(:support_user_id => current_user.id,
                      :license_guid => @license_guid,
                      :reason => reason,
                      :consumable_type => 'Group',
                      :case_number => params[:ticket_number],
                      :action =>"Add",
                      :number_of_sessions => consumable_count,
                      :pooler_guid => pr["guid"],
                      :pooler_type => "Extension")
                flash[:notice] = (flash[:notice].empty? ? "Group consumables were added and " : "Consumables were added and ")
            elsif(pr["product_family"] == "eschool_group_sessions" && params[:group_consumable_count] != "0")
                flash[:error] << (flash[:error].empty? ? "Group consumables could not be added. " : "Consumables could not be added. ")
            end

            RightsExtensionLog.create(:support_user_id => current_user.id,
                  :license_guid           => @license_guid,
                  :extendable_guid        => pr["guid"],
                  :reason                 => reason,
                  :learner_id             => @learner.id,
                  :extendable_created_at  => pr["created_at"].to_datetime,
                  :extendable_ends_at     => pr["ends_at"].to_datetime,
                  :duration               => params[:add_duration],
                  :ticket_number          => params[:ticket_number],
                  :action                 => 'ADD_TIME') if response
        end
        flash[:notice] << (flash[:notice].empty? ? "T" : "t") + "ime extended successfully for the associated product rights."
        redirect_to "/view_learner/#{@license_guid}"
      rescue Exception => ex
        HoptoadNotifier.notify(ex)
        flash[:error] << "Unable to extend time. Please try again later."
        redirect_to "/view_learner/#{@license_guid}"
      end
    end
  end

  def reset_password
    if !params[:license_guid].nil? && !params[:password].nil?
      if !params[:license_guid].empty? && !params[:password].empty?
        begin
          response = ls_api.license.change_password(:guid => params[:license_guid], :password => params[:password],
                                                    :extra_audit_log_information => {"user_id"=>current_user.id, "user_name"=>current_user.user_name}.to_json)
          flash[:notice] = "Password Successfully Reset"  if response
        rescue Exception
          flash[:error]="Failed to reset password. Please try again later."
        end
        redirect_to "/view_learner/#{params[:license_guid]}"
      else
        flash[:error] = "New password should not be empty."
        redirect_to "/view_learner/#{params[:license_guid]}"
      end
    else
      render :template => "support_user_portal/licenses/reset_password_form", :layout => false
    end
  end

  def modify_language
    begin
      if request.post?
        product_rights_guids = []
        ls_api.license.product_rights(:guid => params[:license_guid]).each do |pr|
          product_rights_guids << pr["guid"] if pr["product_identifier"] == params[:previous_language] && pr["product_version"] == params[:version]
        end
        changed_product_rights_from_ls = license_server_language_switch(product_rights_guids, params[:changed_language] )
        error_notice_hash_result =   create_product_language_log(changed_product_rights_from_ls, product_rights_guids, params)
        flash[:error]  = error_notice_hash_result[:error]
        flash[:notice] = error_notice_hash_result[:notice]
        Eschool::Student.cancel_future_sessions(params[:license_guid], params[:previous_language]) if flash[:error].blank?
        redirect_to show_learner_profile_and_license_information_path(:license_guid => params[:license_guid])  and return
      end
    rescue RosettaStone::ActiveLicensing::CallException #A wrapper Exception from a multi-call. The original exception is available as an attribute.
      flash[:error] = "Product Identifier not updated in License Server."
      redirect_to show_learner_profile_and_license_information_path(:license_guid => params[:license_guid]) and return
    rescue Exception => ex
      HoptoadNotifier.notify(ex)
      flash[:error] = "Something went wrong. Not able to process langauge modify request."
      redirect_to show_learner_profile_and_license_information_path(:license_guid => params[:license_guid]) and return
    end
    render :partial => 'modify_language'
  end

  def license_server_language_switch(product_rights_guids_array, changed_language )
    user_data = current_user
    changed_product_rights = ls_api.multicall do
      product_rights_guids_array.each do |product_rights_guid|
        product_right.update_product_identifier(:guid => product_rights_guid, :new_product_identifier => changed_language,
                                                :extra_audit_log_information => {"user_id"=>user_data.id, "user_name"=>user_data.user_name}.to_json)
      end
    end
    changed_product_rights
  end

  def lcdb_language_switch(product_rights_guids_array, changed_language, learner_guid , previous_language)
    lcd_response = []
    product_rights_guids_array.each do | pr |
      lcd_response << lcdb_switch_language(pr,changed_language)
    end

    raise "Learner with guid : #{learner_guid} Has a conflict in LCDB. Old language : #{previous_language}. New language : #{changed_language}" if !lcd_response.select{ |a| a.returnCode=="-1"}.empty?
  end


  def create_product_language_log(changed_product_rights, product_rights_guids_array, params)
    previous_language = params[:previous_language]
    changed_language = params[:changed_language]
    reason = params[:reason]
    license_guid = params[:license_guid]

    changed_product_rights.each do |changed_product_right|
      changed_product_right_obj = changed_product_right[:response][0] #change it when they fix it .. they = LS devs
      prod_lang_log                     = ProductLanguageLog.new
      prod_lang_log.support_user_id     = current_user.id
      prod_lang_log.license_guid        = changed_product_right_obj["license"]["guid"]
      prod_lang_log.product_rights_guid = changed_product_right_obj["guid"]
      prod_lang_log.previous_language   = previous_language
      prod_lang_log.changed_language    = changed_product_right_obj["product_identifier"]
      prod_lang_log.reason              = reason
      #
      if prod_lang_log.valid?
        prod_lang_log.save!
        begin
          lcdb_language_switch(product_rights_guids_array,changed_language,license_guid,previous_language)
        rescue Exception => ex
          ex.message.concat("Learner with guid : #{license_guid} Has a conflict in LCDB. Old language : #{previous_language}. New language : #{changed_language}")
          HoptoadNotifier.notify(ex)
        end
        return {:error => nil, :notice => 'Language modified successfully.' }
      else
        return {:error => prod_lang_log.errors.full_messages, :notice => nil }
      end
    end
  end

  require 'csv'
  def mail_report
    if params[:start_date].to_date > Time.now.to_date || params[:end_date].to_date > Time.now.to_date
      flash[:error] = "Start Date and End date should not be in future."
    elsif params[:end_date].to_date < params[:start_date].to_date
      flash[:error] = "End date should not be lesser than the start date."
    else
      @results = RightsExtensionLog.find_extensions_between(params[:start_date],params[:end_date])
      report = StringIO.new
      CSV::Writer.generate(report, ',') do |title|
        title << ['Customer Name','Email','License guid','Product Right guid','Reason for Extension','Support User','Original Start Date','Original End Date','New End Date']
        @results.each do |r|
          original_end_date = (r["extendable_ends_at"] >= Time.now) ? r["extendable_ends_at"] : Time.now
          title << [r["CustomerName"],r["email"],r["license_guid"],r["extendable_guid"],r["reason"],r["SupportUserName"],r["extendable_created_at"].strftime("%Y-%m-%d %H:%M EST"),r["extendable_ends_at"].strftime("%Y-%m-%d %H:%M EST"),calculate_new_end_date(original_end_date,r["duration"]).strftime("%Y-%m-%d %H:%M EST")]
        end
      end
      report.rewind

      ReportMailer.internal_report(params[:start_date],params[:end_date], report).deliver
      flash[:notice] = "The report was successfully mailed to the distribution list."
    end
    redirect_to :report_search

  rescue Exception => ex
    flash[:error] = "Sorry. Unable to sent mail. Please try again later."
    redirect_to :report_search

  end
  require 'csv'

  def consumables_report
    @selected_type = "All"
    @user_time = TimeUtils.format_time(Time.now, "%A %b %d,%Y")
    from_time_utc = TimeUtils.time_in_user_zone(params[:from_date].to_i/1000).utc
    to_time_utc = TimeUtils.time_in_user_zone(params[:to_date].to_i/1000).utc + 1.day - 1.minute
    @all_products =[]
    if params[:form_request] == "true"
     type =  (params[:type] == "All" ? ["Solo","Group"] : [params[:type].to_s])
     @results = AddConsumableLog.find_logs_between(type, from_time_utc, to_time_utc)
     @results.each do |prod|
        each_product = {
          :date => TimeUtils.format_time(prod.created_at,"%m/%d/%y %I:%M %p"),
          :full_name => prod.full_name,
          :case_number => prod.case_number,
          :consumable_type => prod.consumable_type,
          :number_of_sessions => prod.number_of_sessions,
          :reason => prod.reason,
          :license_guid => prod.license_guid
        }
        @all_products << each_product
      end
      if request.get?
        report = File.new('/tmp/consumable_report.csv', 'w')
        CSV::Writer.generate(report, ',') do |title|
          title << ["Date","Added by","Case Number ","Type","Quantity","Reason","Customer License"]
          @all_products.each do |r|
            title << [r[:date],r[:full_name],r[:case_number],r[:consumable_type],r[:number_of_sessions],r[:reason],r[:license_guid]]
          end
        end
        report.close
        send_file("/tmp/consumable_report.csv", :type => "text/csv", :charset=>"utf-8")
      elsif request.post?
        @selected_type  = params[:type]
        @all_products.flatten!
        render(:update){|page| page.replace_html 'update_prod_report', :partial => "consumables_report_page"}
      end
    end
  end

  # Grandfathering Report
  def grandfathering_report
    @page_title = 'Grandfather Audit'
  end

  def get_grandfathering_report
    collect_grandfathering_report
    render(:update) { |page| page.replace_html 'update_prod_report', :partial => 'grandfathering_report_page' }
  end

  def download_grandfathering_report_csv
    collect_grandfathering_report
    file_path = '/tmp/Grandfather\ Audit.csv'
    UncapLearnerLog.generate_grandfathering_report(file_path, @grandfather_logs)
    send_file(file_path, :type => 'text/csv', :charset => 'utf-8')
  end

  def product_rights_modification_report
    @user_time = TimeUtils.format_time(Time.now, "%A %b %d,%Y")
    from_time_utc = TimeUtils.time_in_user_zone(params[:from_date].to_i/1000).utc
    to_time_utc = TimeUtils.time_in_user_zone(params[:to_date].to_i/1000).utc + 1.day - 1.minute
    @results = RightsExtensionLog.find_extensions_between(from_time_utc,to_time_utc,true)
    @all_products =[]
    type = params[:form_request]
    if type == "true"
      @results.each do |prod|
        if(prod.action=="ADD_TIME")
          original_end_date = prod.extendable_ends_at >= prod.created_at ? prod.extendable_ends_at : prod.created_at
          new_end_date = calculate_new_end_date(original_end_date.to_time.utc,prod.duration)
        elsif(prod.action=="REMOVE_RIGHTS")
          new_end_date = prod.updated_extendable_ends_at
        end
        each_product = {
          :support_user => prod.SupportUserName,
          :license_identifier => prod.email,
          :license_guid => prod.license_guid,
          :reason => prod.reason,
          :ticket_number => prod.ticket_number,
          :duration => prod.duration,
          :original_end_date => TimeUtils.format_time(prod.extendable_ends_at,"%m/%d/%y %I:%M %p"),
          :new_end_date => TimeUtils.format_time(new_end_date,"%m/%d/%y %I:%M %p"),
          :date_extended => TimeUtils.format_time(prod.created_at,"%m/%d/%y %I:%M %p")
        }
        @all_products << each_product
      end
      if request.get?
        report = File.new('/tmp/product_rights_extension_report.csv', 'w')
        CSV::Writer.generate(report, ',') do |title|
          title << ["Support User","License Identifier","License guid","Reason","Ticket Number","Duration","Original End Date","New End Date","Date Extended"]
          @all_products.each do |r|
            title << [r[:support_user],r[:license_identifier],r[:license_guid],r[:reason],r[:ticket_number],r[:duration],r[:original_end_date],r[:new_end_date],r[:date_extended]]
          end
        end
        report.close
        send_file("/tmp/product_rights_extension_report.csv", :type => "text/csv", :charset=>"utf-8")
      elsif request.post?
        @all_products.flatten!
        render(:update){|page| page.replace_html 'update_prod_report', :partial => "product_right_report_page"}
      end
    end
  end
  def cal_duration(durationd,extendable_ends_at)
    len = durationd.length
    type =durationd.slice(len-1,1)
    count=0;
    if type == 'm'
      count = durationd.slice(0,len - 1).to_i*30
      return count.to_s()+"d"
    elsif type == 'd'
      count = durationd.slice(0,len - 1).to_i
      return count.to_s()+"d"
    else
      date_orginal=Date.parse(extendable_ends_at.to_s)
      date_sent=Date.parse(durationd.to_s)
      return (date_sent-date_orginal).to_s()+"d"
    end
  end

  def end_date_calculation
    render :json => {"date" => calculate_new_end_date(params[:original_end_date].to_time.utc, params[:duration]).strftime("%m/%d/%Y") }
  end

  def remove_end_date_calculation
    durations_hash = {"d" => 0,"m" => 0}
    duration_array   = ls_api.product_right.extensions(:guid => params[:guid]).select{|ext| ext["extended_at"].blank?}.sort_by{|ex| ex["created_at"]}.collect{|s| s["duration"]}
    end_date = Time.now
    if params[:duration] != "All"
      duration_to_add = duration_array.last(params[:duration].to_i)
      duration_to_add.each{|s| durations_hash[s.last] += s[0..-2].to_i}
      end_date = params[:original_end_date].to_time.utc-(durations_hash["m"].months + durations_hash["d"].days)
    end
    duration_array.each{|s| durations_hash[s.last] += s[0..-2].to_i}
    render :json => {"date" => end_date.strftime("%m/%d/%Y")}
  end

  private

  def authenticate
    access_denied unless tier1_user_logged_in?
  end

  def calculate_new_end_date(end_date,duration)
    len = duration.length
    count = duration.slice(0,len - 1).to_i
    type =duration.slice(len-1,1)
    if type == 'm'
      return (end_date + count.month)
    elsif type == 'd'
      return (end_date + count.day)
    else
      return (Date.parse(duration.to_s));
    end
  end

  def get_product_language_logs(guid)
    ProductLanguageLog.find(:all, :conditions => ["product_rights_guid=?", guid],:order => 'updated_at DESC')
  end

  def create_consumables_array(extensions, is_old_learner, solo_product_right, group_product_right, group_starts_at, group_valid_through, solo_starts_at, solo_valid_through)
    consumables = []
    if extensions.blank?
      if group_product_right
        solo_count_default = solo_product_right ? 0 : "N/A"
        consumables << {
          :group => {:rolled_over => 0, :start_available => 0, :consumed => 0, :scheduled => 0, :currently_available => 0, :expires_at => ""},
          :solo => {:rolled_over => 0, :start_available => solo_count_default, :consumed => solo_count_default, :scheduled => solo_count_default, :currently_available => solo_count_default, :expires_at => (solo_product_right ? "" : "N/A")},
          :solo_product_right => solo_product_right, :group_product_right => group_product_right,
          :total => {:rolled_over => 0, :start_available => 0, :consumed => 0, :scheduled => 0, :currently_available => 0}, :guid => group_product_right,
          :show => true, :is_burned => false, :start => group_starts_at, :end => group_valid_through }
      elsif solo_product_right
        consumables << {
          :group => {:rolled_over => 0, :start_available => "N/A", :consumed => "N/A", :scheduled => "N/A", :currently_available => "N/A", :expires_at => "N/A"},
          :solo => {:rolled_over => 0, :start_available => 0, :consumed => 0, :scheduled => 0, :currently_available => 0, :expires_at => ""},
          :solo_product_right => solo_product_right, :group_product_right => group_product_right,
          :total => {:rolled_over => 0, :start_available => 0, :consumed => 0, :scheduled => 0, :currently_available => 0}, :guid => solo_product_right,
          :show => true, :is_burned => false, :start => solo_starts_at, :end => solo_valid_through }
      end
    else
      used_extensions = extensions.select {|ext| !ext['extended_at'].blank? }.sort_by {|ext| ext['extended_at']}
      current_extension = used_extensions.last
      used_extensions -= [current_extension]
      unused_extensions = (extensions - used_extensions).sort_by {|ext| ext['created_at']}
      group_count_default = is_old_learner ? "N/A" : 0
      solo_count_default = solo_product_right ? 0 : "N/A"
      used_extensions.each_with_index do |extension, i|
        consumables << {
          :group => {:start_available => group_count_default, :consumed => group_count_default, :rolled_over => group_count_default, :expires_at => (is_old_learner ? "N/A" : "")},
          :solo => {:start_available => solo_count_default, :consumed => solo_count_default, :rolled_over => solo_count_default, :expires_at => (solo_product_right ? "" : "N/A")},
          :total => {:start_available => 0, :consumed => 0, :rolled_over => 0},
          :solo_product_right => solo_product_right, :group_product_right => group_product_right,
          :show => false, :is_burned => true, :start => extension['extended_at'], :guid => extension['guid'],
          :end => (used_extensions[i+1] ? used_extensions[i+1]['extended_at'] : current_extension['extended_at']) }
      end
      start_of_current_extension = current_extension ? current_extension['extended_at'] : unused_extensions.first['created_at'] unless unused_extensions.blank?
      is_first = true
      unused_extensions.each do |extension|
        end_of_extension = calculate_new_end_date(start_of_current_extension, extension['duration'])
        end_of_extension = group_valid_through if group_valid_through and unused_extensions.size == 1 and end_of_extension != group_valid_through
        consumables << {
          :group => {:start_available => group_count_default, :consumed => group_count_default, :scheduled => group_count_default, :currently_available => group_count_default, :expires_at => (is_old_learner ? "N/A" : "")},
          :solo => {:start_available => solo_count_default, :consumed => solo_count_default, :scheduled => solo_count_default, :currently_available => solo_count_default, :expires_at => (solo_product_right ? "" : "N/A")},
          :solo_product_right => solo_product_right, :group_product_right => group_product_right,
          :total => {:start_available => 0, :consumed => 0, :scheduled => 0, :currently_available => 0}, :guid => extension['guid'],
          :show => is_first, :is_burned => false, :start => start_of_current_extension, :end => end_of_extension }
        start_of_current_extension = end_of_extension
        is_first = false
      end
    end
    consumables
  end

  def fetch_consumables(product_right_guid)
    consumables_array = ls_api.product_right.consumables(:product_right_guid => product_right_guid)
    consumables_guid_array = consumables_array.collect {|c| c["guid"]}
    projected_consumables_array = ls_api.product_right.projected_consumables(:product_right_guid => product_right_guid).reject {|c| consumables_guid_array.include? c["guid"] }
    projected_consumables_details = []
    projected_consumables_details = ls_api.multicall do
      projected_consumables_array.each do |c|
        consumable.details(:guid => c["guid"])
      end
    end unless projected_consumables_array.empty?
    consumables_array += projected_consumables_details.collect {|c| c[:response]}
  end

  def populate_product_guid_and_validity(cr_hash, product)
    if product["product_family"] == "application"
      cr_hash[:course_guid]        = product["guid"]
      cr_hash[:valid_through]      = product["unextended_ends_at"]
      cr_hash[:projected_through]  = product["ends_at"]
      cr_hash[:course_usable] = product["usable"]
    end

    if product["product_family"] == "eschool"
      cr_hash[:studio_guid]           = product["guid"]
      cr_hash[:sg_valid_through]      = product["unextended_ends_at"]
      cr_hash[:sg_projected_through]  = product["ends_at"]
      cr_hash[:flag] = (cr_hash[:flag] && product["usable"])
      cr_hash[:studio_usable] = product["usable"]
    end

    if product["product_family"] == "premium_community"
      cr_hash[:rworld_guid]           = product["guid"]
      cr_hash[:rg_valid_through]      = product["unextended_ends_at"]
      cr_hash[:rg_projected_through]  = product["ends_at"]
      cr_hash[:rworld_usable] = product["usable"]
    end

    if product["product_family"] == "eschool_one_on_one_sessions"
      cr_hash[:solo_guid]               = product["guid"]
      cr_hash[:solo_valid_through]      = product["unextended_ends_at"]
      cr_hash[:solo_projected_through]  = product["ends_at"]
      cr_hash[:solo_usable] = product["usable"]
    end

    if product["product_family"] == "eschool_group_sessions"
      cr_hash[:group_guid]            = product["guid"]
      cr_hash[:group_valid_through]      = product["unextended_ends_at"]
      cr_hash[:group_projected_through]  = product["ends_at"]
      cr_hash[:group_usable] = product["usable"]
    end

    if product["product_family"] == "language_switching"
      cr_hash[:language_switch_guid]  = product["guid"]
      cr_hash[:language_switch_valid_through]      = product["unextended_ends_at"]
      cr_hash[:language_switch_projected_through]  = product["ends_at"]
      cr_hash[:language_switch_usable] = product["usable"]
    end
  end

  def populate_consumables_count_for_solo_sessions(consumable_obj, consumables_array, upcoming_sessions, valid_through)
    consumables_array.each do |consumable|
      if consumable["consumed"]
        if consumable["consumed_at"] >= consumable_obj[:start] and consumable["consumed_at"] <= consumable_obj[:end]
          consumable_obj[:solo][:consumed] += 1
          consumable_obj[:total][:consumed] += 1
          consumable_obj[:solo][:start_available] += 1
          consumable_obj[:total][:start_available] += 1
        elsif consumable["consumed_at"] >= consumable_obj[:start]
          consumable_obj[:solo][:rolled_over] = consumable_obj[:solo][:rolled_over].to_i + 1
          consumable_obj[:total][:rolled_over] = consumable_obj[:total][:rolled_over].to_i + 1
          consumable_obj[:solo][:start_available] += 1
          consumable_obj[:total][:start_available] += 1
        end
      else
        if consumable_obj[:is_burned]
          consumable_obj[:solo][:rolled_over] += 1
          consumable_obj[:total][:rolled_over] += 1
          consumable_obj[:solo][:start_available] += 1
          consumable_obj[:total][:start_available] += 1
        else
          consumable_obj[:solo][:currently_available] += 1
          consumable_obj[:total][:currently_available] += 1
          consumable_obj[:solo][:start_available] += 1
          consumable_obj[:total][:start_available] += 1
        end
      end
    end
    upcoming_sessions.each do |session|
      if session.attributes["number_of_seats"].to_i == 1 and session.attributes["session_time"].utc >= consumable_obj[:start] and session.attributes["session_time"].utc < consumable_obj[:end]
        consumable_obj[:solo][:scheduled] += 1
        consumable_obj[:total][:scheduled] += 1
        consumable_obj[:solo][:currently_available] -= 1
        consumable_obj[:total][:currently_available] -= 1
      end
    end unless consumable_obj[:is_burned]
    consumable_obj[:solo][:expires_at] = valid_through.strftime("%m/%d/%Y") unless consumables_array.empty?
  end

  def populate_consumables_count_for_group_sessions(consumable_obj, consumables_array, upcoming_sessions)
    removable = []
    consumables_array.each do |consumable|
      if consumable["pooler"]["type"] == "ProductRight" && consumable_obj[:show]
        if consumable["usable"]
          consumable_obj[:group][:currently_available] += 1
          consumable_obj[:total][:currently_available] += 1
          removable << consumable
        elsif consumable["consumed"] and consumable["consumed_at"] >= consumable_obj[:start] and consumable["consumed_at"] <= consumable_obj[:end]
          consumable_obj[:group][:consumed] += 1
          consumable_obj[:total][:consumed] += 1
          removable << consumable
        end
      elsif consumable["pooler"]["type"] == "ProductRight" && consumable_obj[:is_burned] && !consumable_obj[:show]
        if consumable["expires_at"].try(:to_date) == consumable_obj[:end].try(:to_date)
          if consumable["consumed"]
            consumable_obj[:group][:consumed] += 1
            consumable_obj[:total][:consumed] += 1
          end
          removable << consumable
        end
      elsif consumable["pooler"]["guid"] == consumable_obj[:guid]
        consumable_obj[:group][:currently_available] += 1
        consumable_obj[:total][:currently_available] += 1
        removable << consumable
      end

    end
    consumable_obj[:group][:start_available] = removable.size
    consumable_obj[:total][:start_available] = removable.size

    consumables_array - removable
  end

  def fetch_session_details_of_learner(product_right, upcoming_sessions, consumables)
    consumables_array = fetch_consumables(product_right["guid"])
    if product_right["product_family"] == "eschool_one_on_one_sessions"
      consumables.each do |c|
        populate_consumables_count_for_solo_sessions(c, consumables_array, upcoming_sessions, product_right["ends_at"])
      end
      can_take_solo_from = product_right['starts_at'] if consumables.find {|c| c[:solo][:currently_available].to_i > 0}
    else
      consumables.each do |c|
        consumables_array = populate_consumables_count_for_group_sessions(c, consumables_array, upcoming_sessions)
        upcoming_sessions.each do |session|
          if session.attributes["number_of_seats"].to_i > 1 and session.attributes["session_time"].utc >= c[:start] and session.attributes["session_time"].utc < c[:end]
            c[:group][:scheduled] += 1
            c[:total][:scheduled] += 1
            c[:group][:currently_available] -= 1
            c[:total][:currently_available] -= 1
          end
        end unless c[:is_burned]
        c[:group][:expires_at] = c[:end].strftime("%m/%d/%Y")
      end
      e = consumables.find {|c| c[:group][:currently_available].to_i > 0}
      can_take_group_from = e[:start] if e
    end
    [consumables, can_take_solo_from, can_take_group_from]
  end

  def collect_grandfathering_report
    from_time_utc = TimeUtils.time_in_user_zone(params[:from_date].to_i/1000).utc
    to_time_utc = TimeUtils.time_in_user_zone(params[:to_date].to_i/1000).utc + 1.day - 1.minute
    @grandfather_logs = UncapLearnerLog.includes(:account).between(from_time_utc, to_time_utc)
  end

end
