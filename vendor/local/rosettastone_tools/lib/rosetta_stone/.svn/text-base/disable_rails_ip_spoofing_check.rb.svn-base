# Work Item 20706
#
# Rails has a built-in IP spoofing check that is triggered whenever a request has both an X-Forwarded-For
# (HTTP_X_FORWARDED_FOR) and a Client-IP (HTTP_CLIENT_IP) header.  Our Netscaler load balancers add the
# X-Forwarded-For header on all requests so we want to disable this spoofing check across the board.
#
if defined?(Rails) && defined?(ActionController::Base)
  if Rails::VERSION::MAJOR >= 3
    # NOTE: we have another forced monkeypatch loaded as a part of rosettastone_tools that rewrites the
    # IP address resolution code (the one that uses this configuration variable) so that this setting
    # is no longer relevant in Rails 3.
    module RosettastoneTools
      class DisableIpSpoofingCheck < Rails::Railtie
        config.action_dispatch.ip_spoofing_check = false
      end
    end
  else # Rails 3+
    # Note: in older versions of Rails (2.0 for instance), it was not possible to disable the spoofing check
    # like this.
    if ActionController::Base.respond_to?('ip_spoofing_check=')
      ActionController::Base.ip_spoofing_check = false # rails 2.3, etc, support this syntax
    end
  end
end
