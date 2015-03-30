require 'pathname'

# Copyright (c) 2005 Jamis Buck
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
class ExceptionNotifier < ActionMailer::Base
  @@sender_address = %("Exception Notifier" <exception.notifier@default.com>)
  cattr_accessor :sender_address

  @@exception_recipients = []
  cattr_accessor :exception_recipients

  @@email_prefix = "[ERROR] "
  cattr_accessor :email_prefix

  @@sections = %w(request session environment backtrace)
  cattr_accessor :sections

  # Rosetta Stone local modification to truncate subject lines
  # set to nil (or false) to disable truncation
  @@subject_truncate_length = 120
  cattr_accessor :subject_truncate_length

  views_dir = File.join(File.dirname(__FILE__), '..', 'views')
  self.respond_to?(:prepend_view_path) ? self.prepend_view_path(views_dir) : self.template_root = views_dir

  def self.reloadable?() false end

  def exception_notification(exception, controller, request, data={})
    content_type "text/plain"

    # Rosetta Stone local modification to truncate subject lines
    subject_string = "#{email_prefix}#{controller.controller_name}##{controller.action_name} (#{exception.class}) #{exception.message.inspect}" 
    subject_string = subject_string[0...subject_truncate_length] + '...' if subject_truncate_length && subject_string.length > subject_truncate_length
    subject subject_string

    recipients exception_recipients
    from       sender_address

    body       data.merge({ :controller => controller, :request => request,
                  :exception => exception, :host => (request.env["HTTP_X_FORWARDED_HOST"] || request.env["HTTP_HOST"]),
                  :backtrace => sanitize_backtrace(exception.backtrace),
                  :rails_root => rails_root, :data => data,
                  :sections => sections })
  end

  private

    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map { |line| Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s }
    end

    def rails_root
      @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
    end

end
