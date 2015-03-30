require 'rosettastone_tools'
require 'lagomorphic/railtie' if defined?(Rails::Railtie)

module Rabbit
  autoload :AsyncConnection,    'rabbit/async_connection'
  autoload :Config,             'rabbit/config'
  autoload :Connection,         'rabbit/connection'
  autoload :Helpers,            'rabbit/helpers'
  autoload :Producer,           'rabbit/producer'
  autoload :TestUnitExtensions, 'rabbit/test_unit_ext'

  autoload :Error,               'rabbit/connection'
  autoload :ConnectionError,     'rabbit/connection'
  autoload :UnknownError,        'rabbit/connection'
  autoload :AuthenticationError, 'rabbit/connection'

  def self.connection_class
    @connection_class ||= Connection
  end

  def self.connection_class=(klass)
    @connection_class = klass
  end
end

require 'system_readiness/rabbit'
require 'rabbit/test_unit_ext' if defined?(Rails) && Rails.test? # if we're in a non-rails app, like sqrl, we aren't testing this plugin anyway, according to radsaq
