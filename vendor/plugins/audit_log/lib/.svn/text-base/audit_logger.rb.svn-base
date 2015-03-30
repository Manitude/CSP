module RosettaStone
  module AuditLog
    class AuditLogger

      def initialize(options = {})
        @record = options[:record]
        @options = options
        @options[:except] += ar_special_attributes if ignoring_special_attributes?
        @logs = {}
      end

      # AR has no central place where 'special' columns are recorded, so unfortunately I'm duplicating their
      # names here.
      def ar_special_attributes
        [:created_at, :created_on, :updated_at, :updated_on, :lock_version]
      end

      def record(attribute_name, previous_value, new_value)
        return false if ignore_attribute?(attribute_name)
        @logs[attribute_name.to_sym] ||= {:previous_value => previous_value}
        @logs[attribute_name.to_sym][:new_value] = new_value
        @logs[attribute_name.to_sym][:timestamp] = Time.now
      end

      def save!(action)
        send(:"save_on_#{action}")
      end

      def new_value_for(attribute_name)
        @logs[attribute_name.to_sym][:new_value] if @logs[attribute_name.to_sym]
      end

      def previous_value_for(attribute_name)
        @logs[attribute_name.to_sym][:previous_value] if @logs[attribute_name.to_sym]
      end

    private

      def logger
        RAILS_DEFAULT_LOGGER
      end

      def ignore_attribute?(attribute_name)
        case
        when !@options[:only].empty? then !@options[:only].include?(attribute_name.to_sym)
        when !@options[:except].empty? then @options[:except].include?(attribute_name.to_sym)
        else
          false
        end
      end

      def ignoring_special_attributes?
        @options[:ignore_special_attributes]
      end

      def log_writer
        @record.audit_log_records
      end

      def save_log_entry(log_entry)
        raise(SecurityError, "Couldn't create audit log entry for entry '#{log_entry.inspect}'") unless log_writer.create_log_entry!(log_entry)
      end

      def save_on_create
        save_log_entry(:action => 'create', :timestamp => Time.now)
      end

      def save_on_destroy
        save_log_entry(:action => 'destroy', :timestamp => Time.now)
      end

      def save_on_update
        @logs.each do |attribute_name, log_entry|
          save_log_entry(log_entry.merge(:action => 'update', :attribute_name => attribute_name))
        end
        @logs.clear
      end

    end # AuditLogger
  end   # AuditLog
end