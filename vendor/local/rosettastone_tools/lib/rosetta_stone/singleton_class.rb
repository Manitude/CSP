# -*- encoding : utf-8 -*-
# Rails 2.3.8+ deprecates Object#metaclass in favor of Object#singleton_class
# This file allows singleton_class to be used with prior versions.
#
# This file is only necessary for Rails < 2.3.6 and can be removed once all
# apps are beyond that version.
unless Object.respond_to?(:singleton_class)
  class Object
    # Returns the object's singleton class.
    def singleton_class
      class << self
        self
      end
    end

    # class_eval on an object
    def class_eval(*args, &block)
      singleton_class.class_eval(*args, &block)
    end
  end
end

# Now also support metaclass and metaclass_eval for backwards compatibility (deprecated)
class Object
  # Rails 2.0.x doesn't seem to have Object#metaclass
  alias_method :metaclass, :singleton_class unless respond_to?(:metaclass)
  # This one is a RosettaStone invention
  alias_method :metaclass_eval, :singleton_class_eval unless respond_to?(:metaclass_eval)
end
