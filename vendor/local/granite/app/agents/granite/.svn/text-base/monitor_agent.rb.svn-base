class Granite::MonitorAgent
  include Granite::Agent
  include Granite::AgentMonitoring

  def initialize
    # Stores the status of all agents on all vhosts in a 2-D hash keyed on vhost name and then on Agent id
    @status_table ||= {}

    Granite::MonitorConfiguration.vhosts.each do |vhost|
      @status_table[vhost] ||= {}

      if vhost.downcase == Granite.app_name.downcase
        connection = nil
      else
        connection = "#{vhost}_#{Framework.env}"
      end

      method = lambda do |header, message|
        status = process_agent_heartbeat(header, message, nil)
        @status_table[vhost][status.id] ||= {}
        @status_table[vhost][status.id] = status
      end

      agentize({
        :exchanges => Granite::Agent::STATUS_EXCHANGE,
        :connection => connection,
        :method => method,
        :queue => {:name => identity, :exclusive => true, :durable => false, :auto_delete => true}
      }.merge(Granite::Agent::STATUS_EXCHANGE_OPTIONS))
    end
  end

  def start &blk
    default_start {|agent|
      setup_dead_agent_finder
      yield if block_given?
    }
  end

  def vhost_status(vhost_name = nil)
    return @status_table if vhost_name.nil?
    return @status_table[vhost_name]
  end

  def use_raider(exchange)
    false
  end
end
