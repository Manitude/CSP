namespace :db_cleanup do
  desc "Delete unwanted coaches from staging database"
  task :delete_coaches => :environment do    
    begin
      coach_name_list = File.readlines('tmp/coach_list.txt')
      coach_name_list.each_with_index do |coach_name, i|
        coach = Coach.find_by_user_name(coach_name.strip)
        if coach
          eschool_session_ids_for_coach = CoachSession.where("coach_id = #{coach.id} and session_start_time >= '2013-03-01 05:00:00'").map(&:eschool_session_id).compact
          Eschool::Session.bulk_cancel(eschool_session_ids_for_coach)
          c = coach.destroy
        else
          puts "Coach not found : #{coach_name}"
        end
        puts "#{i} coaches deleted" if ((i+1)%100 == 0)
      end
      puts "#{coach_name_list.size} coaches deleted"
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
  end
end