class CoachAggregator
  def initialize
    @coaches = Hash.new { |h,k| h[k] = []}
  end
  def add(activity)
    return false unless activity.is_a? ReflexActivity
    @coaches[activity.coach_id] << activity
    true
  end

  def parse(start_time, end_time)
    coach_result = []
    @coaches.each do |key, value|
      coach_result << CoachActivityParser.new(key,start_time, end_time).parse(value)
    end
    coach_result
  end

  def size
    @coaches.size
  end

  def for(coach_id)
    @coaches[coach_id]
  end
end
