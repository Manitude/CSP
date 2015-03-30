namespace :update do
  desc "update daylight_diff field in coach availability"
  task :daylight_diff => :environment do
    begin
      condition = "daylight_diff is null"
      total_no_of_records = CoachAvailability.count(:conditions => condition)
      count = 0
      CoachAvailability.find_in_batches(:conditions => condition,:batch_size => 250) do |coach_availability|
      coach_availability.each do |availability|
        if availability.created_at.in_time_zone('Eastern Time (US & Canada)').dst?
            availability.update_attribute(:daylight_diff,3600);
        else
            availability.update_attribute(:daylight_diff,0);
        end
      end
      count+=coach_availability.size
      puts "#{count} has been updated out of #{total_no_of_records}."
      end
      #ActiveRecord::Base.connection.execute(" Alter table coach_availabilities modify daylight_diff integer not null")
      if(count==total_no_of_records)
        puts "updated succcessfully."
      end
    rescue Exception => e
     puts "There was an Exception #{e.message}."
    end
  end
end
