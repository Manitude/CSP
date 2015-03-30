# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require 'ostruct'

class Granite::Job < OpenStruct
  CURRENT_PROTOCOL_VERSION = 1
  class MalformedMessage < StandardError; end

  class << self
    include RosettaStone::PrefixedLogger

    def decode_message(raw_message)
      message_hash = nil
      begin
        decompressed_message = RosettaStone::Compression.decompress(raw_message.to_s)
        raise MalformedMessage if decompressed_message.blank?
        if decompressed_message != raw_message
          percent_reduced = ((raw_message.size - decompressed_message.size) * 100.0 / (decompressed_message.size)).round(1)
          logger.debug("Message compression: #{raw_message.size}/#{decompressed_message.size} bytes (#{percent_reduced}%)")
        end
        message_hash = ActiveSupport::JSON.decode(decompressed_message)
        raise MalformedMessage unless message_hash.is_a?(Hash)
        verify_args(message_hash.symbolize_keys, :timestamp, :job_guid, :payload)
      rescue json_parse_error_exception, ArgumentError => message_error # ArgumentError is raised by verify_args if it fails
        logger.error("malformed message: #{raw_message.inspect}\n#{message_error}")
        RosettaStone::GenericExceptionNotifier.deliver_exception_notification(message_error)
        raise MalformedMessage
      end
      message_hash
    end

    def parse(raw_message)
      message_hash = decode_message(raw_message)
      job = self.new(message_hash)
      job.timestamp = Time.at(job.timestamp) rescue Time.now
      job
    end

    # wraps your message payload in the standard format of a granite job
    def create(message)
      new({:job_guid => RosettaStone::UUIDHelper.generate, :timestamp => Time.now.to_i, :payload => message, :retries => 0, :protocol_version => CURRENT_PROTOCOL_VERSION})
    end

  private
    # you should have the json gem installed, in which case you will get JSON::ParserError.
    # otherwise you'll get StandardError.  but, just install the JSON gem.
    def json_parse_error_exception
      if defined?(MultiJson)
        MultiJson::DecodeError
      elsif defined?(JSON)
        JSON::ParserError
      else
        StandardError
      end
    end

  end

  def to_json
    hash = to_hash
    hash[:timestamp] = hash[:timestamp].to_i
    hash.to_json
  end

  def to_hash
    instance_values['table']
  end
end
