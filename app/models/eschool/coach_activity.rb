module Eschool
  class CoachActivity < JsonBase
    
    #Eschool::CoachActivity.activity_report_for_coaches([1,2,3],'2012-01-11 12:12:12', '2012-02-11 12:12:12', ['ARA'])
    def self.activity_report_for_coaches(ids,start_time,end_time,lang_identifier)
      within_eschool_rescuer do
        self.prefix = "/api/cs/activity_report_for_coaches"
        self.element_name = "" 
        result = post :coach_details, nil, {:ids => ids,:start_time => start_time, :end_time => end_time, :lang_identifier => lang_identifier}.to_json
        ActiveSupport::JSON.decode(result.response.body)
      end
    end
    
  end
end
