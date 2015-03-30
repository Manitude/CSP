module RosettaStone
  module Baffling
    class ApiClientError < SimpleHTTP::ApiClient::ApiClientError; end

    class AccessDeniedException < ApiClientError; end
    class MissingLanguageException < ApiClientError; end

    class UnknownGuidException < ApiClientError; end
    class MissingLevelException < ApiClientError; end
    class CurriculumUnitNotFoundException < ApiClientError; end
    class MissingOrInvalidDateSpecifiedException < ApiClientError; end
    class NewAndUpdatedBothUnspecifiedException < ApiClientError; end
    class UnableToParseExceptionDetailsException < ApiClientError; end

    class ApiClient < SimpleHTTP::ApiClient
      def ping 
        baffling_api_get("/api/baffling/ping") 
      end
      
      def details(guid, language_code)
        baffling_api_get("/api/baffling/details/#{guid}/#{language_code}")
      end

      def user_game_history(guid,page=1)
        baffling_api_get("/api/baffling/user_game_history/#{guid}?page=#{page}")
      end

      def user_interactions(guid,page=1)
        baffling_api_get("/api/baffling/user_interactions/#{guid}?page=#{page}")
      end

      def chat_history(guid,page=1)
        baffling_api_get("/api/baffling/user_chat_logs/#{guid}?page=#{page}")
      end

      def user_invite_history(guid,page=1)
        baffling_api_get("/api/baffling/user_invitation_history/#{guid}?page=#{page}")
      end

      def most_recent_rs3_language(guid)
        baffling_api_get("/api/baffling/most_recent_rs3_language/#{guid}")
      end

      def acquaintances(guid)
        # forcearray is needed so the response is the same no matter how many users
        response = baffling_api_get("/api/baffling/acquaintances/#{guid}", "user")
        return [] unless response && response["user"]

        undo_bad_effects_of_forcearray(response["user"])
      rescue UnknownGuidException
        []
      end

      def tracking_course_info(guid, language_code)
        baffling_api_get("/api/baffling/tracking_course_info/#{guid}/#{language_code}")
      end

      def path_scores_for_language_and_level(guid, language_code, level)
        baffling_api_get("/api/baffling/path_scores_for_language_and_level/#{guid}/#{language_code}/#{level}")
      end

      def time_spent_on_languages(guid)
        baffling_api_get("/api/baffling/time_on_languages/#{guid}")
      end

      def studio_ping_times_summaries(user_id, user_type, eschool_session_ids)
        query_params = "user_id=#{user_id}&user_type=#{user_type}&eschool_session_ids=#{eschool_session_ids.join(",")}"
        baffling_api_get("/api/baffling/studio_ping_times_summaries?#{query_params}", ["studio_ping_time_summary"])
      end

      def studio_ping_times_summaries_for_eschool_session(eschool_session_id, user_ids)
        params = "eschool_session_id=#{eschool_session_id}&user_ids=#{user_ids.join(",")}"
        baffling_api_get("/api/baffling/studio_ping_times_summaries_for_eschool_session?#{params}", ["studio_ping_time_summary"])
      end

      def recently_modified_profiles(time_from, time_to, new, updated )
        time_from = CGI::escape(time_from)
        time_to = CGI::escape(time_to)
        query_params = []

        query_params << "new=true" if new
        query_params << "updated=true" if updated

        response = baffling_api_get("/api/baffling/recently_modified_profiles/#{time_from}/#{time_to}?#{query_params.join('&')}", "user")
        return [] unless response && response["user"]

        undo_bad_effects_of_forcearray(response["user"])
      end

      def recently_expired_or_created_licenses(since, untill)
        since, untill = CGI::escape(since.to_s), CGI::escape(untill.to_s)
        response = baffling_api_get("/api/baffling/recently_expired_or_created_licenses?since=#{since}&untill=#{untill}", "identifier")
        response.delete_if { |key,value| key ==  "content" } #To delete the content key from the resultant has to keep the test clean
      end

      def recently_updated_license_identifiers(last_processed_audit_log_record_id)
        response = baffling_api_get("/api/baffling/recently_updated_license_identifiers?last_processed_audit_log_record_id=#{last_processed_audit_log_record_id}", "guid")
        response.delete_if { |key,value| key ==  "content" } #To delete the content key from the resultant has to keep the test clean
      end

      def community_learner_signin_history(guid, limit = nil)
        response = baffling_api_get("/api/baffling/community_learner_signin_history/#{guid}?limit=#{limit}", "signin")["signin"] || []
        undo_bad_effects_of_forcearray(response)
      end

      def community_user_roles(guid)
        response = baffling_api_get("/api/baffling/community_user_roles/#{guid}", "role")
        return [] unless response && response["role"]

        undo_bad_effects_of_forcearray(response["role"])
      end

      def community_learner_audit_logs(guid)
        response = baffling_api_get("/api/baffling/community_learner_audit_log/#{guid}", "log_record")
        return [] unless response && response["log_record"]

        undo_bad_effects_of_forcearray(response["log_record"])
      end

      def community_user_badges(guid)
        response = baffling_api_get("/api/baffling/community_user_badges/#{guid}", "badge")["badge"] || []
        undo_bad_effects_of_forcearray(response)
      end

      def social_app_languages(guid)
        baffling_api_get("/api/baffling/social_app_languages/#{guid}", "language")["language"] || []
      end

    private
      def baffling_api_get(url, forcearray = false, max_attempts = 3)
        attempt = 1
        begin
          response = nil
          begin
            response = request_with_retry { get(url) }
          rescue SimpleHTTP::ApiClient::ApiClientError => e
            Rails.logger.error("#{e.class}: #{e}")
            raise ApiClientError, e.to_s
          end

          if response.status == '200'
            XmlSimple.xml_in(response.body, 'forcearray' => forcearray, 'suppressempty' => nil)
          else
            raise_appropriate_exception(response)
          end
        rescue UnableToParseExceptionDetailsException => exception
          Rails.logger.error("#{klass}: Got unexpected response from baffler. (attempt #{attempt}), retrying: #{exception.class}: #{exception.message}")
          attempt += 1
          retry unless attempt > max_attempts
          exception_message = "#{klass}: Got #{exception.class} multiple times (max attempts: #{max_attempts}). Giving up."
          Rails.logger.error(exception_message)
          raise exception, exception_message
        end
      end

      def raise_appropriate_exception(response)
        exception_class = ApiClientError

        result = nil
        begin
          result = XmlSimple.xml_in(response.body, 'forcearray' => false, 'suppressempty' => nil, 'KeepRoot' => true)
        rescue ArgumentError => exception
          # result will remain nil if we get an ArgumentError parsing the xml
          exception_class = UnableToParseExceptionDetailsException          
        end

        if (result && (ex = result['exception']) && ex['class'] && ex['content'])
          begin
            exception_class = ('RosettaStone::Baffling::' + ex['class'].demodulize).constantize
          rescue NameError => e
            Rails.logger.error("#{e.class}: #{e}: Got error trying to find a matching baffling client exception for #{ex['class']}")
          end
        end

        Rails.logger.error("Received response with status of '#{response.status}': #{response.body}")
        raise exception_class, "Received response with status of '#{response.status}': #{response.body}"
      end

      def undo_bad_effects_of_forcearray(response)
        response.map do |entity|
          entity.each do |key, value|
            entity[key] = value.first
          end
          OpenStruct.new(entity)
        end
      end

    end
  end
end
