if ENV['PROFILE'] == "true"
	require 'fileutils'
  FileUtils.rm_rf('tmp/prof') if File.exists?('tmp/prof')
  require 'middleware/request_profiler'
  m = Rails::Application.config.app_middleware
  m.insert_after(ActiveRecord::QueryCache, RequestProfiler)
end