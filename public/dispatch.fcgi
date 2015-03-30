#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= 'production'

require File.expand_path('../../config/rubygems_boot', __FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../',  "vendor", "local", "bundler-1.2.0", "lib")

require File.expand_path('../../config/environment', __FILE__)

require 'uri'

class Rack::PathInfoRewriter
  def initialize(app)
    @app = app
  end

  def call(env)
    env.delete('SCRIPT_NAME')
    uri = URI.parse(env['REQUEST_URI'])
    env['PATH_INFO'] = uri.path
    env['QUERY_STRING'] = uri.query

    @app.call(env)
  end
end

Rack::Handler::FastCGI.run  Rack::PathInfoRewriter.new(CoachPortal::Application)
