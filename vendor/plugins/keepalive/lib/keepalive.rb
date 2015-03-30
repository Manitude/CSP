require 'ipaddr'
require 'rosettastone_tools'

module RosettaStone
  module KeepAlive
    autoload :KeepaliveController, 'keepalive_controller'
  end
end
autoload :KeepaliveController, 'keepalive_controller'

require 'pulse_checker/base'
require 'pulse_checker/active_record'
