# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

# This class is intended to be inherited from when you create an agent class
class Granite::BaseAgent
  include Granite::Agent

  class << self

    # these method are all setters (decorators) and readers...
    # note that these take splatted (multiple) arguments, not arrays.

    # note that the actor accepts either a single string or an array for this argument, and converts everything to an array
    def exchange_names(*args)
      if args.any? && (args.first.is_a?(Array) || args.size == 1)
        @exchange_names = args.first
      elsif args.any? # multiple, splatted-style args. use array.
        @exchange_names = args
      end
      @exchange_names ||= self.to_s.underscore.sub(/_agent$/, '')
    end

    def exchange_name(*args)
      raise ArgumentError.new('Hey, just one argument to exchange_name decorator, please') if args.any? && args.size != 1
      exchange_names(args.first)
    end

    def process_method(method_to_set = nil)
      if method_to_set
        @process_method = method_to_set
      end
      @process_method ||= :process
    end


    # Set the queue parameters (for ALL queues). Argument is a hash with values being booleans (except for the name).
    # Valid keys are
    # :name         the name of the queue, defaults to the agent's demodulized classname
    # :auto_delete  whether or not the queue is deleted when there are no consumers
    # :exclusive    whether or not the queue allows only one consumer
    # :durable      whether or not the messages are persisted to disk in case of failure
    def queue_params(queue_param_hash = nil)
      if(queue_param_hash)
        @queue_params = queue_param_hash
      end
      @queue_params
    end

    # note: if you're listening to multiple exchanges, exchange_type and routing-related overrides will apply to all of them. 
    # if you need more flexibility than that, you may need to override agentize_options (call super and then merge in your stuff).
    # you may even need to call agentize multiple times. see controller_agent.rb for an example of that.
    def exchange_type(exchange_type_to_set = nil)
      if exchange_type_to_set
        @exchange_type = exchange_type_to_set
      end
      @exchange_type
    end

    def routing_keys(*args)
      args.each do |routing_key|
        @routing_keys ||= []
        @routing_keys << routing_key
      end
      @routing_keys
    end

    def routing_key(key)
      routing_keys(key)
    end

    def routing_words(*args)
      args.each do |routing_word|
        @routing_words ||= []
        @routing_words << routing_word
      end
      @routing_words
    end

    def routing_word(word)
      routing_words(word)
    end

  end # class << self

  def initialize
    agentize(agentize_options)
  end

private

  # THESE DELEGATED INSTANCE METHODS CAN BE OVERRIDEN IN YOUR AGENT, BUT CONSIDER CUSTOMIZING YOUR AGENT USING THE DECORATOR-STYLE METHODS ABOVE
  # See https://opx.lan.flt/export/HEAD/app_launcher/trunk/doc/story/html/granite.html?format=raw#TOC_6 for an example of overriding everything
  delegate :exchange_names, :process_method, :exchange_type, :routing_keys, :routing_words, :queue_params, :to => :klass

  # returns something like [] or [{:key => '#.hot.#'}, {:key => '#.nothot.'#'}]
  def specified_bindings
    keys = []
    routing_words && routing_words.each do |routing_word|
      keys << "#.#{routing_word}.#"
    end
    keys += routing_keys if routing_keys
    keys.map {|key| {:key => key} }
  end

  def agentize_options
    options = {:method => process_method, :exchanges => exchange_names}
    options.merge!(:message_parsers => message_parsers) if private_methods.map(&:to_sym).include?(:message_parsers)
    options.merge!(:type => exchange_type) if exchange_type
    options.merge!(:bindings => specified_bindings) if specified_bindings.any?
    options.merge!(:queue => queue_params) if queue_params
    options
  end

  # note: define a private method called message_parsers if you need to override the default behavior from Granite::Actor, for example:
  # def message_parsers
  #   {'/curriculums/update' => :process_curriculums_update_xml, '/syncing/upload_progress' => :process_upload_progress_xml}
  # end
  #
  # uncomment this method if you do not want your agent to retry failed messages
  # def use_raider(exchange=nil)
  #   false
  # end
end

# hopefully someday we can do this:
# Granite::Agent = Granite::BaseAgent
