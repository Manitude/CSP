# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# Tries to determine whether the current process is running in the context of a web server
# (e.g. Passenger or mod_fcgid) or as a rake task or Rails console by looking at the program
# name.
module RosettaStone
  module ExecutionContext
    class << self

      def is_web_server?
        is_mod_fcgid? || is_passenger?
      end

      def is_passenger?
        # example: "Passenger ApplicationSpawner: /usr/website/baffler/current"
        process_name.starts_with?('Passenger')
      end

      def is_mod_fcgid?
        # example: "/usr/website/app_launcher/current/public/dispatch.fcgi"
        process_name.ends_with?('dispatch.fcgi')
      end

      def is_rake?
        !!((/\brake\b/).match(process_name))
      end

      def is_irb?
        !!((/\birb\b/).match(process_name))
      end

    private

      def process_name
        $0.to_s
      end

    end
  end
end
