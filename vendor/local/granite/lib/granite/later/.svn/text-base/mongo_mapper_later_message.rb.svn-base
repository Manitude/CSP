class Granite::Later::MongoMapperLaterMessage < Granite::Later::BaseLaterMessage
  include MongoMapper::Document
  include MongoMapper::StrictKeys
  
  required_key :identifier, String
  required_key :scheduled_time, Time
  required_key :message, String #json
  required_key :publish_options, String #json
  required_key :producer_klass_name, String
    
  def self.schedule(identifier, scheduled_time, producer_klass_name, message, publish_options = {})
    collection.update({
      'identifier' => identifier
    }, {
      '$set' => {
        'scheduled_time' => scheduled_time,
        'message' => message,
        'producer_klass_name' => producer_klass_name,
        'publish_options' => publish_options
      }      
    },{
      :upsert => true,
      :safe => true
    })
  end
  
  def self.unschedule(identifier)
    collection.remove({
      'identifier' => identifier
    })
  end
  
  def self.each_overdue_message(&block)
    find_each({
      'scheduled_time' => {'$lt' => Time.now},
      :timeout => false,
      :sort => 'scheduled_time asc'
    }) do |message|
      yield(message)
    end
  end
  
end