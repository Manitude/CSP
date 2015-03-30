require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::KeepAlive::KeepaliveControllerTest < ActionController::TestCase
  tests KeepaliveController

  #hack-city to get the damn route to match
  def setup
    if Rails.version < '3'
      @controller.class.instance_variable_set('@controller_path', 'keepalive')
    else
      # FIXME
      #
      # this code sets the namespaced controller to be the target of the
      # keepalive path. otherwise, TestCase tries to look up a path to
      # RosettaStone::KeepAlive::KeepaliveController when you run something
      # like get :index and fails.
      #
      # putting it in now to make the test work on Rails 3, but if we are
      # going to continue using keepalive in this fashion (maybe not in the
      # face of the Passenger upgrade), it would be prudent to figure out
      # the root cause of Rails 3 thinking that this controller tests the
      # namespaced controller instead of its unnamespaced alias
      Rails.application.routes.draw do
        match 'keepalive' => 'rosetta_stone/keep_alive/keepalive#index'
      end
    end
  end

  def test_warm_up_to_spawns_the_appropriate_number_of_requests
    KeepaliveController.any_instance.expects(:current_process_count).returns(1)
    KeepaliveController.any_instance.expects(:system).with(expected_curl_command).times(25)
    get :index, :warm_up_to => '25'
    assert_response :success
  end

  def test_warm_up_to_with_high_numbers_pegs_at_the_highest_allowed_number
    KeepaliveController.any_instance.expects(:current_process_count).returns(1)
    KeepaliveController.any_instance.expects(:system).with(expected_curl_command).times(KeepaliveController::MAX_WARM_UP_TO)
    get :index, :warm_up_to => (KeepaliveController::MAX_WARM_UP_TO + 10).to_s
    assert_response :success
  end

   def test_warm_up_to_is_ignored_if_there_are_already_more_dispatches_loaded_on_the_machine
    KeepaliveController.any_instance.expects(:current_process_count).returns(20).twice
    KeepaliveController.any_instance.expects(:system).never
    get :index, :warm_up_to => '15'
    assert_response :success
  end

  def test_warm_up_true_makes_the_process_sleep
    KeepaliveController.any_instance.expects(:sleep).with(KeepaliveController::STARTUP_WAIT_TIME)
    get :index, :warm_up => 'true'
    assert_response :success
  end

  def test_users_from_outer_space_can_hit_standard_keepalive
    @request.remote_addr = '209.145.88.41'
    get :index
    assert_response :success
  end

  def test_users_from_outer_space_can_hit_standard_keepalive_with_edster_pingdom
    @request.remote_addr = '209.145.88.41'
    # IT likes to include this so that they know where the requests are coming from
    get :index, :ping => 'pingdom'
    assert_response :success
  end

  def test_users_from_outer_space_cant_hit_keepalive_with_advanced_options_and_hose_us
    @request.remote_addr = '209.145.88.41'
    get :index, :warm_up_to => '25'
    assert_response 404
  end

  def test_num_dispatches_returns_the_current_process_count
    KeepaliveController.any_instance.expects(:current_process_count).returns(10)
    get :index, :num_dispatches => 'true'
    assert_response :success
    assert_equal "10", @response.body.to_s
  end

  if defined?(ActiveRecord)

    def test_active_record_pulse_test_runs_query
      ActiveRecord::Base.connection.expects(:select_one).once
      get :index
      assert_response :success
    end

    def test_active_record_pulse_test_when_query_raises
      ActiveRecord::Base.connection.expects(:select_one).once.raises(ActiveRecord::StatementInvalid)
      assert_raises(ActiveRecord::StatementInvalid) do
        get :index
      end
    end

    def test_check_all_does_nothing_when_no_subclasses
      PulseChecker::ActiveRecord.expects(:check!).never
      PulseChecker::Base.expects(:with_each_subclass).returns([])
      PulseChecker.check_all!
    end

  end # end if defined? ActiveRecord

  private
  def expected_curl_command
    'curl --silent --proxy localhost:80 "test.host/keepalive?warm_up=true" &'
  end
end
