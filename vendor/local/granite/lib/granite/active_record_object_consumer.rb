# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# include this into your Granite Agent class.
# You'll want to define one of the following methods in your agent class:
#
# def process_record(record)  # simple case, assuming an :object was published, you'll get the record
# def process_record(record, header, payload)  # :object published, but you want access to other header/payload attributes
# def process(header, payload) # you need to call find_updated_active_record_object() yourself
module Granite
  module ActiveRecordObjectConsumer
    IGNORABLY_LARGE_CLOCK_SKEW = 120 # seconds; if the skew is larger than this, we give up trying to get our delay timings right
    def self.included(base)
      class << base # whoa, ruby
        attr_accessor :max_find_attempts, :seconds_to_delay_past_updated_at, :class_prefix
      end
      base.max_find_attempts = 3 # default, override in your agent if you wish
      base.seconds_to_delay_past_updated_at = 1 # set to 0 or nil to disable this delay
      base.class_prefix = ''
    end

    # the message indicates an expected updated_at for the record, if the record we load from the database isn't
    # yet up to date, we back off and retry up to MAX_FIND_ATTEMPTS times
    class RecordNotUpdated < RuntimeError; end
    class ProcessRecordMethodMustBeDefined < RuntimeError; end

    # override this if you need, but if so you must call find_updated_active_record_object yourself.
    # in common usage, you just want to define process_record(record) in your agent.
    # your process_record method can accept one argument (record) or 3 arguments (record, header, payload)
    def process(header, payload)
      record = find_updated_active_record_object(payload)
      raise ProcessRecordMethodMustBeDefined unless respond_to?(:process_record, true)
      process_record(*[record, header, payload].slice(0...method(:process_record).arity))
    end

    def find_updated_active_record_object(payload, prefix = nil)
      attributes = payload.dup
      class_key = prefix.nil? ? 'class' : "#{prefix}_class"
      id_key = prefix.nil? ? 'id' : "#{prefix}_id"
      updated_at_key = prefix.nil? ? 'updated_at' : "#{prefix}_updated_at"

      verify_args(attributes, class_key, id_key, updated_at_key)

      object_class, object_id, object_updated_at = attributes[class_key], attributes[id_key], attributes[updated_at_key]

      delay_if_appropriate(object_updated_at)

      record = nil
      attempt = 1
      begin
        classname = klass.class_prefix.blank? ? object_class : klass.class_prefix + object_class
        record = classname.constantize.find(object_id)
        raise RecordNotUpdated unless record.respond_to?(:updated_at) && record.updated_at && record.updated_at.to_i >= object_updated_at
      rescue ActiveRecord::RecordNotFound, RecordNotUpdated
        # opx:#10404: it's possible that the agent is executing before the record has actually been saved (committed) in the database, so
        # we'll do a back-off delay and a retry.
        if attempt < klass.max_find_attempts
          back_off_delay = attempt.to_f / 1.5
          logger.error("Failed to find record in attempt #{attempt}.  Backing off for #{back_off_delay} seconds and retrying.")
          sleep(back_off_delay)
          attempt += 1
          retry
        end
        logger.error("Failed to find updated record after #{klass.max_find_attempts} tries.  Giving up.")
        raise
      end
      record
    end

    def delay_if_appropriate(updated_at)
      return unless klass.seconds_to_delay_past_updated_at.to_i > 0 # disable this behavior by setting seconds_to_delay_past_updated_at to nil
      difference = updated_at.to_i - Time.now.to_i
      seconds_to_delay_before_running_job = difference + klass.seconds_to_delay_past_updated_at
      if difference > IGNORABLY_LARGE_CLOCK_SKEW # gah, something seems wrong
        logger.error("Possible clock skew detected: message indicates updated_at of #{updated_at} but our local agent clock is #{Time.now.to_i}.  Delaying job by #{klass.seconds_to_delay_past_updated_at} seconds.")
        sleep(klass.seconds_to_delay_past_updated_at)
      elsif seconds_to_delay_before_running_job > 0
        logger.info("Delaying job by #{seconds_to_delay_before_running_job} seconds.")
        sleep(seconds_to_delay_before_running_job)
      end
    end
  end
end
