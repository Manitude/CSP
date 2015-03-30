# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module ActionControllerSslExtensions
    # aliases for convenience
    # def instance_supports_ssl?
    # def http_port
    # def https_port
    delegate :instance_supports_ssl?, :http_port, :https_port, :to => RosettaStone::SslFunctionality
  
    def protocol_with_ssl_if_available
      instance_supports_ssl? ? 'https' : 'http'
    end
  
    def https_port_options_if_available_and_nonstandard
      return http_port_options_if_nonstandard unless instance_supports_ssl?
      (https_port == 443) ? {} : {:port => https_port}
    end
  
    def http_port_options_if_nonstandard
      (http_port == 80) ? {} : {:port => http_port}
    end
  
    # intended for use in arguments to url_for(), like:
    # redirect_to(sign_in_url(with_ssl_if_available))
    def with_ssl_if_available(other_options = {})
      other_options.merge(:host => request.host, :protocol => protocol_with_ssl_if_available).merge(https_port_options_if_available_and_nonstandard)
    end
  
    # intended for use in arguments to url_for(), like:
    # redirect_to(root_url(without_ssl))
    def without_ssl(other_options = {})
      other_options.merge(:host => request.host, :protocol => 'http').merge(http_port_options_if_nonstandard)
    end

    # can be merged into url_for options in order to keep you on the same port and protocol you currently have
    def keep_current_port_and_protocol
      {}.tap do |options|
        options.merge!(:port => request.port) unless [80, 443].include?(request.port.to_i)
        options.merge!(:protocol => 'https') if request.ssl?     
      end
    end  
  end
end

if defined?(ActionController)
  ActionController::Base.send(:include, RosettaStone::ActionControllerSslExtensions) 
  # set up all the module methods as helper methods:
  RosettaStone::ActionControllerSslExtensions.instance_methods.each do |controller_method_name|
    ActionController::Base.module_eval do
      helper_method controller_method_name.to_sym
    end
  end
end