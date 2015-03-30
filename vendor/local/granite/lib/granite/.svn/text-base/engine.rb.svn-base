# Include hook code here
module Granite 
  class Engine < Rails::Engine
    initializer 'granite.autoload_agents', :before => :set_autoload_paths do |app|
      Dir.glob(Framework.root.join('**', 'app', 'agents')).each do |dir|
        app.config.autoload_paths << dir
      end
    end
  end
end
