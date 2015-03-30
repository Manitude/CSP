require 'ipaddr'

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
module ExceptionNotifiable
  def self.included(target)
    target.extend(ClassMethods)
  end

  module ClassMethods
    def consider_local(*args)
      local_addresses.concat(args.flatten.map { |a| IPAddr.new(a) })
    end

    def local_addresses
      addresses = read_inheritable_attribute(:local_addresses)
      unless addresses
        addresses = [IPAddr.new("127.0.0.1")]
        write_inheritable_attribute(:local_addresses, addresses)
      end
      addresses
    end

    def exception_data(deliverer=self)
      if deliverer == self
        read_inheritable_attribute(:exception_data)
      else
        write_inheritable_attribute(:exception_data, deliverer)
      end
    end

    def exceptions_to_treat_as_404
      exceptions = [ActiveRecord::RecordNotFound,
                    ActionController::UnknownController,
                    ActionController::UnknownAction]
      exceptions << ActionController::RoutingError if ActionController.const_defined?(:RoutingError)
      exceptions
    end
  end

  private

    def local_request?
      # We don't want anything to be considered local in production, to be safe
      return false if RAILS_ENV == 'production'
      remote = IPAddr.new(request.remote_ip)
      !self.class.local_addresses.detect { |addr| addr.include?(remote) }.nil?
    end

    # make 404 and 500 use rails so they're easier to build...
    def render_404
      options = {:template => "error/404", :status => "404 Not Found"}
      options.merge!(:layout => (error_layout_exists? ? 'error' : false)) 
      render(options)
    end

    def render_500
      options = {:template => "error/500", :status => "500 Error"}
      options.merge!(:layout => (error_layout_exists? ? 'error' : false)) 
      render(options)
    end

    def rescue_action_in_public(exception)
      request.format = 'html' # use html for response despite what the client asks for
      # HACK around a bug (IMO) in rails (2.2.2 at least) where it caches the template format to use after trying to find 
      # one once, which doesn't let you change it later for another template search.  Kicking the cache here.
      response.template.instance_variable_set('@template_format', 'html') if response && response.template
      case exception
        when *self.class.exceptions_to_treat_as_404
          render_404
        else          
          render_500
          deliver_exception_email(exception)
      end
    rescue => new_exception
      deliver_exception_email(new_exception)
      render :text => "<html><body><h1>Application error</h1></body></html>", :status => 500
    end

private

  def deliver_exception_email(exception)
    deliverer = self.class.exception_data
    data = case deliverer
      when nil then {}
      when Symbol then send(deliverer)
      when Proc then deliverer.call(self)
    end

    ExceptionNotifier.deliver_exception_notification(exception, self, request, (data || {}))
  end

  def error_layout_exists?
    ActionController::Base.layout_list.any? {|layout| layout =~ %r(app/views/layouts/error\.)}
  end
end
