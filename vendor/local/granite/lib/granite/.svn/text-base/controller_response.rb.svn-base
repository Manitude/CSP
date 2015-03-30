class Granite::ControllerResponse
  class ResponseParseError < StandardError; end

  attr_reader :opts

  def self.create_class_method(name)
    (class << self; self; end).send(:define_method, name) do
      new(self.const_get(name.upcase))
    end
  end

  # Create constants and matching class methods to create responses associated with those constants
  RESPONSES = %w(ok error ack)

  RESPONSES.each do |response|
    self.const_set(response.upcase, response)
    create_class_method(response)
  end

  def initialize(response, opts={})
    @response = response unless RESPONSES.index(response).nil?
    @opts = opts.nil? ? {} : opts
  end

  def set_opts(val)
    @opts = val
    self
  end

  def to_hash
    @opts.merge(:response => @response) # ensure that the response is correct
  end

  def to_job
    Granite::Job.create(to_hash)
  end

  def self.from_payload(payload)
    raise ResponseParseError, "Response must have values for these keys: #{RESPONSES.join(', ')}" unless job_payload.is_a?(Hash) && !job_payload[:response].nil? && !RESPONSES.index(job_payload[:response]).nil?
    response = job_payload.delete(:response)
    self.new(response, job_payload)
  end
end
