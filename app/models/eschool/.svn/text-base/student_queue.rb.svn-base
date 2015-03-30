module Eschool
  class StudentQueue < JsonBase

    METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION = [:waiting_detail]
      
    def self.custom_method_collection_url(method_name, options = {})
      prefix_options, query_options = split_options(options)
      if METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION.include?(method_name)
        "/api/student_queue/#{method_name}#{query_string(query_options)}"
      else
        "#{prefix(prefix_options)}#{collection_name}/#{method_name}.#{format.extension}#{query_string(query_options)}"
      end
    end
    
    def self.learners_waiting_details
      within_eschool_rescuer do
        #find(:all, :from => "/api/student_queue/waiting_detail")
        self.prefix = "/api/student_queue"
        get :waiting_detail
      end
    end
    
  end
end
