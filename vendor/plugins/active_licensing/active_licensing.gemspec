# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "active_licensing"
  s.version     = "1.0.0"
  s.authors     = ["OPX"]
  s.email       = ["RSPlatforms@rosettastone.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby interface to the license server}
  s.description = %q{Ruby interface to the license server}

  s.add_dependency('i18n')
  s.add_dependency('activesupport')
  s.add_dependency('simple-http')
  s.add_dependency('xml-simple')

  s.require_paths = ["lib"]
end
