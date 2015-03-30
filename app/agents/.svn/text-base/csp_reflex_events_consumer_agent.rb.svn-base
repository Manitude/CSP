require File.expand_path('../../utils/reflex_activity_utils', __FILE__)

class CspReflexEventsConsumerAgent < Granite::BaseAgent
  include ReflexActivityUtils
  self.connection = "locos_#{Rails.env}"
  exchange_name '/eve/event'
  exchange_type :topic
  routing_key '#'
  queue_params :auto_delete => false, :durable => false, :exclusive => false


  def process(header, message)
    if ACCEPTABLE_FOLLOWERS.values.flatten.uniq.include? message['matching_event_type']
      time = Time.at(message['timestamp']/1000).utc
      ReflexActivity.create(:coach_id => message['user_guid'], :timestamp => time, :event => message['matching_event_type'])
    end
  end

  def use_raider(exchange)
    false
  end

end
