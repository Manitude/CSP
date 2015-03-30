# Our custom audit logger merges in the changed_by attribute
class CustomAuditLogger <  RosettaStone::AuditLog::AuditLogger
  # Using this over class_inheritable_accessor because we want it to
  # be the same value over all subclasses, not independent for each.
  cattr_accessor :current_changed_by_entity, :current_ip_address

  def save_log_entry(log_entry)
    log_entry.merge!(:changed_by => changed_by_value) if AuditLogRecord.has_column?('changed_by')
    log_entry.merge!(:ip_address => current_ip_address.to_s) if has_set_field?(:current_ip_address)
    log_entry.merge!(:serialized_attributes => serialize_attributes) if %w(create destroy).include?(log_entry[:action])
    log_entry.merge!(parent_record_details)
    super(log_entry)
  end

  def changed_by_value
    if current_changed_by_entity.nil?
      logger.info("WARNING: 'current_changed_by_entity' is nil. Your audit logs may be inaccurate. Please see custom_audit_logger.rb")
    end
    current_changed_by_entity.to_s
  end

  def has_set_field?(field)
    !send(field).nil?
  end

  def serialize_attributes
    @record.attributes.to_json
  end

  def parent_record_details
    return {} unless @record.respond_to?(:parent_record_class_name_and_id) && @record.parent_record_class_name_and_id.all?(&:present?)
    parent_record_class_name, parent_record_id = @record.parent_record_class_name_and_id
    {:parent_type => parent_record_class_name, :parent_id => parent_record_id}
  end

  class << self
    def set_changed_by!(changed_by_value)
      self.current_changed_by_entity = changed_by_value
    end

    def set_ip_address!(ip_address)
      self.current_ip_address = ip_address
    end

    # provided for backwards compatibility for non-community apps. use self.reset!
    def reset_changed_by!
      self.current_changed_by_entity = nil
    end

    def reset!
      reset_changed_by!
      self.current_ip_address = nil
    end
  end
end
