module Eschool
  class LotusSession < Base

    METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION = [:waiting_students, :average_wait_time_seconds,:matched_students,:longest_wait_time]
    
    def self.custom_method_collection_url(method_name, options = {})
      prefix_options, query_options = split_options(options)
      if METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION.include?(method_name)
        "/api/student_queue/#{method_name}#{query_string(query_options)}"
      else
        "#{prefix(prefix_options)}#{collection_name}/#{method_name}.#{format.extension}#{query_string(query_options)}"
      end
    end

    def self.waiting_students
      within_eschool_rescuer do
        #find(:one, :from => "/api/student_queue/waiting_students", :params => {:student_queue => {:language_identifier => "KLE"}} )
        self.prefix = "/api/student_queue"
        get :waiting_students
      end
    end

    def self.average_learners_waiting_time_sec
      within_eschool_rescuer do
        #find(:one, :from => "/api/student_queue/average_wait_time_seconds", :params => {:student_queue => {:language_identifier => "KLE", :enqueued_after_datetime_utc => time}} )
        self.prefix = "/api/student_queue"
        get :average_wait_time_seconds
      end
    end

    def self.longest_waiting_time
      within_eschool_rescuer do
        #find(:one, :from => "/api/student_queue/longest_wait_time"
        self.prefix = "/api/student_queue"
        get :longest_wait_time
      end
    end

  end
end
