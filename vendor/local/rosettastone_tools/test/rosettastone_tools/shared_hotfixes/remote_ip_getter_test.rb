require File.expand_path('../../../test_helper', __FILE__)

if Rails::VERSION::MAJOR >= 3
  class RemoteIpGetterHotfixTest < Test::Unit::TestCase
    def test_basic_resolution
      assert_equal '24.1.1.1', ip_for('REMOTE_ADDR' => '24.1.1.1').to_s
    end

    def test_resolution_with_proxy
      env = {
        'REMOTE_ADDR' => '127.0.0.1', # local reverse proxy
        'HTTP_X_FORWARDED_FOR' => [
          '10.2.2.2', # client machine on subnet
          '24.2.2.2', # client's router public address
          '10.3.3.3', # load balancer reverse proxy (from app server's perspective)
        ].join(',')
      }
      assert_equal '24.2.2.2', ip_for(env).to_s
    end

    # The practical case this emulates is one in which we have some IP address-based
    # rights restriction on a trusted remote IP (50.50.50.50). While it's impossible
    # to hit our load balancers as 50.50.50.50 through IP spoofing since the SYN-ACK
    # handshake would be impossible, it would be possible to pass it through the
    # HTTP X-Forwarded-For header. A heuristic that, say, uses the first IP address
    # in the forwarding chain, would mistakenly lead to granting the client the
    # priviliges that come with owning 50.50.50.50 even though he doesn't own it.
    #
    # Rack 1.2.5 uses such a method, and Rack 1.2.5's request IP address determiner
    # cannot be trusted for security purposes.
    def test_resolution_with_forgery_attempt
      env = {
        'REMOTE_ADDR' => '10.3.3.3', # load balancer
        'HTTP_X_FORWARDED_FOR' => [
          '50.50.50.50', # client machine on subnet (with public-like IP)
          '24.2.2.2', # client's router public address
        ].join(',')
      }
      assert_equal '24.2.2.2', ip_for(env).to_s
    end

    def test_resolution_with_full_trust
      env = {
        'REMOTE_ADDR' => '10.3.3.3', # load balancer
        'HTTP_X_FORWARDED_FOR' => '10.4.4.4' # local network client's IP
      }
      assert_equal '10.4.4.4', ip_for(env).to_s
    end

    def test_client_ip_gets_thrown_out
      env = {
        'REMOTE_ADDR' => '10.3.3.3', # load balancer
        'HTTP_X_FORWARDED_FOR' => [
          '127.0.0.1', # client's own reverse proxy
          '10.1.1.1', # client's subnet ip
          '7.7.7.7' # client's forward proxy
        ].join(','),
        'HTTP_CLIENT_IP' => '127.0.0.1' # set maliciously or by the client's router
      }
      assert_not_equal '127.0.0.1', ip_for(env).to_s # explicitly demonstrating what we don't want to happen
      assert_equal '7.7.7.7', ip_for(env).to_s
    end

  private

    def ip_for(env)
      if Rails::VERSION::MINOR >= 2
        getter = ActionDispatch::RemoteIp::GetIp.new(
          env, # rack env
          ActionDispatch::RemoteIp.new(
            Rails.application,
            false # check ip spoofing
            # no need to set custom proxies because a default is available at RemoteIp::TRUSTED_PROXIES
          )
        )
        getter.calculate_ip
      else
        ActionDispatch::RemoteIp::RemoteIpGetter.new(
          env, # rack env
          false, # check ip spoofing
          /^127\.0\.0\.1|^10\./ # trusted proxy regex
        )
      end
    end
  end
end
