# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module InflectorExtensions
    def decontrollerize
      gsub(/Controller$/, '')
    end

    def controllerize
      camelize.decontrollerize + 'Controller'
    end
  end
end

String.send(:include, RosettaStone::InflectorExtensions)

