# This hotfix covers two issues in Rails routing.
#
#  * Rails 3 incorrectly resolves request.remote_ip to REMOTE_ADDR
#    if every HTTP_X_FORWARDED_FOR is a trusted proxy. This results
#    in potentially odd behavior. If every step is trusted, there's
#    no harm in just using the step closest to the client.
#  * Rails 2 incorrectly looks among HTTP_X_FORWARDED_FOR to get
#    the request.remote_ip even if REMOTE_ADDR is untrusted. This
#    makes spoofing trivially easy if a client can achieve a direct
#    connection. We fix this by assembling an IP chain and taking
#    the closest untrusted IP from the server.
#
# To use it, if you have rosettastone_tools loaded, have the
# following in an initializer:
#
#     require 'rosettastone_tools/shared_hotfixes/remote_ip_getter'
#
# This file is currently maintained to be compatible with:
#
#  * Rails 3.0.12
#  * Rails 3.1.4
#
if Rails::VERSION::MAJOR == 3 && [0, 1].include?(Rails::VERSION::MINOR)
  ActionDispatch::RemoteIp::RemoteIpGetter.class_eval do
    def remote_addrs
      @remote_addrs ||= @env['REMOTE_ADDR'] ? @env['REMOTE_ADDR'].split(/[,\s]+/) : []
    end

    def to_s
      # original body from 3.0.12
      # return remote_addrs.first if remote_addrs.any?
      #
      # forwarded_ips = @env['HTTP_X_FORWARDED_FOR'] ? @env['HTTP_X_FORWARDED_FOR'].strip.split(/[,\s]+/) : []
      #
      # if client_ip = @env['HTTP_CLIENT_IP']
      #   if @check_ip_spoofing && !forwarded_ips.include?(client_ip)
      #     # We don't know which came from the proxy, and which from the user
      #     raise IpSpoofAttackError, "IP spoofing attack?!" \
      #       "HTTP_CLIENT_IP=#{@env['HTTP_CLIENT_IP'].inspect}" \
      #     "HTTP_X_FORWARDED_FOR=#{@env['HTTP_X_FORWARDED_FOR'].inspect}"
      #   end
      #   return client_ip
      # end
      #
      # return forwarded_ips.reject { |ip| ip =~ @trusted_proxies }.last || @env["REMOTE_ADDR"]

      forwarded_ips = @env['HTTP_X_FORWARDED_FOR'] ? @env['HTTP_X_FORWARDED_FOR'].strip.split(/[,\s]+/) : []
      # ip_chain represents a full list of the HTTP forward chain
      # with the beginning closest to the client and the end
      # closest to the server.
      ip_chain = forwarded_ips + remote_addrs

      # the parts of the IP chain that aren't trusted
      untrusted_ip_chain = ip_chain.reject { |ip| ip =~ @trusted_proxies }

      if untrusted_ip_chain.empty?
        # the entire IP chain is trusted. this can happen if the
        # entire route is on the local network. if so, just get
        # the IP closest to the client.
        return ip_chain.first
      else
        # there is at least one untrusted hop. return the most
        # recent untrusted hop (the last hop before the request
        # hit the Rails server).
        return untrusted_ip_chain.last
      end
    end
  end
else
  puts "remote_ip_getter.rb has yet to be made compatible with this Rails version.  please fix me."
end
