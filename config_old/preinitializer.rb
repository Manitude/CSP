#Default to prod.
ENV['RAILS_ENV'] ||= 'development'
lib = File.expand_path(File.join(::Rails.root.to_s, "vendor", "home_run", "lib"))
$:.unshift lib
$:.unshift File.join(lib, "rosettastone")
# Because rubygems loads date classes
require 'home_run'

# load rubygems, rack from vendor
require File.expand_path('../rubygems_boot', __FILE__)
$:.unshift File.join(::Rails.root.to_s, "vendor", "local", "bundler-1.2.0", "lib")

begin
  require "bundler"
rescue LoadError
  raise "Could not load the bundler gem. Install it with `gem install bundler`."
end

if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.24")
  raise RuntimeError, "Your bundler version is too old." +
   "Run `gem install bundler` to upgrade."
end


