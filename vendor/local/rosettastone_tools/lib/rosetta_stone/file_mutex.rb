# -*- encoding : utf-8 -*-
module RosettaStone
  class FileMutex
    class Locked < StandardError; end
    attr_reader :identifier, :options

    class << self
      include RosettaStone::PrefixedLogger

      def protect(identifier, options = {}, &block)
        mutex = new(identifier, options)
        if mutex.ok_to_run?
          begin
            logger.info("locking for identifier '#{identifier}'")
            mutex.lock!
            yield
          ensure
            logger.info("unlocking for identifier '#{identifier}'")
            mutex.unlock!
          end
        else
          logger.error("identifier '#{identifier}' already locked!")
          raise Locked
        end
      end
    end

    def initialize(identifier, options = {})
      @identifier = identifier
      @options = options
    end

    def ok_to_run?
      !locked? || lock_expired?
    end

    def locked?
      File.exist?(lock_file_name)
    end

    def lock_expired?
      can_expire? && locked? && lock_file_is_stale?
    end

    def lock!
      FileUtils.touch(lock_file_name)
    end

    def unlock!
      FileUtils.rm(lock_file_name) if locked?
    end

  private

    def lock_file_name
      File.join(Rails.root, 'tmp', "#{identifier}.lock")
    end

    def can_expire?
      return options[:expires] unless options[:expires].nil? # allow false
      true
    end

    def lock_expiry_minutes
      (options[:lock_expiry_minutes] && options[:lock_expiry_minutes].to_i) || 300
    end

    def lock_file_is_stale?
      File.mtime(lock_file_name) < lock_expiry_minutes.minutes.ago
    end

  end
end
