# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::LockingTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_access_request_response_with_session_details_history_id
    xml = %Q[
      <response license_server_version="1.0">
      <access_request>
        <session_history_id>123456</session_history_id>
        <session_details_history_id>789</session_details_history_id>
      </access_request>
      </response>
    ]

    opts = {:license => 'test', :product => 'ESP', :family => 'application', :version => 3}
    ApiCommunicator.any_instance.expects(:api_call).with('locking', 'access_request', opts).at_least(1).returns(xml)

    assert_equal({'session_history_id' => '123456', 'session_details_history_id' => '789'}, @ls.locking.access_request(opts))
  end

  def test_access_request_lock_failure
    xml = %q[<response license_server_version="1.0"><exception type="license_is_locked_exception">An error occurred during processing this request.</exception></response>]

    opts = {:license => 'test', :product => 'ESP', :family => 'application', :version => 3}
    ApiCommunicator.any_instance.expects(:api_call).with('locking', 'access_request', opts).at_least(1).returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::LicenseIsLockedException) { @ls.locking.access_request(opts) }
  end

  def test_continuation
    xml = %q[<response license_server_version="1.0"><message type="success">continuation</message></response>]

    opts = {:license => 'test', :session_history_id => '123'}
    ApiCommunicator.any_instance.expects(:api_call).with('locking', 'continuation', opts).at_least(1).returns(xml)

    assert @ls.locking.continuation(opts)
  end

  def test_termination
    xml = %q[<response license_server_version="1.0"><message type="success">termination</message></response>]

    opts = {:license => 'test', :session_history_id => '123'}
    ApiCommunicator.any_instance.expects(:api_call).with('locking', 'termination', opts).at_least(1).returns(xml)

    assert @ls.locking.termination(opts)
  end
end
