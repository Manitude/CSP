# -*- encoding : utf-8 -*-
require 'hoptoad_notifier/rails'

module HoptoadNotifier
  module Rails
    module ControllerMethods
    private

      def hoptoad_session_data
        data_to_return = nil
        if session.respond_to?(:to_hash)
          data_to_return = session.to_hash
        else
          data_to_return = session.data
        end
        filter_session(data_to_return)
      end

      def filter_session(hash)
        return if hash.nil?
        hash = hash.dup
        hash.each do |key, value|
          if (key.is_a?(String) || key.is_a?(Symbol)) && HoptoadNotifier.configuration.session_filters.any? { |re| re.match(key.to_s) }
            hash[key] = '[FILTERED]'
          elsif value.is_a?(Hash)
            hash[key] = filter_session(hash[key])
          end
        end
        hash
      end # filter_session

    end # ControllerMethods
  end # Rails
end # HoptoadNotifier

module ActionController
  class Base
    def local_request?
      # We don't want anything to be considered local in production, to be safe
      return false if RAILS_ENV == 'production'
      super # rails/actionpack/lib/action_controller/rescue.rb
    end

    def error_layout_exists?
      ActionController::Base.layout_list.any? {|layout| layout =~ %r(app/views/layouts/error\.)}
    end

    # make 404 and 500 use rails so they're easier to build...
    def render_404
      options = {:template => "error/404", :status => "404 Not Found"}
      options.merge!(:layout => (error_layout_exists? ? 'error' : false))
      render(options)
    end

    def render_500
      options = {:template => "error/500", :status => "500 Error"}
      options.merge!(:layout => (error_layout_exists? ? 'error' : false))
      render(options)
    end

    def rescue_action_in_public_without_hoptoad(exception)
      request.format = 'html' # use html for response despite what the client asks for
      # HACK around a bug (IMO) in rails (2.2.2 at least) where it caches the template format to use after trying to find
      # one once, which doesn't let you change it later for another template search.  Kicking the cache here.
      response.template.instance_variable_set('@template_format', 'html') if response && response.template
      case exception
        when *HoptoadNotifier.configuration.exceptions_to_treat_as_404
          render_404
        else
          render_500
      end
    rescue => new_exception
      notify_hoptoad(new_exception)
      render :text => "<html><body><h1>Application error</h1></body></html>", :status => 500
    end

    def submit_js_error_to_hoptoad(options = {})
      submit_to_hoptoad = true
      error_hash =
        begin
          ActiveSupport::JSON.decode(request.raw_post || '') || {} # decoding a blank string yields false
        rescue json_parse_error_exception => exception
          if options[:submit_to_hoptoad_anyway_on_parse_failure] == false
            submit_to_hoptoad = false
          end
          {'errorClass' => exception.class.to_s, 'message' => exception.to_s}
        end
      error_class = 'JS:' + (error_hash['errorClass'] || "UnknownException")
      error_message = error_class + ':' + (error_hash['message'] || 'No message set in exception')
      exception_hash = {
        :error_class   => error_class,
        :error_message => error_message,
        :session       => {
          :key => session.instance_variable_get("@session_id"),
          :data => error_hash['data']
        },
      }
      if submit_to_hoptoad
        notify_hoptoad(exception_hash)
      else
        logger.error "Wanted to submit a js error to hoptoad, but could not parse the json to make it happen. Raw post was: #{request.raw_post}"
      end
    end

    # you should have the json gem installed, in which case you will get JSON::ParserError.
    # otherwise you'll get StandardError.  but, just install the JSON gem.
    def json_parse_error_exception
      defined?(JSON) ? JSON::ParserError : StandardError
    end
  end
end

# this constant is frozen. screw that.
former_options = HoptoadNotifier::Configuration.send(:remove_const, :OPTIONS)
HoptoadNotifier::Configuration::OPTIONS = former_options + [:session_filters, :exceptions_to_treat_as_404]

module HoptoadNotifier
  class Configuration
    attr_accessor :session_filters, :exceptions_to_treat_as_404
  end
end

