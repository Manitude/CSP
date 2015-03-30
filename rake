#!/usr/bin/env ruby

begin  
  $:.unshift File.join(File.dirname(__FILE__), "vendor", "local", "rake-0.9.5", "lib")
  require 'rake'
rescue LoadError
  puts "Please add rake to vendor/rake. We don't want to use a system Gem"
end
Rake.application.run