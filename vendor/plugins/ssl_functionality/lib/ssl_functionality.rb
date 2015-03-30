# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.

# In your controllers, set a before filter like so:
#   before_filter RosettaStone::ForceSsl
# or
#   before_filter RosettaStone::ForceNonSsl
# in contexts where you want the application to redirect HTTP requests to HTTPS
# (or vice versa).
# This behavior depends on an (optional) config file at RAILS_ROOT/config/ssl.yml 
# that should have (at least) a key `enable_ssl`.  If the config file is not present, 
# or if enable_ssl is set to false, these before filters will do nothing.
module RosettaStone
  class SslFunctionality
    include RosettaStone::YamlSettings
    yaml_settings :config_file => 'ssl.yml', :required => false

    class << self
      def instance_supports_ssl?
        @instance_supports_ssl ||= !!(settings && settings[:enable_ssl])
      end

      def https_port
        @https_port ||= ((settings && settings[:https_port]) || 443).to_i
      end

      def http_port
        @http_port ||= ((settings && settings[:http_port]) || 80).to_i
      end

      def https_port_in_url
        (https_port == 443) ? '' : ":#{https_port}"
      end

      def http_port_in_url
        (http_port == 80) ? '' : ":#{http_port}"
      end
    end
  end

  # this class is intended to be used as a controller before_filter
  class ForceSsl < SslFunctionality
    class << self
      def filter(controller)
        # adding ?force_non_ssl=true to the URL of the first page in the session should cause you to stick on HTTP
        controller.session[:ssl_functionality_force_non_ssl] = true if controller.params[:force_non_ssl] == 'true'
        return if controller.session[:ssl_functionality_force_non_ssl]
        controller.send(:redirect_to, https_url(controller)) if (!controller.request.ssl? && instance_supports_ssl?) 
      end

    private

      def https_url(controller)
        "https://#{controller.request.host}#{https_port_in_url}#{controller.request.request_uri}"
      end
    end
  end

  # this class is intended to be used as a controller before_filter
  class ForceNonSsl < SslFunctionality
    class << self
      def filter(controller)
        controller.send(:redirect_to, http_url(controller)) if controller.request.ssl? 
      end

    private

      def http_url(controller)
        "http://#{controller.request.host}#{http_port_in_url}#{controller.request.request_uri}"
      end
    end
  end
end