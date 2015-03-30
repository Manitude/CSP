module ClickatellApiMethods
  def send_clickatell_message(user, mobile_number, message_text) # eventually we can have options = {} as the last optional argument. options can be like {:from => 'RS Studio'}, but the custom sender id supposedly doesn't work in the USA
    begin
      msgid = clickatell_make_api_request('send_message', mobile_number, message_text) # options would go as the last argument here
      SmsDeliveryAttempt.create({
        user.class.name.underscore.to_sym => user, # to support both Student and User classes
        :mobile_number => mobile_number,
        :message_body => message_text,
        :api_response_successful => true,
        :clickatell_msgid => msgid,
      })
      true
    rescue Clickatell::API::Error => clickatell_error # note: authentication failure/timeout is handled for us already
      #  * when running low on credits? e.message is unknown at this point
      #  * when out of credits e.message is unknown at this point
      #  * when the system is down e.message is unknown at this point
      #  * when there is no network connection to the system (hint: unplug your laptop from the network to find this one out... i just don't want adium to be mad at me right now, so i'm blowing this one off) e.message is unknown at this point
      #  * when the number is not an SMS receiving number: "Cannot route message"
      #  * when the number is invalid (or no country code): "Cannot route message"
      #  * when the number is the wrong format: "Invalid Destination Address"
      SmsDeliveryAttempt.create({
        user.class.name.underscore.to_sym => user, # to support both Student and User classes
        :mobile_number => mobile_number,
        :message_body => message_text,
        :api_response_successful => false,
        :clickatell_error_code => clickatell_error.code,
        :clickatell_error_message => clickatell_error.message,
      })
      false
    end
  end

  def clickatell_account_balance
    clickatell_make_api_request('account_balance')
  end

  def clickatell_has_route_coverage?(number)
    response = clickatell_make_api_request('route_coverage', number) # Net::HTTPOK
    raise Sms::UncategorizedException, "Response was #{response.inspect}, body was #{response.body}" unless response.is_a?(Net::HTTPOK)
    # sample response bodies:
    # "OK: This prefix is currently supported. Messages sent to this prefix will be routed. Charge: 1\n"
    # "ERR: This prefix is not currently supported. Messages sent to this prefix will fail. Please contact support for assistance.\n"
    return response.body.to_s.starts_with?('OK:')
  end

  # returns a number representing the milliseconds to make the API ping or raises Sms::PingError for other conditions
  def clickatell_ping
    Benchmark.measure do
      begin
        response = clickatell_make_api_request('ping_with_current_session_id')
        if !response.is_a?(Net::HTTPOK) # what the heck clickatell gem?  also what the heck Net::HTTP?
          message = "HTTP failure from Clickatell API: #{response.inspect}"
          logger.error("#{log_prefix} Ping #{message}")
          raise Sms::PingError, message
        end
      rescue Clickatell::API::Error => clickatell_error
        # this error condition is already logged; just raise the PingError
        raise Sms::PingError, "Error response from Clickatell API: #{clickatell_error.inspect}"
      end
    end.milliseconds
  end

  def clickatell_disconnect!
    @clickatell_connection = nil
  end

  def clickatell_reconnect!
    clickatell_disconnect!
    logger.info("#{log_prefix} had stale session, reconnecting")
    clickatell_connection
  end

private
  def clickatell_authenticate!
    raise 'sms.yml is missing either clickatell_api_key, clickatell_username, or clickatell_password' if @config[:clickatell_api_key].blank? || @config[:clickatell_username].blank? ||  @config[:clickatell_password].blank?
    logger.info("#{log_prefix} no current session, authenticating")
    Clickatell::API.authenticate(
      @config[:clickatell_api_key],
      @config[:clickatell_username],
      @config[:clickatell_password]
    )
  end

  def clickatell_connection
    @clickatell_connection ||= clickatell_authenticate!
  end

  def clickatell_make_api_request(api_method, *args)
    attempts = 0
    begin
      logger.info("#{log_prefix} sending API request '#{api_method}' (first attempt)")
      clickatell_connection.send(api_method, *args)
    rescue Clickatell::API::Error => clickatell_error
      attempts += 1
      logger.error(%Q|#{log_prefix} Error #{clickatell_error.code}: #{clickatell_error.message}|)
      if is_timeout_error?(clickatell_error) && attempts < 2 # session timeout error on the first try
        clickatell_reconnect!
        retry
      else # some other kind of error (or session timeout on the second try) - notify and let it bubble
        RosettaStone::GenericExceptionNotifier.deliver_exception_notification(clickatell_error)
        raise
      end
    end
  end

  def log_prefix
    "#{Time.now.to_s(:db)} - Clickatell (#{Process.pid}):"
  end

  # FIXME: we don't really know for sure what the session timeout error looks like!  Guessing for now...
  def is_timeout_error?(clickatell_error)
    return false unless clickatell_error.is_a?(Clickatell::API::Error)
    clickatell_error.code == '001' # #<Clickatell::API::Error code='001' message='Authentication error'>
  end
end

# The built-in ping method requires specifying the session, but it's no fun thinking through what happens
# when your session expires while you're running a ping... yuck.  This gets around it by using the
# current clickatell_connection's session ID
class Clickatell::API
  def ping_with_current_session_id
    ping(auth_hash[:session_id])
  end

  def route_coverage(number)
    execute_command('routeCoverage.php', 'utils', :msisdn => number.to_s, :session_id => auth_hash[:session_id])
  end
end