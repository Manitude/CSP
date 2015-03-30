# This module allows you to schedule messages for later publication to granite using Granite::Later.schedule. LaterMessages
#  are persisted in your app until their scheduled time rolls around, at which point they are
#  pulled out of the persisted store and published to granite.  If a message that has been scheduled
#  for later needs to be cancelled, use Granite::Later.unschedule.  If the scheduled time needs to 
#  change, call Granite::Later.schedule again with the same identifier.
#
# Overdue LaterMessages will be published when you run the rake task granite:publish_overdue_later_messages.
#  It is recommended that you setup a cronjob to call that task every so often (Locos does it every minute):
#  
#  */1 * * * * cd $LOCOS_PRODUCTION_RAILS_ROOT && RAILS_ENV=production ./rake --silent granite:publish_overdue_later_messages > /dev/null 2>&1
module Granite::Later
  
  # Arguments:
  #  identifier(String) - a unique identifier for your message.  Any later schedule calls with the same identifier
  #               will update this later_message rather than creating a new one
  #  scheduled_time(Time) - the time at which the message should be published to granite
  #  producer(subclass of Granite::Producer) - the producer that should be used to publish the message
  #  message(Hash) - the message that should be published
  #  publish_options(Hash) - options to be passed into the Producer.publish call
  def self.schedule(identifier, scheduled_time, producer, message, publish_options = {})
    active_klass.schedule(identifier, scheduled_time.utc, producer.name, message.to_json, publish_options.to_json)
  end
  
  def self.unschedule(identifier)
    active_klass.unschedule(identifier)
  end
  
  def self.publish_overdue_messages
    i = 0
    active_klass.each_overdue_message do |later_message|
      i += 1
      later_message.publish
      unschedule(later_message.identifier)
    end
    return i
  end
  
  def self.active_klass
    if Granite::Configuration.later_implementation == "active_record"
      raise "ActiveRecord is not yet supported"
    elsif Granite::Configuration.later_implementation == "mongo_mapper"
      Granite::Later::MongoMapperLaterMessage
    else
      nil
    end
  end  
  
end