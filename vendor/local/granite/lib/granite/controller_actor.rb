class Granite::ControllerActor < Granite::Actor

  # Overriding Actor.call_message_handler to pass the timestamp as well as the header and message
  def call_message_handler(header, job)
    exchange = header.exchange

    log_benchmark("processing #{exchange} for job_guid #{job.job_guid}") do
      @handler.call(header, job.payload, job.timestamp)
    end
    @parent.record_execution_time!(RosettaStone::Benchmark.most_recent_benchmark)
  end
end
