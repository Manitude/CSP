ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../../../config/environment', File.dirname(__FILE__)) unless defined?(RAILS_ROOT)

# seems to be necessary to get Rails 2.0 (OLLCs) to load the right test classes
if Rails.version < '3'
  require 'test_help'
else
  require 'rails/test_help'
end
