# -*- encoding : utf-8 -*-
module NumericPredicates

  def even?
    return self % 2 == 0
  end

  def odd?
    return self % 2 == 1
  end

  def negative?
    self < 0
  end

  def positive?
    !negative?
  end

end

class Integer
  include NumericPredicates
end

class Float
  include NumericPredicates
end
