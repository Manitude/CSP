module Granite
  module MonitoringController

    def self.included(model)
      Granite::Agent.all_connections.sort{|a,b| a.first.to_s <=> b.first.to_s}.each do |agent_class, connection|
        queue_name = agent_class.new.queue_name
        url_identifier = agent_class.to_s.underscore.gsub('/', '_')

        model.define_check("#{url_identifier}_message_count", {
          :description => "Number of queued messages in the queue #{queue_name}.  Pass ?threshold=N to make it fail at a given threshold",
          :type => 'granite',
        }) do
          respond_with do
            begin
              number = Rabbit::Helpers.message_count(queue_name, connection)
              threshold = params[:threshold] ? params[:threshold].to_i : 10000
              if number > threshold
                "FAILURE: #{number}"
              else
                "OK: #{number}"
              end
            rescue Rabbit::Error => rabbit_error
              "ERROR: #{rabbit_error}"
            end
          end
        end

        model.define_check("#{url_identifier}_consumer_count", {
          :description => "Number of free consumers for the queue #{queue_name} (running but not working on a job at this moment)",
          :type => 'granite',
        }) do
          respond_with do
            begin
              Rabbit::Helpers.consumer_count(queue_name, connection)
            rescue Rabbit::Error => rabbit_error
              "ERROR: #{rabbit_error}"
            end
          end
        end
      end

      model.define_check("deadletter_message_count", {
        :description => "Number of queued messages in the queue deadletter.  Pass ?threshold=N to make it fail at a given threshold",
        :type => 'granite',
      }) do
        respond_with do
          begin
            has_dead_letter = Rabbit::Helpers.status_for_queue('DeadLetter') rescue false
            if has_dead_letter
              number = Rabbit::Helpers.message_count('DeadLetter', nil)
              threshold = params[:threshold] ? params[:threshold].to_i : 10000
              if number > threshold
                "FAILURE: #{number}"
              else
                "OK: #{number}"
              end
            else
              'NOT CREATED'
            end
          rescue Rabbit::Error => rabbit_error
            "ERROR: #{rabbit_error}"
          end
        end
      end
      if Granite::Configuration.all_settings['enable_ranged_chunk_agents'] && Granite::Configuration.all_settings['enable_ranged_chunk_agents'] != 'false'
        Granite::RangedChunkAgent.all.each do |ranged_chunk_agent|
      
          model.define_check("#{ranged_chunk_agent.agent_class}_last_chunking_time", {
            :description => "The amount of time (in milliseconds) that the agent took to find the new range and publish the chunked jobs",
            :type => 'ranged_chunk'
            }) do
            respond_with do
              begin
                threshold = params[:threshold] ? params[:threshold].to_i : 10000
                number = ranged_chunk_agent.last_chunking_time || 0
                if number > threshold
                  "FAILURE: #{number}"
                else
                  "OK: #{number}"
                end
              rescue Exception => e
                "NOT CONFIGURED PROPERLY: #{e}"
              end
            end
          
          end 
      
        end # Granite::RangedChunkAgent.all
      
        model.define_check("longest_lagging_ranged_chunk_agent", {
          :description => "The time (in milliseconds) of how long ago a ranged chunk agent was last run. Only examines enabled agents.",
          :type => 'ranged_chunk'
        }) do
          respond_with do
            last_processed_furthest_behind = Granite::RangedChunkAgent.find_all_by_enabled(true).map(&:last_processed_timestamp).min
            if last_processed_furthest_behind.nil?
              "NO AGENTS ENABLED"
            else
              threshold = params[:threshold] ? params[:threshold].to_i : 3600000
              number = Time.now.milliseconds - last_processed_furthest_behind.milliseconds
              if number > threshold
                "FAILURE: #{number}"
              else
                "OK: #{number}"
              end
            end
          end
        end # longest_lagging_ranged_chunk_agent
      end # Granite::Configuration.all_settings['enable_ranged_chunk_agents']
    end

  end
end