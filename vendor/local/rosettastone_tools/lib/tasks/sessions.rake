# Copyright:: Copyright (c) 2006 Rosetta Stone
# License:: All rights reserved.

# A handful of session-related utility tasks
namespace :sessions do

  # There should be a cron job entry that invokes this task.  See (typically) config/crontab. 
  desc "Expire old sessions from the sessions table.  Optionally override limit=50000 and session_expiry_timeout_in_seconds=X"
  task :expire => [:environment, :notify_on_exception] do
    age_in_seconds =
      if ENV['session_expiry_timeout_in_seconds']
        ENV['session_expiry_timeout_in_seconds'].to_i
      elsif defined? OVERRIDE_SESSION_EXPIRY_TIME
        OVERRIDE_SESSION_EXPIRY_TIME
      elsif defined? SECONDS_BEFORE_SESSION_TIMEOUT
        # don't delete sessions until they are 1.5X older than the session timeout, for good measure
        (SECONDS_BEFORE_SESSION_TIMEOUT * 1.5).to_i
      else
        # default to a day
        60 * 60 * 24
      end
    limit = ENV['limit'].if_hot(&:to_i) || 20000
    sql = %Q[delete from #{sessions_table} where updated_at < date_sub(now(), interval #{age_in_seconds} second) order by id asc limit #{limit}]
    num_deleted = 0
    time = Benchmark.measure do
      num_deleted = ActiveRecord::Base.connection.delete(sql)
    end
    logger.info("#{Time.now.to_s :db} - sessions:expire: deleted #{num_deleted.to_s} old sessions (query took #{'%.4fs' % time.real})")
  end

  desc "Delete all sessions from the database table"
  task :clear => :environment do
    sql = %Q[delete from #{sessions_table}]
    num_deleted = ActiveRecord::Base.connection.delete(sql)
    puts "#{num_deleted.to_s} sessions deleted"
  end

  desc "Number of active sessions"
  task :active => :environment do
    sql = %Q[select count(*) from #{sessions_table} where updated_at > date_sub(now(), interval 40 minute)]
    active = ActiveRecord::Base.connection.select_value(sql)
    puts active + " active sessions"
  end

  desc "Total number of sessions in the sessions table"
  task :count => :environment do
    sql = %Q[select count(*) from #{sessions_table}]
    total = ActiveRecord::Base.connection.select_value(sql)
    puts total + " total sessions"  
  end

  def sessions_table
    if Rails.version >= "2.3"
      ActiveRecord::SessionStore::Session.table_name
    else
      CGI::Session::ActiveRecordStore::Session.table_name
    end
  end
end