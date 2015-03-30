#!/usr/bin/env ruby
# encoding: utf-8

require "bundler"
Bundler.setup

$:.unshift(File.expand_path("../../../lib", __FILE__))
require 'amqp'
require 'amqp/logger'

AMQP.start(:host => 'localhost') do
  if ARGV[0] == 'server'

    AMQP::Channel.new.queue('logger').bind(AMQP::Channel.new.fanout('logging', :durable => true)).subscribe { |msg|
      msg = Marshal.load(msg)
      require 'pp'
      pp(msg)
      puts
    }

  elsif ARGV[0] == 'client'

    log = AMQP::Logger.new
    log.debug 'its working!'

    log = AMQP::Logger.new do |msg|
      require 'pp'
      pp msg
      puts
    end

    log.info '123'
    log.debug [1, 2, 3]
    log.debug :one => 1, :two => 2
    log.error Exception.new('123')

    log.info '123', :process_id => Process.pid
    log.info '123', :process
    log.debug 'login', :session => 'abc', :user => 123

    log = AMQP::Logger.new(:webserver, :timestamp, :hostname, &log.printer)
    log.info 'Request for /', :GET, :session => 'abc'

    AMQP.stop { EM.stop }

  else

    puts
    puts "#{$0} <client|server>"
    puts "  client: send logs to message queue"
    puts "  server: read logs from message queue"
    puts

    EM.stop

  end
end

__END__

{:data => "123", :timestamp => 1216846102, :severity => :info}

{:data => [1, 2, 3], :timestamp => 1216846102, :severity => :debug}

{:data =>
  {:type => :exception, :name => :Exception, :message => "123", :backtrace => nil},
 :timestamp => 1216846102,
 :severity => :error}

{:data => "123", :timestamp => 1216846102, :process_id => 1814, :severity => :info}

{:process =>
  {:thread_id => 109440,
   :process_id => 1814,
   :process_name => "/Users/aman/code/amqp/examples/logger.rb",
   :process_parent_id => 1813},
 :data => "123",
 :timestamp => 1216846102,
 :severity => :info}

{:session => "abc",
 :data => "login",
 :timestamp => 1216846102,
 :severity => :debug,
 :user => 123}

{:session => "abc",
 :tags => [:webserver, :GET],
 :data => "Request for /",
 :timestamp => 1216846102,
 :severity => :info,
 :hostname => "gc"}
