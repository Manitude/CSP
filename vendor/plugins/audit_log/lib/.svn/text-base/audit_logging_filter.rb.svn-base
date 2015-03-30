class AuditLoggingFilter
  def initialize(options)
    verify_args options, :changed_by_reader
    @changed_by_reader = options[:changed_by_reader]
    @ip_address_reader = options[:ip_address_reader]
  end

  def before(controller)
    CustomAuditLogger.set_changed_by!(controller.send(@changed_by_reader))
    CustomAuditLogger.set_ip_address!(controller.send(@ip_address_reader)) if @ip_address_reader
  end

  def after(controller)
    CustomAuditLogger.reset!
  end
end
