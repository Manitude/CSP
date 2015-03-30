# this file loads rosettastone_tools rails extensions for
# Rails 3 apps (when rosettastone_tools is loaded as a gem).
require 'rosettastone_tools/rails_extensions'

module RosettastoneTools
  class Engine < Rails::Engine
    initializer "rails extensions to be loaded after initialization" do
      if defined?(CASClient)
        require 'casclient/rosettastone_modifications'
      end
      require 'rosetta_stone/disable_buffered_logging_for_non_web_server_contexts'
      require 'rosettastone_tools/shared_hotfixes/remote_ip_resolution_fix'
    end
  end
end
