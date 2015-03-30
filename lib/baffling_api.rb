module BafflingApi
  class GuidNotSpecified < StandardError; end
  include BafflingApiUser

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, CommonMethods
    base.extend ClassMethods
    base.extend CommonMethods
  end

  module ClassMethods
    def recently_expired_or_created_licenses(since, untill = Time.now.utc)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.recently_expired_or_created_licenses(since, untill)["identifier"] || []
      end
    end


    def recently_updated_license_identifiers(last_processed_id)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.recently_updated_license_identifiers(last_processed_id)
      end
    end
  end

  module InstanceMethods
    def baffler_course_tracking_info(language = nil)

      interact_with_baffler_api_client do
        language ||= self.baffler_most_recent_rs3_language_code
        return nil if language.nil?
        RosettaStone::Baffling::ApiClient.new.tracking_course_info(self.guid, language)
      end

     end

     def user_game_history(page)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.user_game_history(self.guid,page)
      end
     end

    def user_interactions(page)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.user_interactions(self.guid,page)
      end
    end

    def user_invite_history(page)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.user_invite_history(self.guid,page)
      end
    end

     def chat_history(page)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.chat_history(self.guid,page)
      end
     end

     def selected_learner_chat_history(page, number_of_records, start_date, end_date, conversation_type)
       interact_with_baffler_api_client do
        Baffling::ApiClient.new.selected_learner_chat_history(self.guid, page, number_of_records, start_date, end_date, conversation_type)
       end
     end

     def detailed_chat_history(page, number_of_records, start_date, end_date, message_id)
       interact_with_baffler_api_client do
        Baffling::ApiClient.new.detailed_chat_history(self.guid, page, number_of_records, start_date, end_date, message_id)
       end
     end

    def baffler_path_scores_for_language_and_level(language, level)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.path_scores_for_language_and_level(self.guid, language, level)
      end
    end

    def baffler_details(language = nil)
      interact_with_baffler_api_client do
        language ||= self.baffler_most_recent_rs3_language_code
        self.baffler_data(language)
      end
    end

    def baffler_time_spent_on_languages
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.time_spent_on_languages(self.guid)
      end
    end

    #Gives the count of acquaintances
    def acquaintances_count
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.acquaintances(self.guid).size
      end
    end

    def studio_ping_times_summaries(user_id, user_type, eschool_session_ids)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.studio_ping_times_summaries(user_id, user_type, eschool_session_ids)
      end
    end

    def community_user_roles
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.community_user_roles(self.guid)
      end
    end

    def studio_ping_times_summaries_for_eschool_session(eschool_session_id, user_ids)
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.studio_ping_times_summaries_for_eschool_session(eschool_session_id, user_ids)
      end
    end

    def community_learner_audit_logs
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.community_learner_audit_logs(self.guid)
      end
    end

    def baffler_social_app_languages
      interact_with_baffler_api_client do
        RosettaStone::Baffling::ApiClient.new.social_app_languages(self.guid)
      end
    end

  end

  module CommonMethods
    private
    #Resuces the RunTimeerror due to method not implemented
    def interact_with_baffler_api_client
      begin
        #raise GuidNotSpecified if self.guid.blank?
        yield
        #rescue GuidNotSpecified
        #Rails.logger.debug "Guid is not specified. So not going to baffler."
        # return nil
      rescue Exception => e
        #Rails.logger.debug "Method #{caller.first} not implemented"
        Rails.logger.debug e.backtrace.join("\n")
        return nil
      end
    end
  end

end
