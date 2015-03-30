# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module EventDispatcher
    class << self
      def included(model)
        model.send(:attr_reader, :listeners)
        model.send(:include, InstanceMethods)
      end
    end

    module InstanceMethods

      # event_type - the event type to listen for.
      # listener - a Proc or Lambda to call when the event is fired. Must accept 1 argument which will be the event
      def add_event_listener event_type, listener
        raise ArgumentError.new("Listener must be a proc or lambda") if !listener.is_a?(Proc)
        @listeners ||= {}
        event_type = event_type.event_type if event_type.respond_to?(:event_type)
        @listeners[event_type] ||= []
        @listeners[event_type] << listener if !@listeners[event_type].include?(listener)
      end

      # event_type - the event type to listen for.
      # listener - a Proc or Lambda to call when the event is fired. Must accept 1 argument which will be the event
      def remove_event_listener event_type, listener
        raise ArgumentError.new("Listener must be a proc or lambda") if !listener.is_a?(Proc)
        @listeners ||= {}
        event_type = event_type.event_type if event_type.respond_to?(:event_type)
        @listeners[event_type] ||= []
        @listeners[event_type].delete(listener)
      end

      def fire_event event
        raise ArgumentError.new("event must respond to :event_type") if !event.respond_to?(:event_type)
        @listeners ||= {}
        @listeners[event.event_type] ||= []
        @listeners[event.event_type].each do |listener|
          listener.call(event)
        end
      end
    end

    module Event
      class << self
        def included(model)
          model.send(:attr_accessor, :event_type)
        end
      end
    end
  end
end
