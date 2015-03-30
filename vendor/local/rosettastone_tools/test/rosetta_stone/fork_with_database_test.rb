# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'rosetta_stone/fork_with_database'
require 'fileutils'

class RosettaStone::ForkWithDatabaseTest < Test::Unit::TestCase
  include RosettaStone::ForkWithDatabase

  def test_fork_works_fine
    fork_with_database(1) do
    end
  end

  def test_fork_reports_errors
    exception = assert_raise(RuntimeError) do
      fork_with_database(1) do
        raise 'exception during fork'
      end
    end
    regexp = /exception during fork.*backtrace in (.*)/
    assert_match(regexp, exception.message)
    filename = exception.message.match(regexp)[1]
    assert_true File.exists?(filename)
    FileUtils.rm(filename)
  end

  def test_fork_accesses_the_database_fine
    return if !defined?(ActiveRecord)
    fork_with_database(2) do
      result = ActiveRecord::Base.connection.select_all("select 'bar' as foo")[0]['foo']
      raise "Expected #{result} to be 'bar'" if result != 'bar'
    end
    assert_equal 'awesome', ActiveRecord::Base.connection.select_all("select 'awesome' as packers")[0]['packers']
  end
end
