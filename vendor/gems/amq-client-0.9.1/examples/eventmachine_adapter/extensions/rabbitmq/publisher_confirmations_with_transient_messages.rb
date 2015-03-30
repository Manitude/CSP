#!/usr/bin/env ruby
# encoding: utf-8

__dir = File.dirname(File.expand_path(__FILE__))
require File.join(__dir, "..", "..", "example_helper")

require "amq/client/extensions/rabbitmq/confirm"

amq_client_example "Publisher confirmations using RabbitMQ extension: routable message scenario" do |client|
  channel = AMQ::Client::Channel.new(client, 1)
  channel.open do
    puts "Channel #{channel.id} is now open"

    channel.confirm_select
    channel.on_error do
      puts "Oops, there is a channel-levle exceptions!"
    end


    channel.on_ack do |basic_ack|
      puts "Received basic_ack: multiple = #{basic_ack.multiple}, delivery_tag = #{basic_ack.delivery_tag}"
    end

    x = AMQ::Client::Exchange.new(client, channel, "amq.fanout", :fanout)

    q = AMQ::Client::Queue.new(client, channel, AMQ::Protocol::EMPTY_STRING)
    q.declare(false, false, true, true) do |_, declare_ok|
      puts "Defined a new server-named queue: #{q.name}"

      q.bind("amq.fanout").consume(false, true, true) { |consume_ok|
        puts "Received basic.consume-ok"
      }.on_delivery do |method, header, payload|
        puts "Received #{payload}"
      end
    end

    EM.add_timer(0.5) do
      10.times { |i| x.publish("Message ##{i}", AMQ::Protocol::EMPTY_STRING, { :delivery_mode => 2 }, true) }
    end



    show_stopper = Proc.new {
      client.disconnect do
        puts
        puts "AMQP connection is now properly closed"
        EM.stop
      end
    }

    Signal.trap "INT",  show_stopper
    Signal.trap "TERM", show_stopper

    EM.add_timer(3, show_stopper)
  end
end
