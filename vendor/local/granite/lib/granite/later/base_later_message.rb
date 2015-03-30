class Granite::Later::BaseLaterMessage
  
  def publish
    producer.publish(
      ActiveSupport::JSON.decode(message), 
      ActiveSupport::JSON.decode(publish_options).symbolize_keys
    )
  end
  
  def producer
    @producer ||= producer_klass_name.constantize
  end
  
end