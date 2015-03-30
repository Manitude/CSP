require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::AgentStatusTest < ActiveSupport::TestCase

  test 'create valid hash' do
    hash = {:id => 'Mr. Stupendous', :processing_job => true, :number_of_jobs_processed => 23, :type => Granite::AgentStatus::STATUS, :exchanges => ['/test-exchange'], :queues => ['/test-queue'], :host => '127.0.0.1', :pid => 333}
    assert_nothing_raised do
      Granite::AgentStatus.expects(:local_ip).returns('127.0.0.1')
      Process.expects(:pid).returns(333)

      status = Granite::AgentStatus.status('Mr. Stupendous', {:processing_job => true, :number_of_jobs_processed => 23, :exchanges => ['/test-exchange'], :queues => ['/test-queue']})
      assert_equal 'Mr. Stupendous', status.id
      assert_equal Granite::AgentStatus::STATUS, status.type
      assert_equal true, status.processing_job
      assert_equal 23, status.number_of_jobs_processed
      assert_equal 1, status.exchanges.size
      assert_equal 1, status.queues.size
      assert_equal '/test-exchange', status.exchanges[0]
      assert_equal '/test-queue', status.queues[0]
      assert_equal '127.0.0.1', status.host
      assert_equal 333, status.pid
      stat_hash = status.to_hash
      assert_equal hash, stat_hash
    end
  end

  test 'create valid job' do
    guid = RosettaStone::UUIDHelper.generate
    now = Time.now

    Granite::AgentStatus.stubs(:local_ip).returns('127.0.0.1')
    Process.stubs(:pid).returns(333)
    Time.stubs(:now).returns(now)
    RosettaStone::UUIDHelper.stubs(:generate).returns(guid)

    # job = {:payload => {:type => Granite::AgentStatus::STATUS, :id => 'Mr. Stupendous', :processing_job => true, :number_of_jobs_processed => 23, :exchanges => ['/test-exchange'], :queues => ['/test-queue'], :host => '127.0.0.1', :pid => 333}, :job_guid => guid, :timestamp => now.to_i, :retries => 0}
    job = Granite::Job.create({:type => Granite::AgentStatus::STATUS, :id => 'Mr. Stupendous', :processing_job => true, :number_of_jobs_processed => 23, :exchanges => ['/test-exchange'], :queues => ['/test-queue'], :host => '127.0.0.1', :pid => 333})

    assert_nothing_raised do
      status = Granite::AgentStatus.status('Mr. Stupendous', {:processing_job => true, :number_of_jobs_processed => 23, :exchanges => ['/test-exchange'], :queues => ['/test-queue']})
      assert_equal 'Mr. Stupendous', status.id
      assert_equal Granite::AgentStatus::STATUS, status.type
      assert_equal true, status.processing_job
      assert_equal 23, status.number_of_jobs_processed
      assert_equal 1, status.exchanges.size
      assert_equal 1, status.queues.size
      assert_equal '/test-exchange', status.exchanges[0]
      assert_equal '/test-queue', status.queues[0]
      assert_equal '127.0.0.1', status.host
      assert_equal 333, status.pid
      stat_job = status.to_job
      assert_equal job, stat_job
    end
  end

  test 'test attempt to parse invalid payload data' do
    hash = {:identity => 'Mr. Stupendous', :processing_job => true, :number_of_jobs_processed => 23, :type => Granite::AgentStatus::STATUS, :exchanges => ['/test-exchange'], :queues => ['/test-queue'], :host => '127.0.0.1', :pid => 333}
    assert_raise Granite::AgentStatus::AgentStatusParseError do
      status = Granite::AgentStatus.from_payload(hash)
    end
  end

  test 'create valid status from hash with symbol keys' do
    hash = {:id => 'Mr. Stupendous', :processing_job => true, :number_of_jobs_processed => 23, :type => Granite::AgentStatus::STATUS, :exchanges => ['/test-exchange'], :queues => ['/test-queue'], :host => '127.0.0.1', :pid => 333}
    assert_nothing_raised do
      status = Granite::AgentStatus.from_payload(hash)
      assert_equal 'Mr. Stupendous', status.id
      assert_equal true, status.processing_job
      assert_equal Granite::AgentStatus::STATUS, status.type
      assert_equal 23, status.number_of_jobs_processed
      assert_equal 1, status.exchanges.size
      assert_equal 1, status.queues.size
      assert_equal '/test-exchange', status.exchanges[0]
      assert_equal '/test-queue', status.queues[0]
      assert_equal '127.0.0.1', status.host
      assert_equal 333, status.pid
    end
  end

  test 'create valid status from hash with string keys' do
    hash = {'id'=> 'Mr. Stupendous', 'processing_job'=> true, 'number_of_jobs_processed'=> 23, 'type' => Granite::AgentStatus::STATUS, 'exchanges' => ['/test-exchange'], 'queues' => ['/test-queue'], 'host' => '127.0.0.1', 'pid' => 333}
    assert_nothing_raised do
      status = Granite::AgentStatus.from_payload(hash)
      assert_equal 'Mr. Stupendous', status.id
      assert_equal true, status.processing_job
      assert_equal Granite::AgentStatus::STATUS, status.type
      assert_equal 23, status.number_of_jobs_processed
      assert_equal 1, status.exchanges.size
      assert_equal 1, status.queues.size
      assert_equal '/test-exchange', status.exchanges[0]
      assert_equal '/test-queue', status.queues[0]
      assert_equal '127.0.0.1', status.host
      assert_equal 333, status.pid
    end
  end

  test 'valid job from initialize' do
    guid = RosettaStone::UUIDHelper.generate
    now = Time.now

    Granite::AgentStatus.stubs(:local_ip).returns('127.0.0.1')
    Process.stubs(:pid).returns(333)
    Time.stubs(:now).returns(now)
    RosettaStone::UUIDHelper.stubs(:generate).returns(guid)

    job = Granite::Job.create({:host=> '127.0.0.1', :id => 'Spaceman Spiff', :type => 'unregister', :pid => 333})
    assert_nothing_raised do
      reg = Granite::AgentStatus.new(Granite::AgentStatus::UNREGISTER,'Spaceman Spiff').to_job
      assert_equal job, reg
    end
  end

  test 'local_ip' do
    ip = Granite::AgentStatus.local_ip
    assert_true(ip.is_a?(String))
    assert_match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, ip)
  end

  test 'local_ip_for_routing_key' do
    ip = Granite::AgentStatus.local_ip_for_routing_key
    assert_true(ip.is_a?(String))
    assert_match(/^\d{1,3}_\d{1,3}_\d{1,3}_\d{1,3}$/, ip)
  end
end
