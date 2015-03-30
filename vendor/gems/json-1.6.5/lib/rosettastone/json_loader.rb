# Loading this file as optional.  I recommend adding it to the config.gem line
# in environment.rb, like:
#   config.gem 'json', :lib => 'rosettastone/json_loader'
# Alternately, you can require it from a file in config/initializers, like:
#   require 'rosettastone/json_loader'
#
# This file configures the JSON Gem to be the ActiveSupport::JSON backend.
# It also loads a system_readiness check.

# this line requires json, which loads parser(.rb) and generator(.rb)
ActiveSupport::JSON.backend = 'JSONGem' if defined?(ActiveSupport::JSON)

require File.join(File.dirname(__FILE__), 'system_readiness', 'json')
