# -*- encoding : utf-8 -*-
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../../../config/environment', File.dirname(__FILE__)) unless defined?(RAILS_ROOT)

begin
  require 'mocha/setup' # mocha 0.13+
rescue MissingSourceFile
  require 'mocha' # older versions
end

class Test::Unit::TestCase

  def with_utc_timezone(&block)
    old_tz = ENV['TZ']
    ENV['TZ'] = 'UTC'
    yield
  ensure
    ENV['TZ'] = old_tz
  end

end

