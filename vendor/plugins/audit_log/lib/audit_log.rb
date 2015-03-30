require 'audit_logger'

module RosettaStone
  module AuditLog

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # Module to extend the association with in order to block its usage on records that have audit logging enabled.
    module AuditLogAssociationExtensions
      def <<(*args); warn_against_association_usage; end
      def build(*args); warn_against_association_usage; end
      def create(*args); warn_against_association_usage; end
      def delete(*args); warn_against_association_usage; end

      def warn_against_association_usage
        raise SecurityError, "Don't use this association for anything but finding audit log records."
      end

      # This is a hack around not being able to eager load polymorphic associations. We set the return of 'loggable'
      # to be the owner of this association as an optimisation.
      def load_target
        was_loaded = loaded?
        t = super
        unless was_loaded
          @target.each{|r| r.set_loggable(@owner)}
        end
        t
      end

      # This horrible hack is to prevent rails from doing this stupid thing where it automatically
      # loads this association after a save on the parent association even if that's what i don't
      # want - FIXME. Such a horrible hack, but the code on activerecord that adds that callback
      # is also awful. Broken windows.
      def respond_to?(method_name)
        return false if method_name.to_sym == :loaded?
        super
      end
    end

    module ClassMethods

      # Callback for when ActiveRecord::Base gets extended with this module. All ActiveRecord::Base subclasses
      # get the accessor audit_log_enabled, even if the 'audit_log' method hasn't been called in the class definition.
      def self.extended(base)
        base.class_eval do
          class_inheritable_accessor :audit_log_enabled
          self.audit_log_enabled = false
          def self.audit_log_enabled?; audit_log_enabled == true; end
          def audit_log_enabled?; self.class.audit_log_enabled?; end
        end
      end

      # Sets up audit logging for an ActiveRecord class. Example:
      #
      #   class License < ActiveRecord::Base
      #     audit_logged
      #   end
      #
      # Available options are:
      #
      #   :loggable_actions - one or all of [:create, :update, :destroy]. Enables audit logging for
      #   the selected ActiveRecord actions. Defaults to logging creates, updates, and destroys.
      #
      #   :except - a symbol or array of symbols of attributes to not audit log changes on
      #
      #   :only - a symbol or array of symbols of attributes to only audit log changes on, ignoring
      #   changes to any other attributes
      #
      #   :also_log - a symbol or array of symbols of non ActiveRecord default attributes to log
      #   changes on. Example:
      #
      #      class License < ActiveRecord::Base
      #        audit_logged :also_log => :agreement_type
      #
      #        def agreement_type=(type_string)
      #          self.downcased_agreement_type = type_string.downcase
      #        end
      #
      #        def agreement_type
      #          downcased_agreement_type.upcase
      #        end
      #      end
      #
      #   :ignore_special_attributes - true or false, sets whether to ignore special AR columns like
      #   created_on and lock_version. Defaults to true.
      #
      #   :associate - true or false, sets whether to define the audit_log_records and related
      #   associations on the class audit logging is being enabled on. Defaults to true.
      #
      #   :audit_logger_class - specifies a replacement class to use as the audit_logger object. This
      #   can be overridden to provide a class with more specialised behaviour such as recording an
      #   identifier for the entity making changes to a record. Defaults to using
      #   RosettaStone::AuditLog::AuditLogger, it is recommended you extend this class when adding
      #   functionality.
      def audit_logged(options = {})
        # Extend this class with a module that adds methods such as without_audit_logging
        extend(SingletonMethods)
        class_inheritable_accessor :audit_log_options
        # Clearly, we want to enable the audit logging by default
        enable_audit_logging!
        options = build_audit_log_options(options)
        write_inheritable_attribute(:audit_log_options, options)
        set_up_audit_logging_callbacks
        set_up_also_log_methods(*options[:also_log])
        set_up_association_for_audit_logs if options[:associate]
        # Include appropriate InstanceMethods into this class
        include(InstanceMethods)
      end

      private
      # Merges the options given to audit_log into the options any subclasses may have defined into the default options,
      # and normalizes arguments that can have multiple values into an array, and constantizes the class to use for audit
      # logging. FIXME: Something like this should be moved into rosettastone_tools
      def build_audit_log_options(options = {})
        merged_options = default_audit_log_options.merge(self.audit_log_options || {}).merge(options)
        [:loggable_actions, :except, :only, :also_log].each { |array_option| merged_options[array_option] = Array(merged_options[array_option]) }
        merged_options[:audit_logger_class] = merged_options[:audit_logger_class].to_s.constantize
        merged_options
      end

      # Sets up callbacks for the appropriate stages of ActiveRecord object lifecycle, which by default is a set of callbacks
      # to audit log creates, attribute updates, and deletes.
      def set_up_audit_logging_callbacks
        audit_log_options[:loggable_actions].each do |loggable_action|
          callback_name, callback_method = :"after_#{loggable_action}", :"audit_log_#{loggable_action}s"
          # If the callbacks have already been set up then we dont want to do it again, so we check before trying to add a
          # callback.
          send(callback_name, callback_method) unless inheritable_attributes[callback_name] && inheritable_attributes[callback_name].include?(callback_method)
        end
      end

      # Sets up the association so .audit_log_records can be used on ActiveRecord objects that are being audit logged
      def set_up_association_for_audit_logs
        with_options({:as => :loggable, :extend => AuditLogAssociationExtensions, :order => 'timestamp DESC', :class_name => 'AuditLogRecord'}.merge(AuditLogRecord.mirror_db_options)) do |o|
          o.has_many :audit_log_records
          # Sets up further associations so update_audit_log_records / create_audit_log_records / destroy_audit_log_records can be used to
          # get audit log records for the specific kind of action.
          %w{update destroy create}.each { |action| o.has_many :"#{action}_audit_log_records", :conditions => ['action = ?', action] }
        end
      end

      # Returns the default options for audit logging
      def default_audit_log_options
        {:loggable_actions => [:update, :create, :destroy], :ignore_special_attributes => true, :except => [],
          :only => [], :also_log => [], :audit_logger_class => 'RosettaStone::AuditLog::AuditLogger', :associate => true}
      end

      # If :also_log is used, this method takes the appropriate action to either redefine the getter and setter if they exist,
      # or to set up a callback that will redefine them when they're defined in the future.
      def set_up_also_log_methods(*method_names)
        method_names = method_names.collect { |method_name| (method_name.to_s =~ /^(.*)=$/) ? $1 : method_name.to_s }.uniq
        method_names.each do |method_name|
          valid_for_non_activerecord_audit_logging?(method_name) ? alias_methods_with_audit_logging(method_name) : set_up_callback_for_possible_method_definition(method_name)
        end
      end

      # Performs checks to see if this attribute is valid for use with the :also_log option
      def valid_for_non_activerecord_audit_logging?(method_name)
        method_name = method_name.to_sym
        audit_log_options[:also_log].include?(method_name) && attribute_name_meets_getter_and_setter_requirements(method_name) && attribute_name_meets_arity_requirements(method_name)
      end

      # The attribute name must have both getter and setter methods, so, for example, 'agreement_type' and 'agreement_type='
      def attribute_name_meets_getter_and_setter_requirements(method_name)
        all_instance_methods.include?(method_name.to_s) && all_instance_methods.include?("#{method_name}=")
      end

      # The setter method must have an arity of 1 to work with the :also_log option, that is, it must require 1 argument. The
      # getter method must not require any arguments.
      def attribute_name_meets_arity_requirements(method_name)
        (instance_method("#{method_name}=").arity == 1) && (instance_method(method_name).arity == 0)
      end

      # Aliases the setter method to audit log before calling the original method
      def alias_methods_with_audit_logging(method_name)
        @redefining_audit_log_accessor = true
        define_method(:"#{method_name}_with_audit_logging=") do |value|
          log_attribute_change(method_name, value, false)
          send(:"#{method_name}_without_audit_logging=", value)
        end
        alias_method_chain :"#{method_name}=", :audit_logging
        @redefining_audit_log_accessor = false
      end

      # If we extend with this module but the class has already been extended with it, we end up setting up a recursive chain
      # of method calls
      def set_up_callback_for_possible_method_definition(method_name)
        extend(MethodDefinitionCallback) unless singleton_class.included_modules.include?(MethodDefinitionCallback)
      end

    end # ClassMethods

    module MethodDefinitionCallback

      def self.extended(klass)
        class << klass
          alias_method_chain :method_added, :audit_logging
        end
      end

      # Sets up a callback to check if a method should be redefined to audit log when it's defined in this class.
      def method_added_with_audit_logging(method_name)
        method_added_without_audit_logging(method_name)
        # Return here otherwise we'll end up in a loop of this getting called when we define the new method that overrides
        # the original setter.
        return true if @redefining_audit_log_accessor
        set_up_also_log_methods(method_name)
      end

    end # MethodDefinitionCallback

    module SingletonMethods

      # Used on a class, allows audit logging to be disabled on objects of that type within the scope of the block
      def without_audit_logging(warning = true, &block)
        disable_audit_logging!(warning)
        block.call()
      ensure
        enable_audit_logging!(warning)
      end

      private
      def disable_audit_logging!(warning = true)
        self.audit_log_enabled = false
        logger.info("[WARNING] Warning! Audit logging has been disabled for #{self.to_s}") if warning
      end

      def enable_audit_logging!(warning = true)
        self.audit_log_enabled = true
        logger.info("[WARNING] Audit logging has been enabled for #{self.to_s}") if warning
      end
    end


    module InstanceMethods

      def self.included(klass)
        klass.instance_eval do
          alias_method_chain :initialize, :audit_logging unless self.audit_log_options
        end
      end

      # Disables audit logging for the initialization of this object so the first time setup of
      # attributes doesnt get audit logged.
      def initialize_with_audit_logging(*args, &block)
        self.class.without_audit_logging(false) { initialize_without_audit_logging(*args, &block) }
      end

      # Audit logs writes to attributes on the record
      def write_attribute(attribute_name, value)
        super
        log_attribute_change(attribute_name)
      end

      # Accessor to the AuditLogger object for this record.
      def audit_logger
        @audit_logger ||= audit_log_options[:audit_logger_class].new(self.audit_log_options.merge(:record => self))
      end

      private

      # Logs a change to an attribute, whether it be a default AR type attribute or a method that
      # has been hand defined. Note that if you are logging a non-AR type attribute, then you need
      # to call this *before* the change happens. If you're logging an AR type attribute, then you
      # need to call this *after* the change.
      def log_attribute_change(attribute_name, new_value = nil, attibute_is_active_record = true)
        return nil unless audit_log_enabled? && !new_record?
        if attibute_is_active_record
          #write_attribute has already been called, so the attribute has already been marked as
          #dirty
          return false unless send(:"#{attribute_name}_changed?")
          previous_value, new_value = send(:"#{attribute_name}_change")
        else
          previous_value = send(attribute_name)
          return false if new_value == previous_value
        end

        # fixes #1654
        return false if ([nil, ''].include?(previous_value) && [nil, ''].include?(new_value))

        audit_logger.record(attribute_name, previous_value, new_value)
      end

      %w{create update destroy}.each do |action|
        define_method(:"audit_log_#{action}s") do
          if audit_log_enabled?
            logger.debug("Saving a log entry on #{action} for #{self.class} record #{id}")
            audit_logger.save!(action.to_sym)
          end
          true
        end
      end

    end # InstanceMethods
  end   # AuditLog
end

ActiveRecord::Base.send(:include, RosettaStone::AuditLog)
