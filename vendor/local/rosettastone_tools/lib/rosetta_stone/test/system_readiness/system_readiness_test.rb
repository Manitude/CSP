# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'test', 'test_helper')
require 'rosetta_stone/test/system_readiness/system_readiness_test_definitions'

class SystemReadiness::SystemReadinessTest < Test::Unit::TestCase
  if ENV['skip_system_readiness_tests'] == 'true'
    define_method 'test skipping system readiness tests' do
      puts 'skipping system readiness tests...'
      assert true
    end
  else
    include SystemReadiness::SystemReadinessTestDefinitions
  end
end
