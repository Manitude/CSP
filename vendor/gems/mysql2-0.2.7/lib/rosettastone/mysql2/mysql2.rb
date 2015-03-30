
succeeded = false
Dir.glob(File.expand_path("#{RUBY_PLATFORM}/#{RUBY_VERSION}/**/mysql2.*", File.dirname(__FILE__))).each do |binary|
  begin
    next if succeeded
    require binary
    #Rails.logger.info("Successfully loaded #{binary}")
    succeeded = true
  rescue LoadError => load_error
    #Rails.logger.error("Failed to load #{binary}, there may be others to try.  #{load_error}")
  end
end

raise "Failed to load mysql2 binary for your platform.  Run compile_native_library.rb." unless succeeded

begin
  require 'rosetta_stone/system_readiness'
  require 'system_readiness/mysql2_configuration'
rescue LoadError
  # no worries, allow this gem to load in places where rosettastone_tools isn't loaded (like user_activity)
end
