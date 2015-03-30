require File.expand_path('../test_helper', File.dirname(__FILE__))

class AgentLogTester
  include Granite::AgentLog
  cattr_accessor :log_io

end

class Granite::AgentLogTest < ActiveSupport::TestCase
  test 'logging reopens file if time since last stat is longer than set value' do
    now = Time.now

    Time.stubs(:now).returns(now)

    file = File.new('/tmp/agent_log_test.log', 'w+')
    test_agent = AgentLogTester.new
    test_agent.log_io = file
    test_agent.instance_variable_set(:@time_last_checked_log_stat, now.milliseconds - 45000)
    test_agent.instance_variable_set(:@inode, 1)

    file_stat = file.stat
    file_stat.expects(:ino).returns(2)

    test_agent.log_io.expects(:stat).returns(file_stat)


    file.expects(:reopen).with('/tmp/agent_log_test.log')
    
    test_agent.agent_log "test message", Logger::ERROR
  end
end
