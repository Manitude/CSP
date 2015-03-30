# this file loads ruby gems bundled inside the project.
if !defined?(Gem)
  bundled_rubygems_path = File.expand_path('../../vendor/gems/rubygems-update-1.3.7/lib', __FILE__)

  $LOAD_PATH.unshift(bundled_rubygems_path)
  ENV['RUBYOPT'] = "-I#{bundled_rubygems_path} #{ENV['RUBYOPT']}"
  ENV['GEM_HOME'] = File.expand_path("../../vendor", __FILE__)
  ENV['GEM_PATH'] = File.expand_path("../../vendor", __FILE__)

  require 'rubygems'
end
