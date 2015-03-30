# this will require config/environment and load entire rails environment 
require File.expand_path(File.dirname(__FILE__) + "/environment")
set :job_template, nil

first_run, second_run = GlobalSetting.get_run_timings

every "#{first_run},#{second_run} * * * *" do
  command "cd /usr/website/coachportal/current && RAILS_ENV=production ./bundle exec ./rake ccs:send_email_if_coach_not_present --only_one_rake --silent"
end
