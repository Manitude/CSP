# -*- encoding: utf-8 -*-
# 
# GEM DEVELOPMENT NOTE:
#
# Loading rosettastone_tools as a gem is not 100% equivalent to loading it as a plugin.
#
# When loaded as a plugin in Rails 2, Rails does a few things:
#  * adds lib into the autoload path
#  * requires init.rb
#  * a lot more
#
# When loaded as a gem in Rails 3 (the preferred method of use in Rails 3), this happens:
#  * adds lib into the ruby require path `$:`
#    * files still have to be manually required
#  * requires lib/rosettastone_tools.rb
#
Gem::Specification.new do |s|
  s.name        = "rosettastone_tools"
  s.version     = "1.0.0"
  s.authors     = ["OPX"]
  s.email       = ["RSPlatforms@rosettastone.com"]
  s.homepage    = ""
  s.summary     = %q{Utilities shared across OPX apps}
  s.description = %q{Utilities shared across OPX apps}

  s.add_dependency('i18n')
  s.add_dependency('activesupport')
  s.add_dependency('mocha')

  s.files = Dir['Rakefile', '{lib,test,doc}/**/*', 'README']
  s.require_paths = ["lib"]
end
