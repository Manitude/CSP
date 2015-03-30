namespace :clean do
  desc "Delete all the audit_log_records and user_actions records older than one year from database."
  task :audit_log_records_and_user_actions_records => :environment do
    Cronjob.mutex('audit_log_records_and_user_actions_records') do
        begin
          one_year_old_date = (Time.now - 1.year).utc.to_s(:db)
          connection = ActiveRecord::Base.connection

          connection.execute("delete from audit_log_records where created_at <= '#{one_year_old_date}';")
          puts "Deleted all Audit Log Records older than one year."
           
          connection.execute("delete from user_actions where created_at <= '#{one_year_old_date}';")
          puts "Deleted all User Actions records older than one year."
        rescue Exception => ex
          HoptoadNotifier.notify(ex)
        end
    end  
  end
end
