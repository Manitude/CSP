
class CspControllerAgent < Granite::BaseAgent
  self.connection = Rails.env
  exchange_name 'coachportal_controller'
  # routing_key '#'
  queue_params :auto_delete => false, :durable => false, :exclusive => false


  def process(header, message)
  end

  def use_raider(exchange)
    false
  end

end