# -*- encoding : utf-8 -*-
module SimpleHTTP
  class Client
    # Defines a base Request class intended for subclassing to define new Request types, such
    # as Get and Post.
    class Request
      attr_accessor :attributes
      hash_key_accessor :name => :attributes,
                        :keys => [:host, :path, :port, :headers, :proxy_host, :proxy_port, :open_timeout, :read_timeout, :http_user, :http_password, :use_ssl]

      # Initializes a new SimpleHTTP::Client::Request object. Not intended for use outside
      # of SimpleHTTP internals. Takes a hash of the following arguments:
      # :host - Required. The hostname or IP of the server to make requests to.
      # :path - Required. The path including query parameters to request.
      # :port - Optional. The remote port to connect to, defaults to 80.
      # :headers - Optional. A hash defining a set of HTTP headers to pass along with this request.
      # :proxy_host - Optional. The hostname or IP of a proxy server to make requests through.
      # :proxy_port - Optional. The remote proxy port to connect to.
      # :open_timeout - Optional. Sets a timeout in seconds for opening the HTTP connection.
      # :read_timeout - Optional. Sets a timeout in seconds for reading from the HTTP connection.
      # :data - Optional. Data to send in the request body. Only works with certain kinds of request.
      # :http_user - Optional. A username to use for HTTP basic authorization.
      # :http_password - Optional. A password to use for HTTP basic authorization.
      def initialize(attributes = {})
        verify_args attributes, :host, :path
        self.attributes = attributes
      end

      # Returns the HTTP verb this request class handles.
      def self.verb
        name.demodulize.downcase
      end
      delegate :verb, :to => :klass # Sets up a verb instance method

      # Makes the HTTP request and returns the response, must be overridden by subclasses.
      def go!
        raise RuntimeError, "Must be defined in subclasses."
      end

    private

      # Returns a new Net::HTTP object pre-configured with attributes that will apply to all
      # requests made via this instance
      def net_http
        Net::HTTP.new(host, port, proxy_host, proxy_port).tap do |http|
          http.open_timeout, http.read_timeout = open_timeout, read_timeout
          if use_ssl
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE # gets rid of "warning: peer certificate won't be verified in this SSL session"
          end
        end
      end

      # The Net::HTTP::Response objects returned as a result of using net_http should be
      # returned as the result of evaluation of a block passed into this method. This way,
      # all exceptions are handled via SimpleHTTP rather than bubbling up out of Net::HTTP.
      #
      # Successful requests are also properly returned as SimpleHTTP::Client::Response objects
      # rather than the myriad of return values possible in Net::HTTP.
      def new_response(&block)
        Response.create_from_net_http_response_block(&block)
      end

      def data
        @attributes[:data].to_s
      end

      def authorization_header
        {'Authorization' => 'Basic ' + ["#{http_user}:#{http_password}"].pack('m').delete("\r\n")}
      end

      def has_authorization_details?
        !http_user.nil? || !http_password.nil?
      end

      def headers
        @attributes[:headers] ||= {}
        if has_authorization_details?
          @attributes[:headers] = authorization_header.merge(@attributes[:headers])
        end
        @attributes[:headers]
      end

    end   # Request

    class Get < Request

      def go!
        new_response { net_http.get(path, headers) }
      end

    end   # Get

    class Post < Request

      def go!
        new_response { net_http.post(path, data, headers) }
      end

    end   # Post

    class Put < Request

      def go!
        new_response { net_http.put(path, data, headers) }
      end

    end   # Put

    class Delete < Request

      def go!
        new_response { net_http.delete(path, headers) }
      end

    private

      # The Net::HTTP docs offer this as a sane default for DELETE requests.
      def headers
        {'Depth' => 'Infinity'}.merge(super)
      end

    end   # Delete

    class Head < Request

      def go!
        new_response { net_http.head(path, headers) }
      end

    end   # Head

  end   # Client
end
