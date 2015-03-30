# -*- encoding: utf-8 -*-
$:.push File.expand_path(".", __FILE__)

Gem::Specification.new do |s|
  s.name        = "lagomorphic"
  s.version     = "1.0.0"
  s.authors     = ["OPX"]
  s.email       = ["RSPlatforms@rosettastone.com"]
  s.homepage    = ""
  s.summary     = %q{Lagomorphic plugin}
  s.description = %q{Lagomorphic is a Rosetta Stone gem/plugin to provide shared functionality for integrating with RabbitMQ.}

  s.add_dependency('activesupport')
  s.add_dependency('rosettastone_tools')
  s.add_dependency('json')
  
  s.require_paths = ['lib']
end
