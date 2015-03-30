# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "uniform_notifier/version"

Gem::Specification.new do |s|
  s.name        = "uniform_notifier"
  s.version     = UniformNotifier::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Huang"]
  s.email       = ["flyerhzm@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/uniform_notifier"
  s.summary     = %q{uniform notifier for rails logger, customized logger, javascript alert, javascript console, growl and xmpp}
  s.description = %q{uniform notifier for rails logger, customized logger, javascript alert, javascript console, growl and xmpp}

  s.rubyforge_project = "uniform_notifier"

  s.add_development_dependency "ruby-growl", "3.0"
  s.add_development_dependency "ruby_gntp", "0.3.4"
  s.add_development_dependency "xmpp4r", "0.5"
  s.add_development_dependency "rspec"

  s.files         = Dir.glob("{lib}/**/*")
  s.test_files    = Dir.glob("{test, spec, features}/**/*")
  s.executables   = Dir.glob("{bin}/**/*")
  s.require_paths = ["lib"]
end
