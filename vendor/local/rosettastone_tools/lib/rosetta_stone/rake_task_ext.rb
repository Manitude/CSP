#This patches Rake to Growl the result of a rake test
if RUBY_PLATFORM.downcase.include?("darwin")
  module RosettaStone
    module RakeTestApplicationExtensions

      def self.included(klass)
        klass.send(:include, InstanceMethods)
        klass.send(:alias_method_chain, :invoke_task, :growl_notify)
      end

      module InstanceMethods
        #Capture the result of a rake task invocation and the growl the result
        def invoke_task_with_growl_notify(task_string)
          name, args = parse_task_string(task_string)
          if name.match(/^test/) || name == 'default'
            #We run both scripts because Growl is the name of the program to talk to for the latest
            #growl, but older growls talked to GrowlHelperApp. So dumb.
            ['growl_notifier.applescript','growl_helper_app_notifier.applescript'].each do |script_name|
              growl_command = [
                "osascript",
                File.join(File.dirname(__FILE__),'..','..','bin',script_name),
                name
              ]
              begin
                require 'open3'
                invoke_task_without_growl_notify(task_string)
                growl_command << "0" #To signify success
              rescue Exception => e
                growl_command << "1" #To signify that it wasn't successful
                growl_command << e.to_s #Will print as part of the description
                raise e
              ensure
                begin
                  #Basically, we want to ignore whatever output may come from this. This is because
                  #at least one of these commands is going to throw a syntax error to stderr
                  stdin, stdout, stderr = Open3.popen3(*growl_command)
                rescue Exception => who_cares
                  #You shouldn't get here, but may as well catch it.
                end
              end
            end
          else
            invoke_task_without_growl_notify(task_string)
          end
        end
      end
    end
  end

  Rake::Application.send(:include, RosettaStone::RakeTestApplicationExtensions)
end

#When this module is included in Rake::Task, any exceptions thrown will be sent to Hoptoad
#or your exception notifier of choice
module RosettaStone
  module RakeExceptionNotificationExtensions
    def self.included(klass)
      if defined?(RosettaStone::GenericExceptionNotifier)
        klass.send(:include, InstanceMethods)
        klass.send(:alias_method_chain, :execute, :exception_notify) unless klass.method_defined?(:execute_without_exception_notify)
      end
    end

    module InstanceMethods
      def execute_with_exception_notify(task_string)
        execute_without_exception_notify(task_string)
      rescue Exception => error_to_report
        RosettaStone::GenericExceptionNotifier.deliver_exception_notification(error_to_report)
        raise error_to_report
      end
    end
  end
end
