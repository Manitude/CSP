class Unit

  class << self
    def options
      UNITS_COLLECTION.collect { |unit| [unit, unit] }
    end
  end

end
