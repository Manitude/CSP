require 'rosettastone_tools'
require 'granite/engine' if defined?(Rails::Engine)

if defined?(SystemReadiness)
  require File.join('system_readiness', 'granite_amqp_and_ruby')
  require File.join('system_readiness', 'granite_agent_ymls')
  require File.join('system_readiness', 'amqp_and_rabbit_versions')
end

module Granite
  class << self
    # we try to support Granite::Producer without requiring the app to include the amqp and em gems
    # (if you want agents, your code will call this somewhere along the line)
    def load_amqp!
      require 'amqp' # config.gem does this one for us
    end

    if defined?(Rails)
      if Rails::VERSION::MAJOR < 3
        def app_name
          App.name
        end
      else
        def app_name
          Rails.application.class.to_s.split('::').first
        end
      end
    elsif defined?(Goliath)
      def app_name
        Goliath::Application.app_class.to_s
      end
    end
  end

  autoload :ActiveRecordObjectConsumer,  'granite/active_record_object_consumer'
  autoload :ActiveRecordObjectPublisher, 'granite/active_record_object_publisher'
  autoload :Actor,                       'granite/actor'
  autoload :AgentInfo,                   'granite/agent_info'
  autoload :AgentLog,                    'granite/agent_log'
  autoload :AgentMonitoring,             'granite/agent_monitoring'
  autoload :Agent,                       'granite/agent'
  autoload :AgentStatus,                 'granite/agent_status'
  autoload :BaseAgent,                   'granite/base_agent'
  autoload :BaseTopicAgent,              'granite/base_topic_agent'
  autoload :Configuration,               'granite/configuration'
  autoload :ControllerActor,             'granite/controller_actor'
  autoload :ControllerCommand,           'granite/controller_command'
  autoload :ControllerResponse,          'granite/controller_response'
  autoload :Job,                         'granite/job'
  autoload :Later,                       'granite/later'
  autoload :MonitorConfiguration,        'granite/monitor_configuration'
  autoload :MonitoringController,        'granite/monitoring_controller'
  autoload :PidHelper,                   'granite/pid_helper'
  autoload :Producer,                    'granite/producer'
  autoload :RaiderActor,                 'granite/raider_actor'
  autoload :RangedChunkAgent,            'granite/ranged_chunk_agent'
  autoload :RangedChunkProducer,         'granite/ranged_chunk_producer'
end


