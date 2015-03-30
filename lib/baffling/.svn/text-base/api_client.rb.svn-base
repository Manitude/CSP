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

    def selected_learner_chat_history(guid, page, number_of_records, start_date, end_date, conversation_type)
      baffling_api_get("/api/baffling/selected_learner_chat_history/#{guid}?page=#{page}&number_of_records=#{number_of_records}&start_date=#{start_date}&end_date=#{end_date}&conversation_type=#{conversation_type}")
    end

    def detailed_chat_history(guid, page, number_of_records, start_date, end_date, message_id)
      baffling_api_get("/api/baffling/detailed_chat_history/#{guid}?page=#{page}&number_of_records=#{number_of_records}&start_date=#{start_date}&end_date=#{end_date}&message_id=#{message_id}")
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
          my_json = response.body
          XmlSimple.xml_in(JSON.parse(my_json).to_xml(:root => :my_root), 'forcearray' => forcearray, 'suppressempty' => nil)
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
  end
end