# A superclass that handles all of the configuration for you.  All you have to do is
#  class MyGraniteAgent < Granite::BaseTopicAgent
#   
#   def process(header, event_hash)
#     # .. my awesome code
#   end
#   
# end
#
# MyGraniteAgent.publish({'my' => 'message'})
#
class Granite::BaseTopicAgent < Granite::BaseAgent
  
  EXCHANGE_NAME = "base_topic_agent_exchange"
  
  class Producer < Granite::Producer
    self.exchange_options = self.exchange_options.merge(:type => :topic)
    self.set_exchange(EXCHANGE_NAME)
  end
  
  def self.publish(event_hash)
    Producer.publish(event_hash, publish_options)
  end
  
  def self.publish_options
    {:key => routing_key}
  end
  
  def self.later(identifier, scheduled_time, event_hash)
    Granite::Later.schedule(
      "#{self.name}:#{identifier}", 
      scheduled_time, 
      Producer, 
      event_hash, 
      publish_options
    )
  end
  
  def self.routing_key
    "#{self.name}-routing_key"
  end

  def initialize # :nodoc:
    agentize({
      :method => self.method(:process).to_proc,
      :queue => queue,
      :exchanges => exchanges,
      :type => type,
      :bindings => bindings,
    })
  end

  private
  def bindings
    [{:key => "#.#{self.class.routing_key}.#"}]
  end

  private
  def queue
    { :name => queue_name, :auto_delete => false, :durable => true, :exclusive => false }
  end

  private
  def exchanges
    [EXCHANGE_NAME]
  end

  private
  def type
    :topic
  end
  
end