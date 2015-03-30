%w[
  ssl_functionality
  action_controller_ext
].each do |lib|
  require File.join(File.dirname(__FILE__), 'lib', lib)
end

if Rails.test?
  require File.join(File.dirname(__FILE__), 'lib', 'test', 'test_unit_ext')
end