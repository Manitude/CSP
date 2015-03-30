require 'socket'

# configure exception_notification plugin
# ExceptionNotifier.exception_recipients = %w(error_notifier@rosettastone.com)
# ExceptionNotifier.email_prefix = "[CCS ERROR (#{Socket.gethostname})] "
# ExceptionNotifier.sender_address = %("CCS Error" <donotreply@rosettastone.com>)


CoachPortal::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[CSP ERROR (#{Socket.gethostname})] ",
  :sender_address => %("CSP Error" <donotreply@rosettastone.com>),
  :exception_recipients => %w(error_notifier@rosettastone.com)