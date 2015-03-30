# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# include this into your Granite::Producer class and publish like:
# publish(:object => my_active_record_object)
#
# As long as your message is a hash, any values that are ActiveRecord objects
# will get serialized.  AR objects with keys other than :object will get their
# serialized keys prefixed in the granite job, for example:
#  publish(:license => my_license)
# will serialize to:
#  {'license_class' => 'License', 'license_id' => 123, 'license_updated_at' => 1341495567}
module Granite
  module ActiveRecordObjectPublisher
    def self.included(base)
      if ActiveSupport::VERSION::MAJOR < 3
        base.before_publish(:serialize_active_record_objects)
      else
        base.set_callback(:publish, :serialize_active_record_objects)
      end
    end

    # in your message hash, put :object => an_active_record_object
    # and optionally add :object_class_prefix => 'ReadOnly::'
    def serialize_active_record_objects
      raise "Can only operate on Granite::Job messages" unless @message.is_a?(Granite::Job)
      message_hash = @message.payload
      return unless message_hash.is_a?(Hash)
      message_hash = message_hash.with_indifferent_access

      serialize_active_record_object!(message_hash) # default behavior, handling :object

      # serialize other active record objects in the payload, using a prefix
      message_hash.map {|k, v| k if v.is_a? ActiveRecord::Base}.compact.each do |ar_key|
        serialize_active_record_object!(message_hash, ar_key)
      end
      @message.payload = message_hash
    end

    def serialize_active_record_object!(message_hash, prefix = nil)
      if object = message_hash.delete(prefix || :object)
        class_prefix = message_hash.delete("#{prefix || :object}_class_prefix".to_sym)
        message_hash.merge!(serialized_object(object, prefix, class_prefix))
      end
    end

    def serialized_object(object, prefix = nil, class_prefix = nil)
      {
        prefix.nil? ? 'class' : "#{prefix}_class" => "#{class_prefix}#{object.class}",
        prefix.nil? ? 'id' : "#{prefix}_id" => object.id,
        prefix.nil? ? 'updated_at' : "#{prefix}_updated_at" => object.updated_at.to_i,        
      }
    end
  end
end
