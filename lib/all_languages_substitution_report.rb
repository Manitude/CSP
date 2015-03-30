require 'csv'
class AllLanguagesSubstitutionReport < Struct.new(:current_user_id, :start_param, :end_param, :language_id, :requested_by_coach, :grabbed_by_coach, :duration, :grabbed_within)
  
  def perform
    lang = (language_id == "") ? "All" : Language.find_by_id(language_id).display_name
    coach_manager = CoachManager.find_by_id(current_user_id)
    substitutions = ManagerPortalController.new.substitutions_report_query_method(language_id, requested_by_coach, duration, start_param, end_param, grabbed_by_coach, grabbed_within,'csv')
    sub_details = ManagerPortalController.new.process_substitutions(substitutions)
    report_location = "/tmp/substitutions_report_delayed_job.csv"
    report = File.new(report_location, 'w')
    CSV::Writer.generate(report , ',') do |title|
      title << ['Level','Unit','Village', 'Learners?','Session/Shift Date','Request made','Grabbed on','Requested by','Picked up by','Left Open(in minutes)','Reason']
      sub_details.each do |r|
        title << [r[:level],r[:unit],r[:village],r[:learners_signed_up],r[:subsitution_date],r[:created_at],r[:grabbed_at],r[:coach],r[:grabber_coach],r[:grabbed_within],r[:reason]]
      end
    end
    report.close
    GeneralMailer.send_all_languages_substitution_reports(coach_manager, report_location, start_param, end_param, lang, requested_by_coach, grabbed_by_coach, duration).deliver
  end

end