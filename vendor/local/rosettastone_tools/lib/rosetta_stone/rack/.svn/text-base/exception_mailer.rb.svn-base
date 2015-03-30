# -*- encoding : utf-8 -*-
# -*- coding: UTF-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.
require 'net/smtp'
require 'stringio'
require 'erb'
require 'socket'

module Rack
  # Might want to extract this mailer out of here if found useful elsewhere
  class SimpleMailer
    class RecipientNotSpecified < ArgumentError; end
    CRLF = "\r\n"
    DEFAULT_CONFIG = {
      :host => 'localhost',
      :domain => 'localhost',
      :port => 25
    }.freeze
    NOBODY = 'no_reply@rosettastone.com'.freeze

    attr_reader :config

    # Make sure to provide symbol keys in opts
    def initialize(opts = {})
      @config = DEFAULT_CONFIG.merge(opts).freeze
    end

    def mail(opts)
      opts.keys.each {|k| opts[k.to_sym] = opts[k]} # Contract: keys in opts respond to to_sym

      from       = opts[:from] || NOBODY
      recipients = extract_recipients(opts[:to])

      msg = StringIO.new

      fromto(msg, from, recipients)
      subject(msg, opts)
      date(msg, opts)
      mime(msg, opts)
      msgid(msg, opts)
      type(msg, opts)
      msg << CRLF
      body(msg, opts)

      mailit(msg.string, from, recipients) # The header From/To are not required to match the ones used for smtp.
    end

    private

    def extract_recipients(recipients) # No validations done here
      raise RecipientNotSpecified.new("Missing recipient address(es)") if recipients.nil?

      if recipients.is_a? Array
        recipients.map {|recipient| recipient.strip }
      else
        [recipients.strip]
      end
    end

    def fromto(msg, fromaddr, toaddrs)
      msg << "From: " << fromaddr << CRLF
      msg << "To: " << toaddrs.join(', ') << CRLF
    end

    def subject(msg, opts)
      sub = opts[:subject]
      sub = sub.strip if sub
      msg << "Subject: " << sub << CRLF if !(sub.nil? || sub.empty?)
    end

    def date(msg, opts)
      date = (opts[:date])? opts[:date] : Time.now
      msg << "Date: " << date.strftime("%a, %d %b %Y %H:%M:%S %z") << CRLF
    end

    def mime(msg, opts)
      msg << "MIME-Version: 1.0" << CRLF
    end

    # Base 36 is awesome
    def msgid(msg, opts)
      msg << "Message-ID: <#{Time.now.to_i}.#{rand(36**5).to_s(36)}.#{rand(36**5).to_s(36)}@ruby.simple.mailer>" << CRLF
    end

    # Only text mails
    def type(msg, opts)
      msg << "Content-Type: text/plain; charset=\"utf-8\"" << CRLF if opts[:body] && !opts[:body].empty?
    end

    def body(msg, opts)
      if opts[:body] && !opts[:body].empty?
        msg << opts[:body]
      end
    end

    def mailit(str, fromaddr, toaddrs)
      Net::SMTP.start(config[:host], config[:port], config[:domain]) do |smtp|
        smtp.send_message str, fromaddr, toaddrs
      end
    end

  end

  class ExceptionMailer

    DEFAULT_ENV_KEYS_TO_IGNORE = /action_controller|rack.session.record|rack.session$/
    HOST = Socket.gethostname
    DEFAULT_CONFIG = {
      :to => 'Error Notifier <error_notifier@rosettastone.com>',
      :from => 'Error Notifier <error_notifier@rosettastone.com>'
    }.freeze

    # Stolen from Rack contrib and tweaked a bit
    TEMPLATE = (<<-'EMAIL').gsub(/^ {4}/, '')
    A <%= ex.class.to_s %> occured: <%= ex.to_s %> at <%= Time.now.to_s %><% if @config[:mail_request_body] %><% body = extract_body(env) %><% if body && !body.empty? %>

    ===================================================================
    Request Body:
    ===================================================================

    <%= body.gsub(/^/, '  ') %><% end %><% end %>

    ===================================================================
    Rack Environment:
    ===================================================================

      <%= env.to_a.
        sort{|a,b| a.first <=> b.first}.
        select{|kv| !@ignore.match(kv[0])}.
        map{|k,v| "%-25s%p" % [k+':', v]}.
        join("\n  ") %>
    <% if ex.respond_to?(:backtrace) %>
    ===================================================================
    Backtrace:
    ===================================================================

      <%= ex.backtrace.join("\n  ") %>
    <% end %>
    EMAIL

    attr_reader :mailer, :template, :logger, :config
    def initialize(app, opts = {})
      opts.keys.each {|k| opts[k.to_sym] = opts[k]} # Contract: keys in opts respond to to_sym

      @app = app
      @config = DEFAULT_CONFIG.merge(opts).freeze
      @logger = @config[:logger] || (defined? Rails and (Rails.logger || RAILS_DEFAULT_LOGGER))
      @mailer = (opts[:smtp].is_a? Hash)? SimpleMailer.new(opts[:smtp]) : SimpleMailer.new
      @prefix = (opts[:application])? "[#{opts[:application]}@#{HOST}] - " : "[#{HOST}] - "
      @ignore = Regexp.new(opts[:env_keys_to_ignore]) if opts[:env_keys_to_ignore]
      @ignore ||= DEFAULT_ENV_KEYS_TO_IGNORE
      @template = ERB.new(TEMPLATE)
    end

    def call(env)
      begin
        resp = @app.call(env)
        if err = env['action_controller.rescue.exception'] # Thanks to Rails' stupidity with rescue_action. Set this yourself
          handle_exception(err, env)
        end
        resp
      rescue Exception => ex
        handle_exception(ex, env)
        raise
      end
    end

    def handle_exception(ex, env)
      begin
        mail_exception(ex, env)
      rescue Exception => oops
        if @logger
          begin
            @logger.error("This is awesome. Exception Mailer threw an exception. Details follow")
            @logger.error("\n#{oops.class} (#{oops.message}):\n  " +  oops.backtrace.join("\n  ") + "\n\n")
            @logger.flush if @logger.respond_to? :flush
          rescue
            # Dead meat
          end
        end
      end
    end

    private

    # Careful. Might contain sensitive data.
    def extract_body(env)
      if io = env['rack.input']
        io.rewind if io.respond_to?(:rewind)
        io.read
      end
    end

    def mail_exception(ex, env)
      opts = {}
      opts[:to] = @config[:to]
      opts[:from] = @config[:from]
      opts[:subject] = "#{@prefix}#{ex.message}"
      opts[:body] = @template.result(binding)
      @mailer.mail(opts)
    end

  end

end

