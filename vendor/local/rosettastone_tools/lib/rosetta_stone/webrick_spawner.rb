# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

begin
  require 'webrick_server'
rescue LoadError
  require 'rack/handler/webrick'
end
begin
  require 'dispatcher'
rescue LoadError; end

# adapted from https://trac.lan.flt/webdev/browser/ec_admin/trunk/test/xmlrpc/jaws_server_test.rb
module RosettaStone
  class WebrickSpawner
    class << self
      attr_accessor :server

      def start(overrides = {})
        options = {
          :port            => 3333,
          :ip              => "localhost",
          :environment     => Rails.env.dup,
          :server_root     => File.expand_path(Rails.root + "/public/"),
          :server_type     => Thread,
          :charset         => "UTF-8",
          :mime_types      => WEBrick::HTTPUtils::DefaultMimeTypes,
          :logger          => Rails.logger, # send the webrick output to the normal log file instead of stdout
        }.merge(overrides)
        Socket.do_not_reverse_lookup = true # patch for OS X

        params = {
          :Port        => options[:port].to_i,
          :ServerType  => options[:server_type],
          :BindAddress => options[:ip]
        }
        params[:MimeTypes] = options[:mime_types] if options[:mime_types]
        if options[:logger]
          params[:Logger] = options[:logger]
          params[:AccessLog] = [ [options[:logger], WEBrick::AccessLog::COMBINED_LOG_FORMAT ] ]
        end
        self.server = WEBrick::HTTPServer.new(params)
        if Rails::VERSION::MAJOR > 2
          server.mount('/', Rack::Handler::WEBrick, options)
        else
          server.mount('/', DispatchServlet, options)
        end

        server.start

        # give it a few seconds to get up and running
        loop_count = 0
        while !running? do
          loop_count += 1
          raise "webrick doesn't seem to be running yet" if loop_count > 10
          sleep(0.25)
        end
      end

      def status
        return :Not_started if server.nil?
        server.status # usually :Running, can be :Stop
      end

      def running?
        status == :Running
      end

      def stop
        return if server.nil?
        server.shutdown
        server.stop
        self.server = nil
      end

      def with_server(overrides = {}, &block)
        log_output = capture_output do
          start(overrides)
          yield
        end
        Rails.logger.info("#{self} - output from webrick: #{log_output}")
      ensure
        stop
      end

    private

      # sweet, adapted from vendor/rake/test/capture_stdout.rb
      def capture_output
        s = StringIO.new
        oldstdout = $stdout
        oldstderr = $stderr
        $stdout = s
        $stderr = s
        yield
        s.string
      ensure
        $stdout = oldstdout
        $stderr = oldstderr
      end

    end
  end
end
