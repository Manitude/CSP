require 'ostruct'

class Granite::AgentStatus < OpenStruct
  class AgentStatusParseError < StandardError; end

  UNREGISTER = 'unregister'
  STATUS = 'status'

  # type: type of event, UNREGISTER or STATUS
  # id: the identity of the sender
  # opts: hash of anything else to store
  def initialize(type, id, opts = {} )
    super({:id => id, :type => type, :pid => Process.pid, :host => Granite::AgentStatus.local_ip}.merge(opts))
  end

  [:id, :type].each do |meth|
    define_method(meth) do
      @table[meth]
    end
  end

  def to_job
    Granite::Job.create(to_hash)
  end

  def to_hash
    instance_values["table"]
  end

  class << self
    def status(id, opts = {})
      new(STATUS, id, opts)
    end

    def unregister(id, opts = {})
      new(UNREGISTER, id, opts)
    end

    def from_payload(job_payload)
      required_keys = [:type, :id, :host, :pid]
      job_payload = job_payload.deep_symbolize_keys
      raise AgentStatusParseError, "Agent status must have values for these keys: #{required_keys.join(', ')}" unless job_payload.is_a?(Hash) && required_keys.all? {|key| job_payload.has_key?(key) && !job_payload[key].nil?}
      new(job_payload[:type], job_payload[:id], job_payload)
    end

    def local_ip
      @ip ||= UDPSocket.open do |socket|
        # connect does not actually connect to the remote machine b/c it is using UDP. It just makes a system call that figures out how to route the packets to that address
        socket.connect Rabbit::Config.get().host, 1
        socket.addr.last
      end
    end

    # replace .'s with _'s for use in AMQP routing keys
    def local_ip_for_routing_key
      local_ip.gsub(/\./, '_')
    end
  end
end
