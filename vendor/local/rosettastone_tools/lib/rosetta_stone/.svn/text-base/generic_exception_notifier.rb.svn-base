# -*- encoding : utf-8 -*-
if defined?(ExceptionNotifier) && (!defined?(RosettaStone::GenericExceptionNotifier) || RosettaStone::GenericExceptionNotifier.superclass == ExceptionNotifier)
  module RosettaStone
    class GenericExceptionNotifier < ExceptionNotifier
  
      delegate :email_prefix, :to => superclass
      delegate :sender_address, :to => superclass
      delegate :exception_recipients, :to => superclass
  
      class << self
        # Use this to test this notifier in the console, or in automated tests.
        def test_exception
          raise Exception, "this is just to provide an exception and a backtrace"
        rescue Exception => e
          return e
        end
  
        # use this method if you don't already have an exception in hand but you want to deliver an exception email
        def generate_exception_notification(message = "A detailed message was not provided.  You might want to fix that.")
          raise Exception, message
        rescue Exception => e
          deliver_exception_notification(e)
        end
      end
  
      def exception_notification(exception)
        clean_backtrace = sanitize_backtrace(exception.backtrace)
  
        subject_string = "#{email_prefix} #{exception.class}: #{exception.message.inspect}"
        subject_string = subject_string[0...subject_truncate_length] + '...' if subject_truncate_length && subject_string.length > subject_truncate_length
        subject(subject_string)
  
        from(sender_address)
        recipients(exception_recipients)
  
        email_body = %Q[
    Exception class '#{exception.class}' occurred at #{Time.now.to_s}:
  
      #{exception.message}
      #{clean_backtrace.first}
  
    #{header('Backtrace')}
    #{clean_backtrace.join("\n")}
        ]
  
        body(email_body)
      end
  
    private
      def header(text)
        (['-'*40 + "\n"]*2).join(text + ":\n")
      end
  
    end
  end
elsif defined?(HoptoadNotifier)
  module RosettaStone
    class GenericExceptionNotifier
      class << self
        # use this method if you don't already have an exception in hand but you want to deliver an exception email
        def generate_exception_notification(message = "A detailed message was not provided.  You might want to fix that.")
          raise Exception, message
        rescue Exception => e
          HoptoadNotifier.notify(e)
        end
  
        def deliver_exception_notification(e, options = {})
          HoptoadNotifier.notify(e, options)
        end
      end
    end
  end
elsif defined?(Airbrake)
  module RosettaStone
    class GenericExceptionNotifier
      class << self
        # use this method if you don't already have an exception in hand but you want to deliver an exception email
        def generate_exception_notification(message = "A detailed message was not provided.  You might want to fix that.")
          raise Exception, message
        rescue Exception => e
          Airbrake.notify(e)
        end
  
        def deliver_exception_notification(e, options = {})
          Airbrake.notify(e, options)
        end
      end
    end
  end
else # you have nothing in this app?  ok we'll just log it
  module RosettaStone
    class GenericExceptionNotifier
      class << self
        include RosettaStone::PrefixedLogger

        # use this method if you don't already have an exception in hand but you want to deliver an exception email
        def generate_exception_notification(message = "A detailed message was not provided.  You might want to fix that.")
          logger.error(message)
        end
  
        def deliver_exception_notification(e, options = {})
          logger.error(e.inspect)
        end
      end
    end
  end
end
