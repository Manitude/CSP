# More complex agent to test raider with
class RaiderTestAgent2 < Granite::BaseAgent
  def initialize(conn = nil, exchange = nil)
    klass.connection = conn + "_#{Framework.env}"
    @exchange = exchange
    super()
  end

  def process(header, message)
    raise 'Fake error to exercise RAIDER'
  end

  private
  def exchange_names
    if @exchange.nil?
      super
    else
      @exchange
    end
  end

end
