module ActsAsInterface

  def self.included(target)
    target.extend(ActsAsInterfaceClassMethods)
  end

  class MissingInterfaceMethod < Exception

    def initialize(superclass, subclass, class_or_instance, meth)
      @subclass = subclass
      @superclass = superclass
      @meth = meth
      @class_or_instance = class_or_instance
    end

    def message
      "Classes descending from #{@superclass.name} should define #{@class_or_instance} method #{@meth.to_s}. #{@subclass.name} does not."
    end

  end

end

module ActsAsInterfaceClassMethods
  def interface_instance_methods(meths)
    superclass = self
    meths.each do |interface_method|
      define_method(interface_method) do |*args|
        raise ActsAsInterface::MissingInterfaceMethod.new(superclass, self.class, :instance, interface_method.to_s)
      end
    end
  end

  def interface_class_methods(meths)
    superclass = self
    (class << self; self; end).instance_eval do
      meths.each do |interface_method|
        define_method(interface_method) do |*args|
          raise ActsAsInterface::MissingInterfaceMethod.new(superclass, self, :class, interface_method.to_s)
        end
      end
    end
  end
end