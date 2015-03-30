require File.expand_path('../test_helper', File.dirname(__FILE__))

class Rabbit::ConnectionTest < ActiveSupport::TestCase

  def setup
    reload_rabbit_config!
    @connection = Rabbit::Connection.new
    Rabbit::Connection.test_mode = false

    # grr.  Bunny::Client doesn't autoload because the file is named client08.rb.  so, kick it once.
    Bunny.new.class unless defined?(Bunny::Client)
  end

  def teardown
    Rabbit::Connection.disconnect_all!
    Rabbit::Connection.test_mode = true
  end

  test 'can call get with nil' do
    connection = Rabbit::Connection.get
    assert_equal(Rabbit::Config.get, connection.instance_variable_get('@config'))
  end

  test 'can call get with connection name' do
    connection = Rabbit::Connection.get('test')
    assert_equal(Rabbit::Config.get('test'), connection.instance_variable_get('@config'))
  end

  test 'can call get with config object' do
    connection = Rabbit::Connection.get(Rabbit::Config.get('test'))
    assert_equal(Rabbit::Config.get('test'), connection.instance_variable_get('@config'))
  end

  test 'getting a connection that is already cached does not require reestablishing a connection' do
    connection_1 = Rabbit::Connection.get
    assert_not_nil connection_1.connection
    Rabbit::Connection.any_instance.expects(:establish_connection).never
    connection_2 = Rabbit::Connection.get
    assert_not_nil connection_2.connection # uses the same cached_connection that connection_1 had established
  end

  test 'test_mode' do
    Rabbit::Connection.test_mode = true
    assert_raises(RuntimeError) do
      @connection.connection
    end
  end

  test 'bunny server down error' do
    Bunny::Client.any_instance.expects(:start).raises(Bunny::ServerDownError)
    assert_raises(Rabbit::ConnectionError) do
      @connection.connection
    end
  end

  test 'bunny connection down error' do
    Bunny::Client.any_instance.expects(:start).raises(Bunny::ConnectionError)
    assert_raises(Rabbit::ConnectionError) do
      @connection.connection
    end
  end

  test 'timeout error gets classified as connection error' do
    Bunny::Client.any_instance.expects(:start).raises(Timeout::Error)
    assert_raises(Rabbit::ConnectionError) do
      @connection.connection
    end
  end

  test 'bunny protocol error' do
    Bunny::Client.any_instance.expects(:start).raises(Bunny::AuthenticationError)
    assert_raises(Rabbit::AuthenticationError) do
      @connection.connection
    end
  end

  test 'bunny unknown error' do
    Bunny::Client.any_instance.expects(:start).raises('what')
    assert_raises(Rabbit::UnknownError) do
      @connection.connection
    end
  end

  test 'forced channel close error while trying to disconnect' do
    Bunny::Client.any_instance.expects(:stop).raises(Bunny::ForcedChannelCloseError)
    @connection.connection # establish the connection
    assert_not_nil(@connection.instance_variable_get('@connection'))
    assert_nothing_raised do
      @connection.disconnect!
    end
    assert_nil(@connection.instance_variable_get('@connection'))
  end

  test 'viewable bunny configuration does not have password' do
    viewable_config = @connection.viewable_bunny_configuration
    assert_match(/:user/, viewable_config)
    assert_no_match(/:pass/, viewable_config)
  end

  test 'with_bunny_connection recovers connection' do
    r = Rabbit::Connection.get
    qname = RosettaStone::UUIDHelper.generate
    assert_raises Rabbit::ConnectionError do
      r.with_bunny_connection do |b|
        b.queue(qname, :passive => true) # this will raise
      end
    end
    assert_nothing_raised do
      Timeout.timeout(1) do
        r.with_bunny_connection do |b|
          b.queue(qname, :durable => false)
        end
      end
    end
  end

  Rabbit::Connection.list_of_exceptions_that_require_connection_reset.each do |error_class|
    test "with_bunny_connection reconnects after connection exception #{error_class}" do
      r = Rabbit::Connection.get
      qname = RosettaStone::UUIDHelper.generate

      # make sure we're handling things correctly with variable failure counts. All of these should pass after attempting
      # i times.
      1.upto(3) do |i|
        count = 0
        assert_nothing_raised do
          r.with_bunny_connection(:reconnect_attempts => 3, :reconnect_delay => 0.1) do |b|
            if r.reconnect_attempts < i
              count += 1
              raise error_class.new('Fake exception')
            end
          end
        end
        assert_equal i, r.reconnect_attempts
        assert_equal i, count

        count = 0
        #the connection should still be good even after all the failures
        assert_nothing_raised do
          q = nil
          r.with_bunny_connection(:reconnect_attempts => 3) do |b|
            count += 1
            q = b.queue(qname, :durable => false)
          end
          q.delete
        end
        assert_equal 0, r.reconnect_attempts
        assert_equal 1, count
      end

      #this time we should propagate the error up since it fails MAX times
      count = 0
      assert_raise Rabbit::ConnectionError do
        r.with_bunny_connection(:reconnect_attempts => 3, :reconnect_delay => 0.1) do |b|
          count += 1
          b.queue(qname, :passive => true)
        end
      end
      assert_equal 3, r.reconnect_attempts
      assert_equal 4, count

    end
  end

  test 'with_bunny_connection attempts to reconnect specified number of times' do
    r = Rabbit::Connection.get
    qname = RosettaStone::UUIDHelper.generate
    new_max_times = 10

    # make sure we're handling things correctly with variable failure counts. All of these should pass after attempting
    # i times.
    count = 0
    assert_raise Rabbit::ConnectionError do
      r.with_bunny_connection({:reconnect_attempts => new_max_times, :reconnect_delay => 0.1}) do |b|
        count += 1
        b.queue(qname, :passive => true)
      end
    end

    assert_equal new_max_times, r.reconnect_attempts
    assert_equal new_max_times + 1, count

    count = 0
    #the connection should still be good even after all the failures
    assert_nothing_raised do
      q = nil
      r.with_bunny_connection(:reconnect_attempts => 3) do |b|
        count += 1
        q = b.queue(qname, :durable => false)
      end
      q.delete
    end

    assert_equal 0, r.reconnect_attempts
    assert_equal 1, count
  end

  test "list_of_exceptions_that_require_connection_reset has all Errno values" do
    Errno.constants.each do |c|
      assert_true Rabbit::Connection.list_of_exceptions_that_require_connection_reset.include?("Errno::#{c}".constantize)
    end
  end
end
