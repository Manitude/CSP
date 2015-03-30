require 'active_support'

module RosettaStone
  module KeepAlive
    class RouteModifier
      cattr_accessor :keepalive_route, :route_block_starter
      self.keepalive_route = "map.keepalive '/keepalive', :controller => 'keepalive', :action => 'index'"
      self.route_block_starter = /ActionController::Routing::Routes.draw(\s+)?do(\s+)?\|map\|(.*)?\n/
      
      def initialize(route_file_path)
        check_file_path(route_file_path)
        @route_file_path = route_file_path
      end
      
      def unmodified_route_file
        @route_file_contents ||= File.read(@route_file_path)
      end
      
      def modified_route_file
        @modified_routes ||= modify_route_file_contents
      end
      
      def save!
        File.open(@route_file_path, 'w') { |route_file| route_file << modified_route_file }
      end
      
      def revert!
        File.open(@route_file_path, 'w') { |route_file| route_file << unmodified_route_file }
      end
      
    private
      
      def check_file_path(route_file_path)
        return true if File.exist?(route_file_path) && File.writable?(route_file_path)
        raise "\nI either can't find or can't write to your routes.rb file. To make this plugin work, add a route like this manually:\n\n  #{keepalive_route}\n\n" +
              "It should likely be defined before the rest of your routes."
      end
      
      def modify_route_file_contents
        md = unmodified_route_file.match(route_block_starter)
        if md && route_starter = md[0]
          insert_keepalive_route(unmodified_route_file, route_starter)
        else
          raise "For some reason, I can't tell where to add the route in your routes file. Please add this route by hand:\n\n  #{keepalive_route}\n"
        end
      end
      
      def insert_keepalive_route(route_file_contents, route_starter)
        route_file_contents.sub(route_starter, "#{route_starter}  #{keepalive_route}\n")
      end
      
    end # RouteModifier
  end   # KeepAlive
end     # RosettaStone
    