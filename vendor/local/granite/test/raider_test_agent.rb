# Simple agent to test raider with
class RaiderTestAgent < Granite::BaseAgent
  def process(header, message)
    raise 'Fake error to exercise RAIDER'
  end
end
