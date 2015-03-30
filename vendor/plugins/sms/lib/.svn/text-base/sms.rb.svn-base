class Sms
  class UncategorizedException < StandardError; end
  class PingError < StandardError; end
  include Singleton
  cattr_accessor :api_methods
  self.api_methods = []

  def initialize
    @config = SMS_CONFIG.symbolize_keys
  end

  module ApiMethods
    def send_message(user, message_text, resending_activation_code = false)
      mobile_number = klass.sanitize_number(user.mobile_number_with_country_code)
      vendors_to_try = user.has_international_mobile_number? ? %w(clickatell celltrust) : %w(celltrust clickatell)
      vendors_to_try.reverse! if resending_activation_code #9556
      send_message_with_fallback(user, mobile_number, message_text, vendors_to_try)
    end
  
    def send_message_with_fallback(user, mobile_number, message_text, vendors_to_try, vendor_trying_index = 0)
      # App.enable_clickatell
      # App.enable_celltrust
      if App.send("enable_#{vendors_to_try[vendor_trying_index]}")
        # send_clickatell_message
        # send_celltrust_message
        if self.send("send_#{vendors_to_try[vendor_trying_index]}_message", user, mobile_number, message_text)
          return true
        end
      end
      if vendor_trying_index < vendors_to_try.size - 1
        return send_message_with_fallback(user, mobile_number, message_text, vendors_to_try, vendor_trying_index + 1)
      end
      false
    end
  end
  
  include ApiMethods
  include ClickatellApiMethods
  include CelltrustApiMethods
  
  # do some magic to set up the API methods so they can be called directly on Sms rather than the instance.
  # For instance, ApiMethods#ping is accessed as Sms.ping.  sweet. 
  (ApiMethods.instance_methods + ClickatellApiMethods.instance_methods + CelltrustApiMethods.instance_methods).each do |api_method|
    self.api_methods << api_method.to_sym # so we can handle respond_to?
    klass.send(:delegate, api_method.to_sym, :to => :instance)
  end
  
  class << self
    def respond_to?(meth)
      super || self.api_methods.include?(meth.to_sym)
    end
  
    def ok_to_send_messages?
      App.ok_to_send_sms
    end
  
    # remove non-numerics and leading zeros
    def sanitize_number(number)
      number.to_s.gsub(%r{\D}, '').gsub(%r{^0+}, '')
    end
  end

end
