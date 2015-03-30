# test_helper inspired by http://svn.techno-weenie.net/projects/plugins/calculations/test/fixtures/

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

$: << File.dirname(__FILE__) + '/models'

require 'active_record/fixtures'

config = YAML::load_file(File.dirname(__FILE__) + '/database.yml')

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/test.log')
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

ActiveRecord::Migrator.migrate("#{File.dirname(__FILE__)}/../migrations/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
load(File.dirname(__FILE__) + '/schema.rb')

class ActiveSupport::TestCase #:nodoc:

  include ActiveRecord::TestFixtures

  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'

  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false
end