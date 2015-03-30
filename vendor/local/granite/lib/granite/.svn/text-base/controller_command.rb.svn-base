class Granite::ControllerCommand
  class CommandParseError < StandardError; end

  attr_reader :opts

  def self.create_class_method(name)
    (class << self; self; end).send(:define_method, name) do
      new(self.const_get(name.upcase))
    end
  end

  # Create constants and matching class methods to create commands associated with those constants
  COMMANDS = %w(start stop list restart status purge_dead)

  COMMANDS.each do |command|
    self.const_set(command.upcase, command)
    create_class_method(command)
  end

  def initialize(command, opts={})
    @command = command unless COMMANDS.index(command).nil?
    @opts = opts.nil? ? {} : opts
  end

  def set_opts(val)
    @opts = val
    self
  end

  def to_hash
    @opts.merge(:command => @command) # ensure that the command is correct
  end

  def to_job
    Granite::Job.create(to_hash)
  end

  def self.from_payload(payload)
    raise CommandParseError, "Command must have values for these keys: #{COMMANDS.join(', ')}" unless job_payload.is_a?(Hash) && !job_payload[:command].nil? && !COMMANDS.index(job_payload[:command]).nil?
    command = job_payload.delete(:command)
    self.new(command, job_payload)
  end
end
