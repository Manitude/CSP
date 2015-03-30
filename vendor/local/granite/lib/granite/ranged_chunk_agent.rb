require 'benchmark'

module Granite
  if Granite::Configuration.all_settings['enable_ranged_chunk_agents'] && Granite::Configuration.all_settings['enable_ranged_chunk_agents'] != 'false'
    class RangedChunkAgent < ActiveRecord::Base
  
      LOCK_TIMEOUT = 1
  
      class NotChunkableAgentError < StandardError; end
  
      validate :chunk_size_or_chunks
      validates_presence_of :agent_class
      class << self
        def run_agents
          all.each do |ranged_chunk_agent|
            begin
              ranged_chunk_agent.run if ranged_chunk_agent.should_run?
            rescue Exception => exception
              RosettaStone::GenericExceptionNotifier.deliver_exception_notification(exception)
            end
          end
        end
      end
  
      def should_run?
        # this should check mutex
        enabled? && past_run_interval?
      end
  
      def past_run_interval?
        return true if last_processed_timestamp.nil? # let's run it if we've never run it
        Time.now.to_i >= (last_processed_timestamp + (interval || 0).seconds).to_i
      end
  
      def with_application_lock
        RangedChunkAgent.application_lock(lock_name, LOCK_TIMEOUT) do
          yield
        end
      end
      
      def lock_name
        "ranged_chunk_agent:" + agent_class
      end
      
      def locked?
        result = Granite::RangedChunkAgent.connection.select_one(%Q[SELECT IS_FREE_LOCK('#{lock_name}') as RESULT])
        if result && result['RESULT']
          return result['RESULT'].to_i == 0
        else
          raise Exception.new("Unexpected result from IS_FREE_LOCK query.")
        end
      end
      
      def unlock!
        result = Granite::RangedChunkAgent.connection.select_one(%Q[SELECT RELEASE_LOCK('#{lock_name}') as RESULT])
        if result && result['RESULT']
          return result['RESULT'].to_i == 1
        else
          raise Exception.new("Unexpected result from RELEASE_LOCK query.")
        end
      end
      
      def with_chunk_benchmarking
        chunking_time = Benchmark.measure { yield }.milliseconds
        if self.respond_to?(:last_chunking_time)
          self.update_attribute(:last_chunking_time, chunking_time)
        end
      end

      def run
        with_chunk_benchmarking do
          with_application_lock do 
            yield if block_given? # for tests. blargle margle.
            self.per_chunk do |chunk|
              if agent < Granite::BaseAgent
                RangedChunkProducer.publish(chunk.to_s, {:key => self.routing_key})
              else
                agent.new.process({}, chunk.to_s)
              end
            end
          end
        end
      end
  
      def routing_key
        self.agent_class
      end
  
      def per_chunk
        now = Time.now
        new_range = calculate_new_range
        calculated_chunk_size = chunk_by_size? ? chunk_size : (new_range.count - 1)/chunks
        if calculated_chunk_size == 0 # nothing has happend. still record that the agent has moved on.
          self.update_attribute(:last_processed_timestamp, now)
        else 
          cursor = chunk_by_size(calculated_chunk_size, new_range) do |chunk_range|
            yield chunk_range
          end
          self.update_attributes({:cursor => cursor, :last_processed_timestamp => now})
        end
      end
  
      # Using ActiveSupport's blockless step
      # range.step(n) will return an array of object, beginning with the first element, and going through to the highest it can, below the last element.
      # Example: 
      # > (123..234).step(12) 
      # => [123, 135, 147, 159, 171, 183, 195, 207, 219, 231]
      # The upper cursor in this case would be 231.
      #
      # This code assumes that agents know to be right-exclusive. 
      def chunk_by_size(the_size, new_range)
        if new_range.begin >= new_range.end
          return new_range.end
        end
        upper_cursor = new_range.min
        range_arr = new_range.step(the_size)
        range_arr.each_with_index do |cursor, ii|
          upper_cursor = range_arr[ii+1] || upper_cursor
          yield((cursor..upper_cursor)) unless upper_cursor == cursor
        end
        return upper_cursor
      end
  

    private

      def chunk_size_or_chunks
        errors.add(:chunk_size, "OR chunks (not both).") if self.chunk_size && self.chunks
        errors.add(:chunk_size, "or chunks must be set.") if self.chunk_size.blank? && self.chunks.blank?
      end


      def chunk_by_size?
        !self.chunk_size.blank?
      end

      # we don't want to call this but once.
      def calculate_new_range
        agent.new_range(self.reload.cursor)  # rescue and reraise something nice and descriptive
      rescue NoMethodError => e
        raise NotChunkableAgentError.new("Agent #{agent} does not have a 'new_range' method. Please add this.")
      end

      def agent
        agent_class.constantize
      end

    end
  else
    # to prevent Expected to define Granite::RangedChunkAgent (LoadError)
    class RangedChunkAgent
    end
  end
end
