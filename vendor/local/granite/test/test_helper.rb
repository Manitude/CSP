# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../../../config/environment', File.dirname(__FILE__)) unless defined?(RAILS_ROOT)

# grr.  Bunny::Client doesn't autoload because the file is named client08.rb.  so, kick it once.
Bunny.new.class unless defined?(Bunny::Client)

class ActiveSupport::TestCase

  def purge_all_queues!
    queues_to_purge = Rabbit::Helpers.queues('test')
    queues_to_purge.each do |qname|
      Rabbit::Helpers.purge_queue(qname, 'test')
    end

    # for our sanity:
    queues_to_purge.each do |queue|
      assert_queue_empty(queue)
    end
  end

  def delete_all_queues!
    queues_to_delete = Rabbit::Helpers.queues('test')
    queues_to_delete.each do |qname|
      Rabbit::Helpers.delete_queue(qname, 'test')
    end
  end


  def generate_status_message(id, currently_processing_job, number_of_jobs_processed, exchanges, queues, host = '127.0.0.1', pid = 1)
    Granite::AgentStatus.new(Granite::AgentStatus::STATUS, id, {:currently_processing_job => currently_processing_job, :number_of_jobs_processed => number_of_jobs_processed, :exchanges => exchanges, :queues => queues, :host => host, :pid => pid})
  end

  def assert_queue_empty(queue)
    status = Rabbit::Helpers.status_for_queue(queue)
    assert_equal 0, status[:message_count]
  end

  def assert_agent_event(agent, event_type, proc, timeout = 4)
    assert_nothing_raised do
      Timeout.timeout(timeout) do
        test_proc = lambda {}
        test_proc.expects(:call).at_least_once
        agent.add_event_listener(event_type, test_proc)
        agent.add_event_listener(event_type, proc)
      end
    end
  end

  class << self
    alias_method :test_before_timer, :test

    def test(description, timeout = 8, &block)
      new_test = lambda do
        assert_nothing_raised do
          Timeout.timeout(timeout) do
            instance_eval &block
          end
        end
      end

      test_before_timer(description, &new_test)
    end

  end

end

module AgentOutputLogger
  IO = StringIO.new

  def self.output
    IO.string
  end

  def self.reset!
    IO.reopen
  end
end
