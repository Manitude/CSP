# this file loads rosettastone_tools rails extensions for
# Rails 2 apps (when rosettastone_tools is loaded as a plugin).
if defined? Rails
  require 'rosettastone_tools/rails_extensions'
end

if defined?(CASClient)
  require 'casclient/rosettastone_modifications'
end

require 'rosetta_stone/disable_buffered_logging_for_non_web_server_contexts'

# old Rails (like 2.0) doesn't add app subdirectories in plugins to the load path
Dependencies.load_paths << File.join(File.dirname(__FILE__), '..', '..', 'app', 'controllers') if defined?(Dependencies)
