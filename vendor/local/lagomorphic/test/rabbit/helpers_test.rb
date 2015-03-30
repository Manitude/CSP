require File.expand_path('../test_helper', File.dirname(__FILE__))

class Rabbit::HelpersTest < ActiveSupport::TestCase
  # gah.  ruby-debug can't handle a StringIO for $stdout.  pass disable_mocking_stdout=true
  def self.disable_mocking_stdout?
    !ENV['disable_mocking_stdout'].nil? && ENV['disable_mocking_stdout'] != 'false'
  end

  def setup
    # we prefix this onto vhosts or users that we create in tests so we can make sure
    # we clean them up properly:
    @global_item_prefix = (App.name rescue rand(1000)).to_s + '_helpers_test_'
    @queues_to_delete = []
    @vhosts_to_delete = []
    @users_to_delete = []

    reload_rabbit_config! # try to clear out anything messed up my mocking the config in other tests

    unless klass.disable_mocking_stdout?
      @old_stdout = $stdout
      @stdout = $stdout = StringIO.new
    end
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Rabbit::Connection.test_mode = false # we want to actually talk to rabbit for a few of these tests
  end

  def teardown
    @queues_to_delete.each do |q|
      begin
        Rabbit::Helpers.delete_queue(q)
      rescue => e
        puts e
      end
    end

    @vhosts_to_delete.each do |v|
      begin
        Rabbit::Helpers.delete_vhost!(v) if Rabbit::Helpers.vhost_exists?(v)
      rescue => e
        puts e
      end
    end

    @users_to_delete.each do |u|
      begin
        Rabbit::Helpers.delete_user!(u) if Rabbit::Helpers.user_exists?(u)
      rescue => e
        puts e
      end
    end

    unless klass.disable_mocking_stdout?
      $stdout = @old_stdout
    end

    extra_vhosts = Rabbit::Helpers.vhosts.select {|vhost| vhost.starts_with?(@global_item_prefix) }
    if extra_vhosts.any?
      extra_vhosts.each {|vhost| Rabbit::Helpers.delete_vhost!(vhost)}
      flunk "This test added vhosts. Please clean it up: #{extra_vhosts.inspect}"
    end
    extra_users = Rabbit::Helpers.users.select {|user| user.starts_with?(@global_item_prefix) }
    if extra_users.any?
      extra_users.each {|user| Rabbit::Helpers.delete_user!(user)}
      flunk "This test added users. Please clean it up: #{extra_users.inspect}"
    end

    Rabbit::Helpers.output_commands = true
    Rabbit::Connection.test_mode = true
  end

  if Rabbit::Helpers.check_system?
    test 'list vhosts' do
      vhosts = Rabbit::Helpers.vhosts
      assert_true(vhosts.is_a?(Array))
      assert_true(vhosts.include?('/'))
    end

    test 'create and delete vhost' do
      vhost_name_that_does_not_exist = "#{@global_item_prefix}create_and_delete_vhost_#{Time.now.milliseconds}"
      assert_false(Rabbit::Helpers.vhost_exists?(vhost_name_that_does_not_exist))
      assert_true(Rabbit::Helpers.add_vhost!(vhost_name_that_does_not_exist))
      assert_true(Rabbit::Helpers.vhost_exists?(vhost_name_that_does_not_exist))
      assert_true(Rabbit::Helpers.delete_vhost!(vhost_name_that_does_not_exist))
      assert_false(Rabbit::Helpers.vhost_exists?(vhost_name_that_does_not_exist))
    end

    test 'create vhost failure' do
      vhost_name_that_does_not_exist = "#{@global_item_prefix}create_vhost_failure_#{Time.now.milliseconds}"
      assert_true(Rabbit::Helpers.add_vhost!(vhost_name_that_does_not_exist))
      assert_false(Rabbit::Helpers.add_vhost!(vhost_name_that_does_not_exist))
      assert_stdout_matches("vhost '#{@global_item_prefix}create")
      # cleanup
      Rabbit::Helpers.delete_vhost!(vhost_name_that_does_not_exist)
    end

    test 'delete vhost failure' do
      vhost_name_that_does_not_exist = "#{@global_item_prefix}delete_vhost_failue_#{Time.now.milliseconds}"
      assert_false(Rabbit::Helpers.delete_vhost!(vhost_name_that_does_not_exist))
      assert_stdout_matches("vhost '#{@global_item_prefix}delete")
    end

    test 'list users' do
      users = Rabbit::Helpers.users
      assert_true(users.is_a?(Array))
      assert_true(users.include?('guest'))
    end

    test 'create and delete users' do
      user, password = "#{@global_item_prefix}your_mom", "was_here"
      assert_true(Rabbit::Helpers.add_user!(user, password))
      assert_true(Rabbit::Helpers.user_exists?(user))
      assert_true(Rabbit::Helpers.delete_user!(user))
      assert_false(Rabbit::Helpers.user_exists?(user))
    end

    test 'create user failure' do
      user_name_that_does_not_exist = "#{@global_item_prefix}create_user_failure_#{Time.now.milliseconds}"
      assert_true(Rabbit::Helpers.add_user!(user_name_that_does_not_exist, 'blah'))
      assert_false(Rabbit::Helpers.add_user!(user_name_that_does_not_exist, 'blah'))
      assert_stdout_matches("user '#{@global_item_prefix}create")
      assert_true(Rabbit::Helpers.delete_user!(user_name_that_does_not_exist))
    end

    test 'delete user failure' do
      user_name_that_does_not_exist = "#{@global_item_prefix}delete_user_failure_#{Time.now.milliseconds}"
      assert_false(Rabbit::Helpers.delete_user!(user_name_that_does_not_exist))
      assert_stdout_matches("user '#{@global_item_prefix}delete")
    end

    test 'set permissions' do
      with_test_user do |user, vhost|
        assert_true(Rabbit::Helpers.set_permissions(user, vhost))
        assert_match(user, Rabbit::Helpers.list_permissions(vhost))
      end
    end

    test 'publish message and message in queue' do
      message = RosettaStone::UUIDHelper.generate
      queue = RosettaStone::UUIDHelper.generate
      Rabbit::Helpers.publish_message(message, queue)
      assert_true Rabbit::Helpers.message_in_queue?(message, queue)
    end

    test 'message in queue fails when the message isnt there' do
      message = RosettaStone::UUIDHelper.generate
      queue = RosettaStone::UUIDHelper.generate
      Rabbit::Helpers.publish_message('something else', queue)
      assert_false Rabbit::Helpers.message_in_queue?(message, queue)
    end

    test 'test connection fails if the auth or vhost is bad' do
      Bunny::Client.any_instance.expects(:start).raises(Bunny::AuthenticationError)
      assert_raises(Rabbit::AuthenticationError) do
        Rabbit::Helpers.test_connection
      end
    end

    test 'test connection fails if the server is down' do
      Bunny::Client.any_instance.expects(:start).raises(Bunny::ServerDownError)
      assert_raises(Rabbit::ConnectionError) do
        Rabbit::Helpers.test_connection
      end
    end

    test 'list queues' do
      queues = Rabbit::Helpers.queues
      assert_true(queues.is_a?(Array))
    end

    test 'list exchanges' do
      exchanges = Rabbit::Helpers.exchanges
      assert_true(exchanges.is_a?(Array))
    end

    test 'list bindings' do
      bindings = Rabbit::Helpers.bindings
      assert_true(bindings.is_a?(Array))
    end

    test 'purge queue' do
      message = RosettaStone::UUIDHelper.generate
      queue = RosettaStone::UUIDHelper.generate
      Rabbit::Helpers.publish_message(message, queue)
      assert_true Rabbit::Helpers.message_in_queue?(message, queue)

      Rabbit::Helpers.purge_queue(queue)
      assert_false Rabbit::Helpers.message_in_queue?(message, queue)
    end

    test 'delete queue' do
      queue = RosettaStone::UUIDHelper.generate
      Rabbit::Connection.get.with_bunny_connection do |bunny|
        bqueue = bunny.queue(queue)
      end
      queues = Rabbit::Helpers.queues
      assert_true(queues.include?(queue))

      Rabbit::Helpers.delete_queue(queue)

      queues = Rabbit::Helpers.queues
      assert_false(queues.include?(queue))
    end

    test 'delete a certain binding on a queue' do
      exchange_name = RosettaStone::UUIDHelper.generate
      queue_name = RosettaStone::UUIDHelper.generate
      binding_key_one = 'this.hot.key'
      binding_key_two = 'this.hot.other.key'
      queue = nil
      Rabbit::Connection.get.with_bunny_connection do |bunny|
        exchange = bunny.exchange(exchange_name, :type => :topic)
        queue = bunny.queue(queue_name)
        queue.bind(exchange, :key => 'this.hot.key')
        queue.bind(exchange, :key => 'this.hot.other.key')
      end
      
      assert_difference('Rabbit::Helpers.bindings.size', -1) do
        Rabbit::Helpers.unbind_queue_from_exchange_with_binding_key(queue_name, exchange_name, binding_key_one)
      end

      assert_difference('Rabbit::Helpers.bindings.size', -1) do
        Rabbit::Helpers.unbind_queue_from_exchange_with_binding_key(queue_name, exchange_name, binding_key_two)
      end

      assert_no_difference('Rabbit::Helpers.bindings.size') do

        # Error Reply Code: 404
        # Error Reply Text: NOT_FOUND - no binding this.hot.key between exchange '52df22ef-eb5e-44cd-aede-1b3be137a24e' in vhost '/sqrl_test' and queue 'ccaf485d-3db7-4320-a722-20683ba1eaed' in vhost '/sqrl_test'
        assert_raises(Rabbit::ConnectionError) do
          Rabbit::Helpers.unbind_queue_from_exchange_with_binding_key(queue_name, exchange_name, binding_key_one)
        end

      end

      Rabbit::Helpers.delete_queue(queue_name)
      Rabbit::Helpers.delete_exchange(exchange_name)
    end

    test 'delete exchange' do
      exchange = RosettaStone::UUIDHelper.generate

      Rabbit::Connection.get.with_bunny_connection do |bunny|
        bexchange = bunny.exchange(exchange, :type => :fanout)
      end

      exchanges = Rabbit::Helpers.exchanges
      assert_true(exchanges.include?(exchange))

      Rabbit::Helpers.delete_exchange(exchange)

      exchanges = Rabbit::Helpers.exchanges
      assert_false(exchanges.include?(exchange))
    end

    test 'empty_queue_into_queue works in same vhost' do
      @queues_to_delete << 'source_queue'
      @queues_to_delete << 'dest_queue'
      100.times do |i|
        Rabbit::Helpers.publish_message("#{i}", 'source_queue')
      end

      wait_for_queue_count(nil, 'source_queue', 100)

      Rabbit::Connection.get().with_bunny_connection do |b|
        b.queue('dest_queue')
      end

      Rabbit::Helpers.empty_queue_into_other_queue('source_queue', 'dest_queue', nil, nil, {}, {})

      wait_for_queue_count(nil, 'dest_queue', 100)
    end

    test 'empty_queue_into_queue works in different vhost' do
      with_two_test_vhosts do |vhost_1, vhost_2|

        100.times do |i|
          Rabbit::Helpers.publish_message("#{i}", 'source_queue', nil, vhost_1)
        end

        wait_for_queue_count(vhost_1, 'source_queue', 100)

        Rabbit::Connection.get(vhost_2).with_bunny_connection do |b|
          b.queue('dest_queue')
        end

        Rabbit::Helpers.empty_queue_into_other_queue('source_queue', 'dest_queue', vhost_1, vhost_2, {}, {})

        wait_for_queue_count(vhost_2, 'dest_queue', 100)
      end
    end

    test 'empty_queue_into_queue works in different vhost with reply_to' do
      with_two_test_vhosts do |vhost_1, vhost_2|

        100.times do |i|
          Rabbit::Helpers.publish_message("#{i}", 'source_queue', nil, vhost_1, {:reply_to => vhost_1})
        end

        wait_for_queue_count(vhost_1, 'source_queue', 100)

        Rabbit::Connection.get(vhost_2).with_bunny_connection do |b|
          b.queue('dest_queue')
        end

        assert_equal 100, Rabbit::Helpers.empty_queue_into_other_queue('source_queue', 'dest_queue', vhost_1, vhost_2, {}, {}, true)

        wait_for_queue_count(vhost_2, 'dest_queue', 100)

        msg_hash = Rabbit::Helpers.pop('dest_queue', vhost_2, false)
        assert_equal vhost_1, msg_hash[:header].properties[:reply_to]
      end
    end

    test 'empty_queue_into_queue works in different vhost with no reply_to' do
      with_two_test_vhosts do |vhost_1, vhost_2|
        100.times do |i|
          Rabbit::Helpers.publish_message("#{i}", 'source_queue', nil, vhost_1, {:reply_to => vhost_1})
        end

        wait_for_queue_count(vhost_1, 'source_queue', 100)

        Rabbit::Connection.get(vhost_2).with_bunny_connection do |b|
          b.queue('dest_queue')
        end

        assert_equal 100, Rabbit::Helpers.empty_queue_into_other_queue('source_queue', 'dest_queue', vhost_1, vhost_2)

        wait_for_queue_count(vhost_2, 'dest_queue', 100)

        msg_hash = Rabbit::Helpers.pop('dest_queue', vhost_2, false)
        assert_nil msg_hash[:header].properties[:reply_to]
      end
    end
  end

private

  def bunny_client_class
    Bunny.new.class
  end

  def with_test_user
    user, password, vhost = "#{@global_item_prefix}user_#{Time.now.milliseconds}", 'password', "#{@global_item_prefix}test_#{Time.now.milliseconds}"
    Rabbit::Helpers.add_vhost!(vhost)
    Rabbit::Helpers.add_user!(user, password)
    yield user, vhost
  ensure
    Rabbit::Helpers.delete_user!(user)
    Rabbit::Helpers.delete_vhost!(vhost)
  end

  def stdout
    @stdout.string
  end

  def assert_stdout_matches(matcher, message = '')
    assert_match(matcher, stdout, message)
  end

  def with_two_test_vhosts(&block)
    vhost_1 = "#{@global_item_prefix}_vhost_1"
    vhost_2 = "#{@global_item_prefix}_vhost_2"
    user = "#{@global_item_prefix}_user"
    @vhosts_to_delete << vhost_1
    @vhosts_to_delete << vhost_2
    @users_to_delete << user

    Rabbit::Helpers.add_user!(user, 'testing')

    Rabbit::Helpers.add_vhost!(vhost_1)
    Rabbit::Helpers.add_vhost!(vhost_2)

    Rabbit::Helpers.set_permissions(user, vhost_1)
    Rabbit::Helpers.set_permissions(user, vhost_2)

    @config = {
      vhost_1 => {:host => '127.0.0.1', :vhost => vhost_1, :user => user, :password => 'testing'},
      vhost_2 => {:host => '127.0.0.1', :vhost => vhost_2, :user => user, :password => 'testing'},
    }.with_indifferent_access

    Rabbit::Config.stubs(:all_settings).returns(@config)
    configs = @config.map_to_hash {|key, options| { key => Rabbit::Config.new(key)} }
    Rabbit::Config.stubs(:all_configurations).returns(configs)

    yield(vhost_1, vhost_2)

    # we're mocking Rabbit::Config stuff, so we need to clear its cached connections or else it might
    # try to use a cached connection against a vhost that no longer exists...
    Rabbit::Connection.disconnect_all!
  end

  # there seems to be a timing issue when trying to count the number of messages in a queue
  # *immediately* after publishing a number of messages.  a little bit of waiting seems to
  # straighten things out.  this behavior may be rabbitmq version specific, not sure.  it
  # seems to be exacerbated by running rabbitmq on a heavily loaded box.
  def wait_for_queue_count(vhost, queue_name, expected_count, options = {})
    retries = options[:retries] || 3
    delay = options[:delay] || 0.25 # seconds
    count = nil
    while retries > 0
      count = Rabbit::Helpers.message_count(queue_name, vhost)
      return if count == expected_count
      logger.debug("wait_for_queue_count: got #{count}, expected #{expected_count}. waiting.")
      retries -= 1
      sleep delay
    end
    flunk "after #{retries} tries, got #{count}, expected #{expected_count} for queue #{queue_name}"
  end
end
