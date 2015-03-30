# -*- encoding : utf-8 -*-
require 'webrick'
require 'webrick/httpproxy'

class WEBrick::HTTPServlet::ProcHandler
  alias_method :do_PUT, :do_POST
  alias_method :do_DELETE, :do_POST
  alias_method :do_HEAD, :do_POST
end

class SimpleHttpTestServer
  TEST_SERVER_MOUNT_PATH = '/simplehttp/testing'

  class << self
    def start(options = {})
      stop if @server
      options[:port] ||= default_port
      webrick_options = {
        :ServerType => Thread, :Port => options[:port], :AccessLog => [],
        :Logger => WEBrick::Log.new(nil, WEBrick::Log::FATAL)
      }
      webrick_options[:RequestTimeout] = options[:request_timeout] if options[:request_timeout]
      @server = WEBrick::HTTPServer.new(webrick_options)

      # TODO / FIXME - refactor to something that extends AbstractServlet rather than using the webrick
      # ProcHandler
      @server.mount_proc(TEST_SERVER_MOUNT_PATH) do |request,response|
        servlet = SimpleHttpTestServlet.new(request, response)
        servlet.process!(options[:before_filter], options[:after_filter])
      end
      @server.start
    end

    def stop
      @server.shutdown
      @server.stop
    end

    def default_port
      defined?(ActiveSupport::TestCase::WEBRICK_PORT_FOR_TESTS) ? ActiveSupport::TestCase::WEBRICK_PORT_FOR_TESTS : 4334
    end
  end

  class SimpleHttpTestServlet
    attr_reader :request, :response, :params
    private :request, :response, :params

    def initialize(request, response)
      @request, @response, @params = request, response, request.query.with_indifferent_access
      if !@request.header['authorization'].empty?
        username, password = @request.header['authorization'].first.split(' ')[1].unpack('m')[0].split(':')
      else
        username = password = nil
      end
      @request.singleton_class.send(:define_method, :username) { username }
      @request.singleton_class.send(:define_method, :password) { password }
      @request.body # to force it to read the request body before processing
    end

    def process!(before_filter = nil, after_filter = nil)
      before_filter.call(request, response, params) if before_filter
      response.status = 200
      response.body = 'OK'
      after_filter.call(request, response, params) if after_filter
    end

  end # SimpleHttpTestServlet

end

class SimpleHttpTestMockProxyServer

  class << self
    def start(options = {})
      stop if @server
      options[:port] ||= default_port
      @server = MockProxy.new(:ServerType => Thread, :Port => options[:port], :ProxyContentHandler => options[:on_request],
                              :AccessLog => [], :Logger => WEBrick::Log.new(nil, WEBrick::Log::FATAL))
      @server.start
    end

    def stop
      @server.shutdown
      @server.stop
    end

    def default_port
      defined?(ActiveSupport::TestCase::WEBRICK_PORT_FOR_TESTS) ? ActiveSupport::TestCase::WEBRICK_PORT_FOR_TESTS.to_i + 100 : 4335
    end
  end

  class MockProxy < WEBrick::HTTPProxyServer

    def service(req, res)
      @config[:ProxyContentHandler].call(req, res) if @config[:ProxyContentHandler]
    end

  end

end
