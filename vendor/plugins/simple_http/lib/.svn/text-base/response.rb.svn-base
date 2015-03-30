# -*- encoding : utf-8 -*-
module SimpleHTTP
  class Client
    class Response

      attr_accessor :attributes
      hash_key_accessor :name => :attributes, :keys => [:body, :code, :http_version, :message, :headers]
      alias_method :status, :code

      # Initializes a new SimpleHTTP::Client::Response object. Takes a hash of the following arguments:
      # :body - Required. The body of the HTTP response.
      # :code - Required. The HTTP status code of the response.
      # :http_version - Optional. The HTTP version returned by the server.
      # :message - Optional. A status message returned by the server.
      def initialize(attributes = {})
        self.attributes = attributes
      end

      # Given a block that evaluates and returns a Net::HTTP::Response object, this method creates a
      # SimpleHTTP::Client::Response object if successful, and handles any exceptions raised otherwise.
      def self.create_from_net_http_response_block(&block)
        response = block.call
        new(:body => response.body, :code => response.code, :http_version => response.http_version, :message => response.message, :headers => response.to_hash)
      rescue Exception => e
        handle_net_http_exception(e)
      end

      def code_class
        "#{code[0..0]}xx".to_sym
      end
      alias_method :status_class, :code_class

      def success?
        code_class == :"2xx"
      end

      def get_header(header_name)
        headers[header_name.to_s.downcase].if_hot {|h| h.join(', ')}
      end

    private

      def self.handle_net_http_exception(exception)
        case exception
        when SocketError, Errno::ECONNREFUSED, TimeoutError, Timeout::Error, SystemCallError, IOError
          raise ConnectionException,
            "A connection error occurred internal to SimpleHTTP. The root cause was #{exception.class}: #{exception.message}"
        else
          raise UnhandledException,
            "An unhandled error occurred internal to SimpleHTTP. The root cause was #{exception.class}: #{exception.message} (#{exception.backtrace})"
        end
      end

    end   # Response
  end   # Client
end
