# -*- encoding : utf-8 -*-
class Module

  def changing_constant(constant, value, &block)
    initial_value = send(:remove_const, constant)
    const_set(constant, value)
    block.call
    send(:remove_const, constant)
  ensure
    send(:remove_const, constant) if const_defined?(constant)
    const_set(constant, initial_value)
  end

end
