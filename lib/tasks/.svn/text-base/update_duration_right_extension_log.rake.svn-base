namespace :update do
  desc "update duration field in rights_extension_logs "
  task :update_duration_in_right_extension_logs => :environment do
    begin
      total_no_of_records = RightsExtensionLog.count
      count = 0
      RightsExtensionLog.find_in_batches(:batch_size => 250) do |extension_log|
      extension_log.each do |ext|
        if(ext.action=="ADD_TIME")
          original_end_date = ext.extendable_ends_at >= ext.created_at ? ext.extendable_ends_at : ext.created_at
          new_end_date = ext.duration ? ActiveSupport::TimeZone['UTC'].parse(ext.duration) : nil
          duration_details = new_end_date ? cal_duration(new_end_date.to_s,original_end_date) : "NA"
          ext.update_attribute(:duration,duration_details)
        elsif(ext.action=="REMOVE_RIGHTS")
          duration_details = cal_duration(ext.updated_extendable_ends_at .to_s,ext.extendable_ends_at)
          ext.update_attribute(:duration,duration_details)
        end
      end
      count+=extension_log.size
      puts "#{count} has been updated out of #{total_no_of_records} at time #{Time.now}."
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

private

def cal_duration(durationd,extendable_ends_at)
  len = durationd.length
  type =durationd.slice(len-1,1)
  count=0;
  if type == 'm'
    count = durationd.slice(0,len - 1).to_i*30
    return count.to_s()+"d"
  elsif type == 'd'
    count = durationd.slice(0,len - 1).to_i
    return count.to_s()+"d"
  else
    date_orginal=Date.parse(extendable_ends_at.to_s)
    date_sent=Date.parse(durationd.to_s)
    return (date_sent-date_orginal).to_s()+"d"
  end
end