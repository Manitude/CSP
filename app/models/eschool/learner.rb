module Eschool
  class Learner < Base

    METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION = [:eschool_sessions_studio_summary]

    def self.sessions_summary(guid_or_id)
      within_eschool_rescuer do
        response = get :eschool_sessions_studio_summary, :id => guid_or_id
        response["future_sessions"].flatten!
        Eschool::Learner.new(response)
      end
    end

    def self.studio_history(guid_or_id)
      within_eschool_rescuer do
        find(:one, :from => "/api/students/#{guid_or_id}/studio_history")
      end
    end

    def self.custom_method_collection_url(method_name, options = {})
      if METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION.include?(method_name)
        "/api/se/students/#{options[:id]}/#{method_name}"
      else
        prefix_options, query_options = split_options(options)
        "#{prefix(prefix_options)}#{collection_name}/#{method_name}.#{format.extension}#{query_string(query_options)}"
      end
    end
  end

end
