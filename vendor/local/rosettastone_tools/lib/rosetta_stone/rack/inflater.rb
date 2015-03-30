# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.
require 'zlib'
require 'stringio'

# This is a Middleware class intended for use with Rack.
# It decompresses gzip- or deflate-encoded request bodies.  This functionality is
# enabled for HTTP POSTs when the web server sets the HTTP_CONTENT_ENCODING
# environment variable to 'gzip'.
#
# Usage with Rails: in config/environment.rb, add the following within the
# Rails::Initializer block:
#
#    # install Rack Inflater middleware to decompress incoming gzip-encoded request bodies:
#    require Rails.root.join(*%w(vendor plugins rosettastone_tools lib rosetta_stone rack inflater))
#    config.middleware.insert(0, Rack::Inflater)
#
# This probably only works with Rails 2.3+
#
# WARNING: This technique decompresses the entire input stream into memory.
# This could be dangerous if someone crafts a gzipped request that
# expands to a huge uncompressed length.  We could run out of memory and
# cause a DoS.
# At the very least you should limit the max request body length, but
# even that isn't failsafe.
#
# GZIP and Deflate encodings are similar; they both use the same compression
# algorithm (deflate) but GZIP wraps the compressed payload with a magic header
# (for easier identification) and appends bytes that represent CRC and uncompressed
# length (for more reliable detection of corruption/failure).  Deflate encoding
# is just the raw compressed data.
#
# So, use GZIP if you can.
#
# Incoming HTTP request headers should be one of the following:
#   Content-Encoding: gzip
#   Content-Encoding: deflate
module Rack
  class Inflater
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless env['REQUEST_METHOD'] == 'POST'

      begin
        if env['HTTP_CONTENT_ENCODING'].to_s =~ /(^|,|\s)gzip(\s|,|$)/
          decompress_gzip_encoding(env)
        elsif env['HTTP_CONTENT_ENCODING'].to_s =~ /(^|,|\s)deflate(\s|,|$)/
          decompress_deflate_encoding(env)
        end
      rescue Exception => e
        set_error(env, e.inspect)
        env['rack.input'].rewind
      end
      @app.call(env)
    end

  private

    # note: these error appear in the web server error log, not the rails log
    def set_error(env, message)
      env['rack.errors'].write("#{klass}: #{message}")
      env['rack.errors'].flush
    end

    def decompress_gzip_encoding(env)
      # We would *like* to set this middleware up as a "pipe", but Rails reads up to
      # CONTENT_LENGTH bytes, and we can't know the true (uncompressed) content length unless
      # we decompress the whole input stream.
      #env['rack.input'] = Zlib::GzipReader.new(env['rack.input'])
      gz_reader = Zlib::GzipReader.new(env['rack.input'])
      uncompressed_body = gz_reader.read
      gz_reader.close
      env['CONTENT_LENGTH'] = uncompressed_body.length
      env['rack.input'] = StringIO.new(uncompressed_body)
    end

    def decompress_deflate_encoding(env)
      uncompressed_body = Zlib::Inflate.inflate(env['rack.input'].read)
      env['CONTENT_LENGTH'] = uncompressed_body.length
      env['rack.input'] = StringIO.new(uncompressed_body)
    end
  end
end
