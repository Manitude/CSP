module Eschool
  class CoachCurrentStatus < JsonBase

    METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION = [:current_statuses]

    def self.custom_method_collection_url(method_name, options = {})
      prefix_options, query_options = split_options(options)
      if METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION.include?(method_name)
          "/api/teacher_status/#{method_name}#{query_string(query_options)}"
      else
        "#{prefix(prefix_options)}#{collection_name}/#{method_name}.#{format.extension}#{query_string(query_options)}"
      end
    end


    def self.current_statuses
      within_eschool_rescuer do
        self.prefix = "/api/teacher_status"
        get :current_statuses
      end
    end

  end
end
