begin
  require "rosettastone/date_ext/#{RUBY_PLATFORM}/#{RUBY_VERSION}/date_ext"
  #require "date_ext"
rescue LoadError
  raise unless RUBY_PLATFORM =~ /mswin|mingw/
  require "#{RUBY_VERSION[0...3]}/date_ext"
end
require "date/format" unless defined?(Date::Format::ZONES)
