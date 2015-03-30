# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module ObjectExtensions
    def klass
      self.class
    end

    def multisend(*method_names)
      method_names.collect{|method_name| send(method_name)}
    end
    alias_method :cascade, :multisend # Love to Smalltalk.

    def me
      block_given? ? yield(self) : self
    end

    def only_if
      self unless block_given? && !yield(self)
    end

    # this is for backwards compatibility for pre-Rails-2.3 (?) apps running
    # Ruby < 1.8.7.  Rails 2.3+ (?) already has this defined, as does Ruby
    # 1.8.7+ and 1.9.
    def tap
      yield self
      self
    end unless Object.respond_to?(:tap)

    # #to_json results in a string that doesn't report as HTML safe,
    # so when Rails 3 or rails_xss incorporates it, it further HTML
    # escapes it. We don't want this to happen in some environments
    # (like in Javascript files), so Javascript ERB files can call
    # to_embedded_json instead of to_json to avoid HTML escaping the
    # resulting string
    def to_embedded_json
      s = to_json
      s.respond_to?(:html_safe) ? s.html_safe : s
    end

    def if_hot
      yield self unless self.nil?
    end
    alias_method :unless_ill, :if_hot

    # instance_eval on the singleton_class
    def singleton_class_eval(&block)
      singleton_class.instance_eval(&block)
    end

    def all_instance_methods(show_methods_from_ancestors=true)
      public_instance_methods(show_methods_from_ancestors) + private_instance_methods(show_methods_from_ancestors) + protected_instance_methods(show_methods_from_ancestors)
    end

    # this is for backwards compatibility for pre-Rails-2.3 (?) apps
    def present?
      !blank?
    end unless Object.respond_to?(:present?)

    # call method_name on the object, if the object responds to method_name.
    # otherwise, return self.
    # useful for something like 'string'.try_to(:html_safe)
    # when you don't know whether the .html_safe method exists
    def try_to(method_name, *args)
      respond_to?(method_name) ? send(method_name, *args) : self
    end

    # Will retry a block, depending on which exception is raised
    #
    # Params:
    # +exceptions_to_rescue+:: an array that contains types of exceptions that, if raised, will cause the block to be retried. Defaults to all exceptions.
    # +max_attempts+:: the maximum number of times that the block should be executed. Default to 2.
    # +send_exception_notification+:: true if you would like to send a notification on exception. Defaults to false.
    # +reset_proc+:: a Proc that will be run prior to retrying the block. Defaults to nil.
    def retry_on_exception(exceptions_to_rescue = [Exception], max_attempts = 2, send_exception_notification = false, reset_proc = nil )
      attempt = 1
      begin
        yield
      rescue *exceptions_to_rescue => e
        attempt += 1
        RosettaStone::GenericExceptionNotifier.deliver_exception_notification(e) if send_exception_notification
        unless attempt > max_attempts
          logger.error "#{Time.now.to_s(:db)}: retry_on_exception - retrying (attempt #{attempt})...  Error was #{e.inspect}"
          reset_proc.call if reset_proc
          retry
        end
        logger.error "#{Time.now.to_s(:db)}: retry_on_exception - failed after #{max_attempts} tries"
        raise e
      end
    end
  end

  module ObjectClassMethodExtensions
    def display_name
      to_s.underscore.split('_').join(' ')
    end
  end

  # a block in the context of the instance (like instance_eval) but pass the block parameters (like block.call).
  #
  # See: http://blog.jayfields.com/2006/09/ruby-instanceexec-aka-instanceeval.html for more.
  module InstanceExec
    module InstanceExecHelper; end
    include InstanceExecHelper
    def instance_exec(*args, &block)
      if defined?(::Rails) && ::Rails.version.to_s < '3'
        begin
          old_critical, Thread.critical = Thread.critical, true
          n = 0
          n += 1 while respond_to?(mname="__instance_exec#{n}")
          InstanceExecHelper.module_eval{ define_method(mname, &block) }
        ensure
          Thread.critical = old_critical
        end
        begin
          ret = send(mname, *args)
        ensure
          InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
        end
        ret
      else
        super
      end
    end # def instance_exec
  end # InstanceExec
end
Object.send(:include, RosettaStone::ObjectExtensions)
Object.send(:extend, RosettaStone::ObjectClassMethodExtensions)
Object.send(:include, RosettaStone::InstanceExec)
