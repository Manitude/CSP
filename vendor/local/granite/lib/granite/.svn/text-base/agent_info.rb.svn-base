class Granite::AgentInfo
  attr_accessor :count, :max

  def initialize(initial_count = 1, max_count = nil)
    @count = initial_count
    @max = max_count ||= @count
    raise(ArgumentError.new("Count should be an integer.  Was `#{@count.inspect}`")) unless @count.is_a?(Fixnum)
    raise(ArgumentError.new("Max should be an integer.  Was `#{@max.inspect}`")) unless @max.is_a?(Fixnum)
  end
end
