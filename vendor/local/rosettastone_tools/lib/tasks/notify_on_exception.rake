require File.join(File.dirname(__FILE__), '..','rosetta_stone', 'rake_task_ext')

desc "Put this as a prereq on a task to make any generated exceptions get sent to the exception notifier of choice"
task :notify_on_exception do
  Rake::Task.send(:include, RosettaStone::RakeExceptionNotificationExtensions)
end
