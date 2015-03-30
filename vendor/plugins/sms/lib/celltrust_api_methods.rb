require 'net/http'
require 'net/https'

# to get rid of the "warning: peer certificate won't be verified in this SSL session" warnings
class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

module CelltrustApiMethods
  def send_celltrust_message(user, mobile_number, message_text) # eventually we can have options = {} as the last optional argument. options can be like {:from => 'RS Studio'}, but the custom sender id supposedly doesn't work in the USA
    begin
      url = URI.parse(@config[:celltrust_url] || 'https://gateway.celltrust.net')
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      response, body = http.post('/TxTNotify/TxTNotify', "PhoneDestination=#{mobile_number}&Message=#{CGI.escape(message_text)}&CustomerNickname=#{@config[:celltrust_username]}&Username=#{@config[:celltrust_username]}&Password=#{@config[:celltrust_password]}&XMLResponse=true")
      xml_body = XmlSimple.xml_in(body, 'forcearray' => false)
      msgid = nil
      sms_delivery_params = {
        user.class.name.underscore.to_sym => user, # to support both Student and User classes
        :mobile_number => mobile_number,
        :message_body => message_text
      }
      if xml_body['MsgResponseList'] && xml_body['MsgResponseList']['MsgResponse'] && xml_body['MsgResponseList']['MsgResponse']['MessageId']
        msgid = xml_body['MsgResponseList']['MsgResponse']['MessageId']
        sms_delivery_params.merge!(:api_response_successful => !!msgid, :celltrust_msgid => msgid)
      elsif xml_body['Error'] && xml_body['Error']['ErrorCode'] && xml_body['Error']['ErrorString']
        sms_delivery_params.merge!(:api_response_successful => false, :celltrust_error_code => xml_body['Error']['ErrorCode'], :celltrust_error_message => xml_body['Error']['ErrorString'])
      else
        raise "unknown xml body: #{body}"
      end
      SmsDeliveryAttempt.create(sms_delivery_params)
      return !!sms_delivery_params[:api_response_successful]
    rescue Exception => ee
      RosettaStone::GenericExceptionNotifier.deliver_exception_notification("celltrust error: #{ee.inspect}")
      SmsDeliveryAttempt.create({
        user.class.name.underscore.to_sym => user, # to support both Student and User classes
        :mobile_number => mobile_number,
        :message_body => message_text,
        :api_response_successful => false,
        :celltrust_error_code => 'unknown - see message',
        :celltrust_error_message => ee.inspect,
      })
      false
    end
  end
end