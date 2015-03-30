class AuditLogRecord < ActiveRecord::Base
  class << self
    def mirror_db_options
      using_mirror_db_connection? ? {:mirror_db_connection => true} : {}
    end

    def using_mirror_db_connection?
      defined?(MagicMultiConnection)
    end

    # In this class, we expect a :type as well as an :id for the polymorphic association stuff to work.
    def create_log_entry!(log_entry)
      # This is a little weird. I shouldn't need to do this. Investigate. Seems like a rails bug, it's serializing
      # symbols to yaml.
      alr_klass = determine_alr_klass(log_entry)
      log_entry[:attribute_name], log_entry[:action] = log_entry[:attribute_name].to_s, log_entry[:action].to_s

      # some users of this plugin may not have all these columns in the audit_log_records table, be tolerant.
      %w(ip_address serialized_attributes parent_id parent_type changed_by).each do |optional_column|
        log_entry.delete(optional_column.to_sym) unless has_column?(optional_column)
      end
      alr_klass.create!(log_entry)
    end

    def has_column?(column_name)
      @column_names_as_strings ||= Set.new(column_names.map(&:to_s))
      @column_names_as_strings.include?(column_name.to_s)
    end

  private

    # Could present a security risk at some point, but is very unlikely. It'd mean we'd somehow have to be getting
    # :klass_type from the user, which would defeat the purpose of audit logs really.
    def determine_alr_klass(log_entry)
      (log_entry[:klass_type].blank?) ? self : log_entry[:klass_type].constantize
    end

  end

  after_save :mark_read_only_callback
  #after_find :mark_read_only_callback # Rails 3.0+

  belongs_to :loggable, {:polymorphic => true}.merge(mirror_db_options)

  def previous_value_after_typecast
    typecast_attribute_based_on_loggable(previous_value)
  end

  def new_value_after_typecast
    typecast_attribute_based_on_loggable(new_value)
  end

  # I hate that they chose 'type' as the STI name so much. Note to self - start changing it from 'type' in all our
  # apps using set_inheritance_column.
  def klass_type=(klass_name)
    self[:type] = klass_name
  end

  def klass_type
    return self[:type]
  end

  # This is part of a workaround that relates to being unable to eager load polymorphic associations, and not being
  # able to use loggable= because it'll assume i want to set the association
  def set_loggable(loggable)
    @cached_loggable = loggable
  end

  alias_method :association_loggable, :loggable
  def loggable
    @cached_loggable || association_loggable
  end

  def deserialized_attributes
    raise NotImplementedError unless klass.has_column?('serialized_attributes')
    if serialized_attributes.blank?
      {}.with_indifferent_access
    else
      begin
        ActiveSupport::JSON.decode(serialized_attributes).with_indifferent_access
      rescue json_parse_error_exception
        {}.with_indifferent_access
      end
    end
  end

  def after_find
    mark_read_only_callback
  end

private

  def typecast_attribute_based_on_loggable(value)
    # this is because mysql returns nulls in columns of type "text" as empty strings rather than nil
    return nil if value == ''
    if attribute_name && column = loggable.column_for_attribute(attribute_name)
      column.type_cast(value)
    else
      value
    end
  end

  # you should have the json gem installed, in which case you will get JSON::ParserError.
  # otherwise you'll get StandardError.  but, just install the JSON gem.
  def json_parse_error_exception
    defined?(JSON) ? JSON::ParserError : StandardError
  end

  def mark_read_only_callback
    readonly!
    true
  end

end
