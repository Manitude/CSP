# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

class SystemReadiness::AmqpAndRabbitVersions < SystemReadiness::Base
  class << self
    def verify
      response = [true, '']
      begin
        AMQP.start(Rabbit::Config.get(Framework.env).configuration_hash(true).to_hash.symbolize_keys) { EM.stop }
      rescue Exception => exception
        response = [false, "You may have a version of rabbitmq that is too old (sometimes with the symptom of this exception: PossibleAuthenticationFailureError). amqp gem 0.8.x requires rabbitmq version above 2.0 (https://github.com/ruby-amqp/amqp/issues/112). Exception: #{exception.inspect}"]
      end
      response
    end
  end
end
