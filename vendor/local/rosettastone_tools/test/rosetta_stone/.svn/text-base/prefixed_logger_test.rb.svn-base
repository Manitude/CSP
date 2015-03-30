# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::PrefixedLoggerTestClassForInstanceInclusion
  include RosettaStone::PrefixedLogger
end

class RosettaStone::PrefixedLoggerTestClassForClassInclusion
  class << self
    include RosettaStone::PrefixedLogger
  end
end

module RosettaStone::PrefixedLoggerTestModuleForModuleInclusion
  class << self
    include RosettaStone::PrefixedLogger
  end
end

class RosettaStone::PrefixedLoggerTest < Test::Unit::TestCase

  def test_logger_is_defined_for_instance_inclusion
    assert(RosettaStone::PrefixedLoggerTestClassForInstanceInclusion.new.respond_to?(:logger))
    assert(prefixed_logger = RosettaStone::PrefixedLoggerTestClassForInstanceInclusion.new.logger)
    assert(prefixed_logger.is_a?(RosettaStone::LogPrefixer))
    assert_equal('RosettaStone::PrefixedLoggerTestClassForInstanceInclusion', prefixed_logger.instance_variable_get('@name_prefix'))
  end

  def test_logger_is_defined_for_class_inclusion
    assert(RosettaStone::PrefixedLoggerTestClassForClassInclusion.respond_to?(:logger))
    assert(prefixed_logger = RosettaStone::PrefixedLoggerTestClassForClassInclusion.logger)
    assert(prefixed_logger.is_a?(RosettaStone::LogPrefixer))
    assert_equal('RosettaStone::PrefixedLoggerTestClassForClassInclusion', prefixed_logger.instance_variable_get('@name_prefix'))
  end

  def test_logging_with_instance_inclusion
    instance = RosettaStone::PrefixedLoggerTestClassForInstanceInclusion.new
    with_clean_log_file do
      instance.logger.info('test log message')
      lines = log_file_entries.split("\n")
      assert_equal(1, lines.size)
      assert_match(log_entry_matcher('RosettaStone::PrefixedLoggerTestClassForInstanceInclusion', 'test log message'), lines.first)
    end
  end

  def test_logging_with_class_inclusion
    with_clean_log_file do
      RosettaStone::PrefixedLoggerTestClassForClassInclusion.logger.info('test log message')
      lines = log_file_entries.split("\n")
      assert_equal(1, lines.size)
      assert_match(log_entry_matcher('RosettaStone::PrefixedLoggerTestClassForClassInclusion', 'test log message'), lines.first)
    end
  end

  def test_logging_with_module_inclusion
    with_clean_log_file do
      RosettaStone::PrefixedLoggerTestModuleForModuleInclusion.logger.info('test log message')
      lines = log_file_entries.split("\n")
      assert_equal(1, lines.size)
      assert_match(log_entry_matcher('RosettaStone::PrefixedLoggerTestModuleForModuleInclusion', 'test log message'), lines.first)
    end
  end

  def test_log_prefixer_passes_through_methods_that_arent_log_levels
    assert_true(RosettaStone::PrefixedLoggerTestClassForClassInclusion.logger.fatal?)
  end

private

  def log_entry_matcher(name_prefix, message = nil)
    %r{^20\d\d-\d\d-\d\d \d\d:\d\d:\d\d - #{name_prefix} \(pid \d+\): #{message ? message : '.+'}$}
  end
end
