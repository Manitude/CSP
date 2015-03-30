# -*- encoding : utf-8 -*-
#Basically, this is a class that is not loaded by default but would be loaded
#by rails autoloading
class NonLoadedClass
  attr_accessor :name

  def initialize(name_in)
    self.name = name_in
  end

end
