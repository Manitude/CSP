# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.
require 'zlib'
require 'stringio'

module RosettaStone
  module Compression
    class << self
      def compress(message)
        gz_writer = Zlib::GzipWriter.new(StringIO.new)
        gz_writer.write(message.to_s)
        gz_writer.close.string
      end

      def decompress(compressed_message)
        decompressed_message = nil
        begin
          gz_reader = Zlib::GzipReader.new(StringIO.new(compressed_message.to_s))
          decompressed_message = gz_reader.read
          gz_reader.close
        rescue Zlib::GzipFile::Error
          decompressed_message = compressed_message
        end
        return decompressed_message
      end

      def is_compressed?(message)
        Zlib::GzipReader.new(StringIO.new(message.to_s))
        true
      rescue Zlib::GzipFile::Error
        false
      end
    end
  end
end
