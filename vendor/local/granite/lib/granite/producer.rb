# lame, but this doesn't get auto-required in 2.x it seems
require 'active_support/version'

class Granite::Producer < Rabbit::Producer
  if ActiveSupport::VERSION::MAJOR < 3
    before_publish :convert_message_to_job
    class_inheritable_accessor :raise_publish_exceptions
  else
    set_callback :publish, :convert_message_to_job
    class_attribute :raise_publish_exceptions
  end

  self.raise_publish_exceptions = false

  def convert_message_to_job
    @message = Granite::Job.create(@message)
  end
  
  def publish(*args)
    begin
      super
    rescue Rabbit::Error => publish_exception
      if klass.raise_publish_exceptions
        raise
      else
        RosettaStone::GenericExceptionNotifier.deliver_exception_notification(publish_exception)
        logger.error(%Q['#{klass}' exception in publish: '#{publish_exception}'])
        false
      end
    end
  end

end
