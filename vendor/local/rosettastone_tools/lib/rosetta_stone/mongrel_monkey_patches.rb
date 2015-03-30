# -*- encoding : utf-8 -*-
# Some monkey patching is required for selenium tests to run properly with mongrel 1.1.5
# There is a bug in rails/rack/mongrel involving the way that the Response header is formatted
# and it manifests itself in different ways depending on which version of rails you are running.
#
# We've patched rack 1.1.0 manually, so we don't need to patch that from here.
#
# This seems to load appropriately if you do script/server or mongrel_rails start.
# It requires an extra kick, however, to get loaded from polonium's MongrelServerRunner.

if defined?(Mongrel) && defined?(Mongrel::Const::MONGREL_VERSION) && Mongrel::Const::MONGREL_VERSION == '1.1.5'
  if RosettaStone::RailsVersionString > RosettaStone::VersionString.new(2,3,8)
    logger.info("MongrelMonkeyPatches: im in ur mongruls, setn ur cookies.")

    # This patch was one piece of the larger patch found here:
    #   http://gist.github.com/471663
    # and referenced from here:
    #   https://rails.lighthouseapp.com/projects/8994/tickets/4690-mongrel-doesnt-work-with-rails-238
    #
    class Mongrel::CGIWrapper
      def header_with_rails_fix(options = 'text/html')
        @head['cookie'] = options.delete('cookie').flatten.map { |v| v.sub(/^\n/,'') } if options.class != String and options['cookie']
        header_without_rails_fix(options)
      end
      alias_method_chain :header, :rails_fix
    end

  elsif RosettaStone::RailsVersionString == RosettaStone::VersionString.new(2,3,8)
    logger.info("MongrelMonkeyPatches: im in ur mongruls, setn ur cookies.  And you should upgrade rails.")
    # this bug only started to be exercised with Rails 2.3.8.
    #
    # see also:
    #  * http://www.mail-archive.com/ovirt-devel@redhat.com/msg00817.html
    #  * http://github.com/fauna/mongrel/commit/7c9d988d4de2e08d67f95ca209196427fd89c9af
    class Mongrel::CGIWrapper
      def send_cookies(to)
        # convert the cookies based on the myriad of possible ways to set a cookie
        if @head['cookie']
          cookie = @head['cookie']
          case cookie
          when Array
            cookie.each {|c| to['Set-Cookie'] = c.to_s }
          when Hash
            cookie.each_value {|c| to['Set-Cookie'] = c.to_s}
          else
            to['Set-Cookie'] = cookie.to_s  # this is the only changed line from 1.1.5
          end

          @head.delete('cookie')
        end

        # @output_cookies seems to never be used, but we'll process it just in case
        @output_cookies.each {|c| to['Set-Cookie'] = c.to_s } if @output_cookies
      end
    end
  else
    logger.info("Look, please, please, upgrade rails.")
    # it's your lucky day, but you should upgrade rails. *muted trumpet*
  end

end
