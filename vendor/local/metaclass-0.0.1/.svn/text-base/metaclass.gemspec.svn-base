# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "metaclass/version"

Gem::Specification.new do |s|
  s.name        = "metaclass"
  s.version     = Metaclass::VERSION
  s.authors     = ["James Mead"]
  s.email       = ["james@floehopper.org"]
  s.homepage    = "http://github.com/floehopper/metaclass"
  s.summary     = %q{Adds a metaclass method to all Ruby objects}

  s.rubyforge_project = "metaclass"

  s.files         =  Dir.glob("{lib}/**/*")  
  s.test_files    =  Dir.glob("{test}/**/*")
  s.executables   =  s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
