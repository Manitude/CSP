# -*- encoding: utf-8 -*-
$:.push File.expand_path(".", __FILE__)

Gem::Specification.new do |s|
  s.name        = "granite"
  s.version     = "1.0.0"
  s.authors     = ["OPX"]
  s.email       = ["RSPlatforms@rosettastone.com"]
  s.homepage    = ""
  s.summary     = %q{Granite plugin}
  s.description = %q{Granite plugin}

  s.add_dependency('activesupport')
  s.add_dependency('lagomorphic')
  s.add_dependency('uuidtools')
  s.add_dependency('rosettastone_tools')
  
  s.require_paths = ['lib']
end
