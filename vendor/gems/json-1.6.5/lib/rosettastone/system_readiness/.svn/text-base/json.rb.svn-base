require 'rosetta_stone/system_readiness'

class SystemReadiness::Json < SystemReadiness::Base
  class << self
    def verify
      JSON
      return false, "JSON::Pure is loaded... not using the C library? (Fix this by running './compile_native_library.rb' from the json vendor/gems directory)" if defined?(JSON::Pure)
      return false, "JSON::Ext.constants is empty... C library not loaded? (Fix this by running './compile_native_library.rb' from the json vendor/gems directory)" if JSON::Ext.constants.empty?
      return JSON.parse({'test' => true}.to_json)['test'], ''
    rescue Exception => e
      return false, "failed: #{e.message}"
    end
  end
end
